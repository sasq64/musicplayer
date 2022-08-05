/***************************************************************************
 *   Copyright (C) 2004 by David Banz                                      *
 *   neko@netcologne.de                                                    *
 *   GPL'ed                                                                *
 ***************************************************************************/

#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include "player.h"
#include <pthread.h>

#include <sys/stat.h>

#ifdef __linux__
	#include <malloc.h>
#else
	#include <stdlib.h>
#endif

#ifdef _SDL_Framework
        #include <SDL/SDL.h>
#else
        #include "SDL.h"
#endif

void tfmxIrqIn();

char act[8]={1,1,1,1,1,1,1,1};

extern int toOutFile;
extern struct Hdb hdb[8];
extern struct Cdb cdb[8];
extern struct Mdb mdb;

/* we have to make HALFBUFSIZE really 1/2 of BUFSIZE now,
so we can use the maximum fragment size for SDL (...choppy sound under
heavy CPU load otherwise...) */
#define HALFBUFSIZE (65536 * 4)
#define BUFSIZE (131072 * 4)

union
{
 S16 b16[BUFSIZE/2];
 U8 b8[BUFSIZE];
} buf;

volatile int bhead=0,btail=0;


S32 tbuf[HALFBUFSIZE*2];

extern int jiffies;
int bytes=0,bytes2=0;

U32 blocksize=0,multiplier=1,stereo=0;

int sndhdl=0;
int force8=0;
int isfile=0;
int eRem=0; /* remainder of eclocks */
int blend=1; /* default to blended mode */
int filt=1; /* light lpf */
int over=0;

pthread_mutex_t lock;
pthread_cond_t cond;

void fill_audio(void *udata, Uint8 *stream, int len);
void filter(S32 *b, int num);
void stereoblend(S32 *b,int num);
void conv_u8(S32 *b,int num); 
void conv_s16(S32 *b,int num);
void mix_add_ov(struct Hdb *hw,int n,S32 *b);
void mix_add(struct Hdb *hw,int n,S32 *b);
void mixit(int n,int b);  
void mixem(U32 nb,U32 bd);
void open_sndfile(void);
void open_snddev(void); 
int try_to_output(void);
int play_it(void);
void TfmxTakedown(void);   
int try_to_makeblock(void);
void tfmxIrqIn(void);

static int available_sound_data()
{
    int l = bhead - btail + BUFSIZE;
    l %= BUFSIZE;

    return l;
}

/* Simple little three-position weighted-sum LPF. */

void filter(S32 *b, int num)
{
	register int x;
	static int wl=0,wr=0; /* actually backwards but who cares? */
	switch(filt)
	{
	case 3:
		for (x=0;x<num;x++)
		{
			wl=((b[HALFBUFSIZE])+wl*3)>>2; b[HALFBUFSIZE]=wl;
			wr=((*b)+wr*3)>>2; *b++=wr;
		}
		break;
	case 2:
		for (x=0;x<num;x++)
		{
			wl=((b[HALFBUFSIZE])+wl)>>1; b[HALFBUFSIZE]=wl;
			wr=((*b)+wr)>>1; *b++=wr;
		}
		break;
	case 1:
		for (x=0;x<num;x++)
		{
			wl=((b[HALFBUFSIZE])*3+wl)>>2; b[HALFBUFSIZE]=wl;
			wr=((*b)*3+wr)>>2; *b++=wr;
		}
		break;
	}
}

/* This one looks like a good candidate for high optimization... */

void stereoblend(S32 *b,int num)
{
	if (blend)
	{
		int x;
		for (x=0;x<num;x++)
		{
			register int y;
			y=((b[HALFBUFSIZE]*11)+((*b)*5))>>4;
                        b[0]=((b[HALFBUFSIZE]*5)+((*b)*11))>>4;
                        b[HALFBUFSIZE]=y;
                        b++;
		}
	}
}

void conv_u8(S32 *b,int num)
{
	int x;
	S32 *c=b;
	U8 *a=(U8 *)&buf.b8[bhead];

    // there should always be enough space for conversion since buffer is only
    // filled half so abort in this case. We could wait here instead.
    if ( available_sound_data() + ( num * multiplier ) >= BUFSIZE ) {
        abort();
    }
    
	filter(b,num);
	stereoblend(b,num);

	if (stereo)
	{
		for (x=0;x<num;x++)
		{
                        *a++ = ((b[HALFBUFSIZE])>>8) ^ 0x80;
                        *a++ = ((*b++)>>8) ^ 0x80;
		}
	}
	else
	{
		for (x=0;x<num;x++)
		{
/* reverted, the new version probably broke something */
			*a++ = (( b[HALFBUFSIZE] + *b++ )>>9) ^ 0x80;
/*			*a++ = b[HALFBUFSIZE];
			*a = *a + *b++;
			*a = *a >>9;
			*a = *a ^ 0x80;*/
		}
	}
	bytes2+=num;
	for(x=0;x<num;x++)
	{
		c[HALFBUFSIZE]=0;
		*c++=0;
	}

	bhead = ( bhead + ( num * multiplier ) ) % BUFSIZE;
}

void conv_s16(S32 *b,int num)
{
	int x;
	S32 *c=b;
	S16 *a=(S16 *)&buf.b8[bhead];

    // there should always be enough space for conversion since buffer is only
    // filled half so abort in this case. We could wait here instead.
    if ( available_sound_data() + ( num * multiplier ) >= BUFSIZE ) {
        abort();
    }
    
	filter(b,num);
	stereoblend(b,num);

	if (stereo)
	{
		for (x=0;x<num;x++)
		{
                        *a++=(b[HALFBUFSIZE]);
                        *a++=(*b++);
		}
	}
	else
	{
		for (x=0;x<num;x++)
		{
/* reverted, the new version broke -b0 */
			*a++=(b[HALFBUFSIZE]+*b++)>>1;
/*			*a++ = b[HALFBUFSIZE];
			*a = *a + *b++;
			*a = *a >> 1;*/
		}
	}
	bytes2+=num;
	for(x=0;x<num;x++)
	{
		c[HALFBUFSIZE]=0;
		*c++=0;
	}

	bhead = ( bhead + ( num * multiplier ) ) % BUFSIZE;
}

void (*conv)(S32 *,int)=&conv_s16;

static int nul=0;
void (*mix)(struct Hdb *,int,S32 *);

void mix_add(struct Hdb *hw,int n,S32 *b)
{
	register S8 * p = hw->sbeg;
	register U32 ps=hw->pos;
	int v=hw->vol;
	U32 d=hw->delta;
	U32 l=(hw->slen<<14);

	if (v>0x40)v=0x40;

/* This used to have (p==&smplbuf).  Broke with GrandMonsterSlam */
	if ((p==(S8 *)&nul)||( ((hw->mode)&1)==0 )||(l<0x10000))
		return;
	if ((hw->mode&3)==1)
	{
		p=hw->sbeg=hw->SampleStart;
		l=(hw->slen=hw->SampleLength)<<14;
		ps=0;
		hw->mode|=2;
/*		hw->loop(&hw);*/
	}
	if (!v)
	{
#if 0		/* Will be supported someday... */
		while(n--){
			(*b++)+=(p[(ps+=d)>>14]*v);
			if (ps<l) continue;
			ps-=l;
			p=hw->SampleStart;
			if (((l=hw->SampleLength<<14)<=0x10000) ||
			    (!hw->loop(hw)) )
					{
				ps=l=d=0;
				p=smplbuf;
				break;
			}
		}
		return;
#endif
	}
	while(n--){
		(*b++)+=(p[(ps+=d)>>14]*v);
		if (ps<l) continue;
		ps-=l;
		p=hw->SampleStart;
		if ( ((l=((hw->slen=hw->SampleLength)<<14))<0x10000) ||
		     (!hw->loop(hw)) )
				 {
			hw->slen=ps=d=0;
			p=smplbuf;
			break;
		}
	}
	hw->sbeg=p;
	hw->pos=ps;
	hw->delta=d;
	if (hw->mode&4) (hw->mode=0);
}

void mix_add_ov(struct Hdb *hw,int n,S32 *b)
{
	register S8 * p = hw->sbeg;
	register U32 ps=hw->pos;
	register U32 psreal;
	int v=hw->vol;
	U32 d=hw->delta;
	U32 l=(hw->slen<<14);

	int v1;
	int v2;

	if (v>0x40)v=0x40;

/* This used to have (p==&smplbuf).  Broke with GrandMonsterSlam */
	if ((p==(S8 *)&nul)||( ((hw->mode)&1)==0 )||(l<0x10000))
		return;
	if ((hw->mode&3)==1)
	{
		p=hw->sbeg=hw->SampleStart;
		l=(hw->slen=hw->SampleLength)<<14;
		ps=0;
		hw->mode|=2;
	/*	hw->loop(&hw); */
	}
	if (!v)
	{
#if 0		/* Will be supported someday... */
		while(n--){
			(*b++)+=(p[(ps+=d)>>14]*v);
			if (ps<l) continue;
			ps-=l;
			p=hw->SampleStart;
			if (((l=hw->SampleLength<<14)<=0x10000) ||
			    (!hw->loop(hw)) )
					{
				ps=l=d=0;
				p=smplbuf;
				break;
			}
		}
		return;
#endif
	}
/*
#   define RESAMPLATION \
      v1=src[ofs>>FRACTION_BITS];\
      v2=src[(ofs>>FRACTION_BITS)+1];\
      *dest++ = v1 + (((v2-v1) * (ofs & FRACTION_MASK)) >> FRACTION_BITS);

*/
#define FRACTION_BITS 14
#define INTEGER_MASK (0xFFFFFFFF << FRACTION_BITS)
#define FRACTION_MASK (~ INTEGER_MASK)

	while(n--){
		/*
		   register short oo=(ps&0x3FFF);
		   q=((p[(ps >> 14)+1])*(16384-oo));
		   (*b++)+=((p[((ps+=d)>>14)])*oo+q)*v>>14; 
		   */

		/*
		(*b++)+=(p[ps>>14]*v);
	        */
		psreal = ps>>FRACTION_BITS;
		v1 = p[psreal];
		if (psreal+1 < hw->slen)
		{
			v2 = p[psreal+1];
		}
		else
		{
			v2 = hw->SampleStart[0];
			/* fprintf(stderr, "H"); */
			/* (*b++) += v*v1; */
		}
		(*b++) += v*((v1 +
			      (((signed) ((v2-v1) * (ps & FRACTION_MASK)))
			       >> FRACTION_BITS)));
		ps += d;

		if (ps<l) continue;
		ps-=l;
		p=hw->SampleStart;
		if ( ((l=((hw->slen=hw->SampleLength)<<14))<0x10000) ||
		     (!hw->loop(hw)) )
				 {
			hw->slen=ps=d=0;
			p=smplbuf;
			break;
		}
	}
	hw->sbeg=p;
	hw->pos=ps;
	hw->delta=d;
	if (hw->mode&4) (hw->mode=0);
}
	
void (*mix)(struct Hdb *,int,S32 *)=&mix_add;

void mixit(int n,int b)
{
	int x;
	S32 *y;
	if (multimode)
	{
		if(act[4])mix(&hdb[4],n,&tbuf[b]);
		if(act[5])mix(&hdb[5],n,&tbuf[b]);
		if(act[6])mix(&hdb[6],n,&tbuf[b]);
		if(act[7])mix(&hdb[7],n,&tbuf[b]);
		y=&tbuf[HALFBUFSIZE+b];
		for (x=0;x<n;x++,y++)
			*y=(*y>16383)?16383:
			   (*y<-16383)?-16383:*y;
	}
	else
		if(act[3])mix(&hdb[3],n,&tbuf[b]);
	if(act[0])mix(&hdb[0],n,&tbuf[b]);
	if(act[1])mix(&hdb[1],n,&tbuf[HALFBUFSIZE+b]);
	if(act[2])mix(&hdb[2],n,&tbuf[HALFBUFSIZE+b]);
}

void mixem(U32 nb,U32 bd)
{
/*	printf("nb=%5d bd=%5d\n",nb,bd);*/
	if (over==-1) mix=&mix_add_ov; else mix=&mix_add;
	mixit(nb,bd);
/*	printf("%6d at byte %4x (made %4x bytes) %3xbpm\n",
	       jiffies,bd,nb,0x1B51F8/eClocks);*/
/*	if (mix==&mix_set)*/
}

void open_snddev()
{
        SDL_AudioSpec wanted;
	
	multiplier=2;
	if (force8) conv=&conv_u8;
	blocksize=HALFBUFSIZE;

	/* SDL open device here */

        /* Set the audio format */
        wanted.freq = outRate;

#ifdef WORDS_BIGENDIAN
	wanted.format = (force8?AUDIO_U8:AUDIO_S16MSB);
#else
        wanted.format = (force8?AUDIO_U8:AUDIO_S16LSB);
#endif
        wanted.channels = (stereo?2:1);
        wanted.samples = (force8?4096:8192); /* as big as it gets */
        wanted.callback = fill_audio;
        wanted.userdata = NULL;

	if ( SDL_OpenAudio(&wanted, NULL) < 0 )
	{
	        fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
	        /* */
		_exit(-1);
	}
	SDL_PauseAudio(0);

	multiplier*=(stereo?2:1);
	multiplier/=(force8?2:1);

        if (stereo)
		blocksize=blocksize/multiplier/2;
        else
	        blocksize=blocksize/multiplier/4;

	if (blocksize>HALFBUFSIZE)
	{
		fprintf(stderr,"Block size %d not supported",blocksize);
		_exit(1);
	}
	return;
}

void open_sndfile()
{
/*	int x=0;*/
	multiplier=2;

	if (force8) conv=&conv_u8;
	
/* FIXME: I hope this is correct*/
#ifdef WORDS_BIGENDIAN
	outRate*=(force8?1:2);
#endif

	blocksize=HALFBUFSIZE;

	if ((sndhdl=open(outf,O_WRONLY|O_CREAT|O_TRUNC,0644))<0)
	{		
		perror("open");
		_exit(1);
	}

	multiplier*=(stereo?2:1);
	multiplier/=(force8?2:1);

        if (stereo)
		blocksize=blocksize/multiplier/2;
        else
	        blocksize=blocksize/multiplier/4;

	if (blocksize>HALFBUFSIZE)
	{
		fprintf(stderr,"Block size %d not supported",blocksize);
		close(sndhdl);
		_exit(1);
	}
	return;
}


void TfmxTakedown()
{
	if (toOutFile==1)
	{
		close(sndhdl);
	}
	free(smplbuf);

	if (toOutFile==0)
	{
		SDL_CloseAudio();
		SDL_Quit();
	}
}


int try_to_makeblock()
{
	static S32 nb=0,bd=0; /* num bytes, bytes done */
	int n,r=0;
    int loops = 0;

    while ( available_sound_data() < BUFSIZE / 2 && mdb.PlayerEnable ) {
        loops++;

		tfmxIrqIn();
		nb=(eClocks*(outRate>>1));
		eRem+=(nb%357955);
		nb/=357955;
		if (eRem>357955) nb++,eRem-=357955;
		while (nb>0)
		{
			n=blocksize-bd;
			if (n>nb) n=nb;
			mixem(n,bd);
			bytes+=n;
			bd+=n;
			nb-=n;

            // convert full blocksize or partial block at end of player
			if ( ((unsigned int)bd) == blocksize || ! mdb.PlayerEnable )
			{
				conv(&tbuf[0],bd);
				bd=0;
				r++;
			}
		}
	}

    if ( ! loops && toOutFile == 0 ) {
        pthread_mutex_lock( &lock );
        if ( available_sound_data() >= BUFSIZE / 2 ) {
            pthread_cond_wait( &cond, &lock );
        }
        pthread_mutex_unlock( &lock );
    }
    
	return((mdb.PlayerEnable)?r:-1);
}

void fill_audio(void *udata, Uint8 *stream, int len)
{
    int avail = available_sound_data();

    if ( avail < len ) {
        SDL_memset( stream + avail, 0, len - avail );

        len = avail;
    }

    int total_len = len;
    int written = 0;

    // we need to loop if we hit the ring buffer boundary while trying
    // to fill len audio bytes
    while ( total_len > 0 ) {
        if ( btail + len > BUFSIZE ) {
            len = BUFSIZE - btail;
        }

        SDL_MixAudio(stream + written, &buf.b8[btail], len, SDL_MIX_MAXVOLUME);

        btail = ( btail + len ) % BUFSIZE;
        written += len;

        total_len -= len;

        // try again to write all data
        len = total_len;
    }
    
	/* udata is not used, but that's because of SDL */

    // for a signal we should need the lock but we do it anyway (more
    // often than we need)
    pthread_cond_signal( &cond );
}

int write_output()
{
	int x;
	//int n=blocksize*multiplier;

	if (toOutFile==0) {
        return 0;
    }

    int total_len = available_sound_data();
    int len;
    
    while ( total_len > 0 ) {
        len = total_len;
        if ( btail + len > BUFSIZE ) {
            len = BUFSIZE - btail;
        }

		x = write( sndhdl, &buf.b8[btail], len );

        if ( x <= 0 ) {
            perror("write");
            close(sndhdl);
            _exit(1);
        }

        btail = ( btail + len ) % BUFSIZE;

        total_len -= x;
	}
	
	/* did not have any return value */
	return 1;
}

int play_it()
{
    pthread_mutex_init( &lock, NULL );
    pthread_cond_init( &cond, NULL );
    
	while (try_to_makeblock());
	while (try_to_makeblock()>=0)
	{
		write_output();
	}

    write_output();

    if (toOutFile==0) {
        while ( available_sound_data() > 0 ) SDL_Delay( 25 );
    }

    pthread_mutex_destroy( &lock );
    pthread_cond_destroy( &cond );

    return (0);
}
