/***************************************************************************
 *   Copyright (C) 2004 by David Banz                                      *
 *   neko@netcologne.de                                                    *
 *   GPL'ed                                                                *
 ***************************************************************************/

#ifdef __linux__
	#include <asm/byteorder.h>
#endif

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "tfmxsong.h"
#include "player.h"
#include <sys/stat.h>
#include <fcntl.h>
#include <openssl/evp.h>

#ifdef _SDL_Framework
        #include <SDL/SDL.h>
#else
        #include "SDL.h"
#endif

/* external functions */
void open_sndfile();
void open_snddev();
void TfmxInit();
void StartSong();
void play_it();
void TfmxTakedown();

/* internal functions */
void check_md5_and_headers(char *mfile);
void usage(char *x);
void dump_macro(int *a);
void dump_pattern(int x);
int load_tfmx(char *mfn, char *sfn);
void do_debug(void);

/* MD5 digests for TFMX songs that need special treatment... */
unsigned const char* md5GemxTitle="\xf4\xa1\xd6\x04\xc4\xdf\xb3\x0f\x91\x0f\xd8\xac\x4b\x96\xe3\x06";
unsigned const char* md5DfreakTitle="\x9c\xf1\x72\x34\xbc\xe1\x0d\x21\xe2\x90\x11\x72\xeb\x1a\x2a\xcc";
unsigned const char* md5OopsUpBroken="\x79\x41\x33\xe1\xf1\x13\x1b\x23\xc0\x9c\xd7\x29\xe8\xa6\x2a\x4e";
unsigned const char* md5OopsUp="\x9a\x19\x78\x84\xa8\x15\x5e\xdd\x02\x90\x23\x57\xfa\xf2\x4e\x4e";

unsigned const char*
md5Monkey="\xc9\x5a\xa4\xf4\x44\xe8\x9a\x3f\x61\x4d\xfd\xe4\x20\x29\x96\x2a";

/* this is the MDAT that causes a segfault and other errors on MacOS-X */
unsigned const char* md5WeirdZoutThm="\xb2\x7c\xa7\x9c\x14\x69\x63\x87\xc1\x9c\x01\xf6\x5e\x15\x3e\xff";

int weirdZoutThm=0;
int dangerFreakHack=0;
int oopsUpHack=0;
int monkeyHack=0;

/* do we have a single-file TFMX (mdat+smpl in one file) ? */
int singleFile=0;
/* are DOS extensions used? (.tfx/.sam) */
int dosExt=0;
/* header data for single-file TFMX */
uint nTFhd_offset=0;
uint nTFhd_mdatsize=0;
uint nTFhd_smplsize=0;

U32 outRate=44100;
extern int force8;

struct Hdr hdr;
extern struct Hdb hdb[8];
extern struct Pdblk pdb;
extern int LoopOff();
extern struct Mdb mdb;

extern char act[8];

int toOutFile=0;
char outf[PATHNAME_LENGTH]="/dev/null";
unsigned int mlen;
U32 editbuf[16384];
U8 *smplbuf;
int *macros;
int *patterns;
short ts[512][8];

int num_ts,num_pat,num_mac;

int songnum=0;
int gubed=0;
int printinfo=0;
int startPat=-1;
int gemx=0;
int loops=1;
extern int blend,filt,over;

/* misc vars for TFMX format test */
#define MAGIK_LEN 11        /* length including final null byte */
unsigned int nMagikLen=MAGIK_LEN;
char pMagikBuf[MAGIK_LEN];




/* TFMX format test from UADE */
static int tfmxtest(unsigned char *buf, int filesize, char *pre)
{
  int ret = 0;

  if (buf[0] == 'T' && buf[1] == 'F' && buf[2] =='H' && buf[3] =='D')
  {
    if (buf[0x8] == 0x01) {
      strncpy (pre, "TFHD1.5\x00", nMagikLen-1);		/* One File TFMX format */
      /* by Alexis NASR */
      ret = 1;
    } else if (buf[0x8] == 0x02) {
      strncpy (pre, "TFHDPro\x00",nMagikLen-1);
      ret = 1;
    } else if (buf[0x8] == 0x03) {
      strncpy (pre, "TFHD7V\x00",nMagikLen-1);
      ret = 1;
    }

  } else if ((buf[0] == 'T' && buf[1] == 'F' && buf[2] =='M' && buf[3] == 'X')||
	     (buf[0] == 't' && buf[1] == 'f' && buf[2] =='m' && buf[3] == 'x'))  {

    strncpy (pre, "MDAT\x00",nMagikLen-1);	/*default TFMX: TFMX Pro*/
    ret = 1;

    if ((buf [4] == '-' &&  buf[5] == 'S' && buf[6] =='O' && buf[7] == 'N' && buf[8] == 'G' && buf[9] == ' ')||
	(buf [4] == '_' &&  buf[5] == 'S' && buf[6] =='O' && buf[7] == 'N' && buf[8] == 'G' && buf[9] == ' ')||
	(buf [4] == 'S' &&  buf[5] == 'O' && buf[6] =='N' && buf[7] == 'G')||
	(buf [4] == 's' &&  buf[5] == 'o' && buf[6] =='n' && buf[7] == 'g')||
	(buf [4] == 0x20)) {
      if ((buf [10] =='b'  && buf[11] =='y')  ||
	  (buf [16] == ' ' && buf[17] ==' ')  ||
	  (buf [16] == '(' && buf[17] =='E' && buf[18] == 'm' && buf[19] =='p' && buf[20] =='t' && buf[21] == 'y' && buf[22] ==')' ) ||
	  (buf [16] == 0x30 && buf[17] == 0x3d) || /*lethal Zone*/
	  (buf [4]  == 0x20)) {
	if (buf[464]==0x00 && buf[465]==0x00 && buf[466]==0x00 && buf[467]==0x00) {
	  if ((buf [14]!=0x0e && buf[15] !=0x60) || /*z-out title */
	      (buf [14]==0x08 && buf[15] ==0x60 && buf[4644] != 0x09 && buf[4645] != 0x0c) || /* metal law */
	      (buf [14]==0x0b && buf[15] ==0x20 && buf[5120] != 0x8c && buf[5121] != 0x26) || /* bug bomber */
	      (buf [14]==0x09 && buf[15] ==0x20 && buf[3876] != 0x93 && buf[3977] != 0x05)) { /* metal preview */
	    strncpy (pre, "TFMX1.5\x00",nMagikLen-1);	/*TFMX 1.0 - 1.6*/
	  }
	}
      } else if (((buf[0x0e]== 0x08 && buf[0x0f] ==0xb0) &&   /* BMWi */
		  (buf[0x140] ==0x00 && buf[0x141]==0x0b) && /*End tackstep 1st subsong*/
		  (buf[0x1d2]== 0x02 && buf[0x1d3] ==0x00) && /*Trackstep datas*/

		  (buf[0x200] == 0xff && buf[0x201] ==0x00 && /*First effect*/
		   buf[0x202] == 0x00 && buf[0x203] ==0x00 &&
		   buf[0x204] == 0x01 && buf[0x205] ==0xf4 &&
		   buf[0x206] ==0xff && buf[0x207] ==0x00)) ||

		 ((buf[0x0e]== 0x0A && buf[0x0f] ==0xb0) && /* B.C Kid */
		  (buf[0x140] ==0x00 && buf[0x141]==0x15) && /*End tackstep 1st subsong*/
		  (buf[0x1d2]== 0x02 && buf[0x1d3] ==0x00) && /*Trackstep datas*/

		  (buf[0x200] == 0xef && buf[0x201] ==0xfe && /*First effect*/
		   buf[0x202] == 0x00 && buf[0x203] ==0x03 &&
		   buf[0x204] == 0x00 && buf[0x205] ==0x0d &&
		   buf[0x206] ==0x00 && buf[0x207] ==0x00)))  {
	strncpy (pre, "TFMX7V\x00",nMagikLen-1);	/* "special cases TFMX 7V*/

      } else {

	int e, i, s, t;

	/* Trackstep datas offset */
	if (buf[0x1d0] ==0x00 && buf[0x1d1] ==0x00 && buf[0x1d2] ==0x00 && buf[0x1d3] ==0x00) {
	  /* unpacked*/
	  s = 0x00000800;
	} else {
	  /*packed */
	  s = (buf[0x1d0] <<24) + (buf[0x1d1] <<16) + (buf[0x1d2] <<8) + buf[0x1d3]; /*packed*/
	}

	for (i = 0; i < 0x3d; i += 2) {
	  if (( (buf[0x140+i] <<8 ) +buf[0x141+i]) > 0x00 ) { /*subsong*/
	    t = (((buf[0x100+i]<<8) +(buf[0x101+i]))*16 +s ); /*Start of subsongs Trackstep data :)*/
	    e = (((buf[0x140+i]<<8) +(buf[0x141+i]))*16 +s ); /*End of subsongs Trackstep data :)*/
	    if (t < filesize || e < filesize) {
	      for (t = t ; t < e ; t += 2) {
		if (buf[t] == 0xef && buf[t+1] == 0xfe) {
		  if (buf[t+2] == 0x00 && buf[t+3] == 0x03 &&
		      buf[t+4] == 0xff && buf[t+5] == 0x00 && buf[t+6] == 0x00) {
		    i=0x3d;
		    strncpy (pre, "TFMX7V\x00",nMagikLen-1);	/*TFMX 7V*/
		    break;
		  }
		}
	      }
	    }
	  }
	}
      }
    }
  }
  return ret;
}


void check_md5_and_headers(char *mfile)
{
	EVP_MD_CTX mdctx;
	const EVP_MD *md;
	unsigned char md_value[EVP_MAX_MD_SIZE];
	int md_len;
        
	/* return value of format test */
	int nUadeRet=0;

	int mc=0;
	int dfc=0;
	int gxc=0;
	int zxc=0;
	int ooxc=0;
	int ooxc2=0;
	int monkeyc=0;
	long size=-1;
	unsigned long pos=0;
	unsigned char* fdat;
	
	FILE *fp=0;
	
	if ((fp=fopen(mfile,"r")) == 0)
	{
		perror("fopen");
		return;
	}
	while ( !feof(fp) )
	{
		getc(fp);
		size++;
	}
	/* have filesize */
	fclose(fp);
	/* allocale buffer */
	fdat=malloc((sizeof(unsigned char))*((unsigned long)size));
	/* fill buffer */
	if ((fp=fopen(mfile,"r")) == 0)
	{
		perror("fopen");
		return;
	}
	for (pos=0; pos < ((unsigned long)(size)); pos++)
	{
		fdat[pos]=getc(fp);
	}
	fclose(fp);

	/* since we have got the file loaded, it's a good time to run the format test... */
	/* first clear magik buffer */
	memcpy(pMagikBuf,"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",nMagikLen);
	/* run test */
        nUadeRet=tfmxtest(fdat, ((unsigned long)size), pMagikBuf);
	/* print result */
	printf("\nmagik[%s] ret[%d]\n",pMagikBuf,nUadeRet);
        /*
	TODO do something with result...
	"MDAT"
	"TFMX1.5"
	"TFMXPro" (we only get this for 1-file TFMX-songs, which are not supported anyway ATM.)
	"TFMX7V"
	nUadeRet==1 ==> some kind of TFMX format, otherwise not recognized
	*/

	/* if it's a single-file TFMX, let's grab the pointers to mdat+smpl while we're at it */
	if (singleFile==1)
	{
		memcpy( (void*)(&nTFhd_offset), (void*)(fdat+4), 4);
		nTFhd_offset=ntohl(nTFhd_offset);
		/* now we have the size of the header */
		memcpy( (void*)(&nTFhd_mdatsize), (void*)(fdat+10), 4);
		nTFhd_mdatsize=ntohl(nTFhd_mdatsize);
		/* now we have the size of the mdat */
		memcpy( (void*)(&nTFhd_smplsize), (void*)(fdat+14), 4);
		nTFhd_smplsize=ntohl(nTFhd_smplsize);
		/* now we have the size of the smpl */
	
		/* check if the actual filesize matches the size given by the header */
		if (nTFhd_offset+nTFhd_mdatsize+nTFhd_smplsize != size)
		{
			printf("\nERROR! 1-file TFMX header defines illegal size:\
[%d] instead of [%d] \n",nTFhd_offset+nTFhd_mdatsize+nTFhd_smplsize,(unsigned long)size);
			exit(0);
		}
	
	}

	/* create md5 digest */
	OpenSSL_add_all_digests();
	md = EVP_get_digestbyname("MD5");
	if (!md) {
		printf("Unknown message digest MD5");
		exit(1);
	}
	EVP_DigestInit(&mdctx, md);
	EVP_DigestUpdate(&mdctx, fdat, size);
	EVP_DigestFinal(&mdctx, md_value, &md_len);
	/* compare md5 sums */
	for (mc=0; mc<16; mc++)
	{
		if (md_value[mc]==md5DfreakTitle[mc])
			dfc++;
	}
	for (mc=0; mc<16; mc++)
	{
		if (md_value[mc]==md5GemxTitle[mc])
			gxc++;
	}
	for (mc=0; mc<16; mc++)
	{
		if (md_value[mc]==md5WeirdZoutThm[mc])
			zxc++;
	}
	for (mc=0; mc<16; mc++)
	{
		if (md_value[mc]==md5OopsUp[mc])
			ooxc++;
	}
	for (mc=0; mc<16; mc++)
	{
		if (md_value[mc]==md5OopsUpBroken[mc])
			ooxc2++;
	}
	for (mc=0; mc<16; mc++)
	{
		if (md_value[mc]==md5Monkey[mc])
			monkeyc++;
	}
	if (dfc==16)
		dangerFreakHack=1;
	else if (gxc==16)
		gemx=1;
	else if (ooxc==16)
	        oopsUpHack=1;
	else if (ooxc2==16)
	        oopsUpHack=1;
	else if (zxc==16)
	        weirdZoutThm=1;
	else if (monkeyc==16)
	        monkeyHack=1;

#ifdef WORDS_BIGENDIAN
	if (weirdZoutThm==1)
	{
		printf("Warning! Problematic Z-Out theme mdat detected!\n\
May cause crashes/hangups on big-endian CPUs!\n");
	}
#endif

	/* free buffer */
	free(fdat);
	return;
}

void usage(char *x)
{
	fprintf(stderr,"tfmxplay v1.1.7/SDL by Jon Pickard <marxmarv@antigates.com>,\n"
"Neochrome <neko@netcologne.de> and others.\n"
"Copyright 1996-2004, see accompanying README for details.\n"
"\n"
"Usage: %s [options] mdat-file [smpl-file]\n"
"where options is one or more of:\n"
"-b mode		set stereo mode (0=mono, default 1=headphone, 2=stereo)\n"
"-8		generate 8-bit output\n"
"-p num		subsong to play (default 0)\n"
"-f freq		suggest playback rate in samples/sec (default 44100)\n"
"-o file		write audio output to file\n"
"-i		print info about the module (text, subsong, etc.)\n"
"-w num		set low-pass filter frequency (0=none, 3=lowest, default 0)\n"
"-l num		set loop mode (0=no repeat, default 1=infinite)\n"
"-v              disable oversampling (=linear interpolation)\n"
"-D              force hack for Danger Freak title tune\n"
"-G              force old hack for GemX title tune (still incomplete)\n"
,x
);

}

void dump_macro(int *a)
{
	int x=0,s=0;
	while (((x&0xff000000)!=(0x07000000))&&(s<511))
	{
		x=ntohl(a[s]);
		printf("%04x: %08x ",s,x);
		puts("");
		s++;
	}
}

/* this one can also load a single-file TFMX :) */
int load_tfmx(char *mfn, char *sfn)
{
	FILE *gfd;
	struct stat s;
	unsigned int x,y,z=0;
	U16 *sh,*lg;

	if ((gfd=fopen(mfn,"r")) == 0)
	{
		perror("fopen");
		return(1);
	}

	/* jump to mdat start if single-file format */
	if (singleFile==1)
	{
		fseek(gfd, nTFhd_offset, SEEK_CUR);
	}

	if (!fread(&hdr,sizeof(hdr),1,gfd))
	{
		perror("fread");
		fclose(gfd);
		return(1);
	}
	if (strncmp("TFMX-SONG",hdr.magic,9)&&
	    strncmp("TFMX_SONG",hdr.magic,9)&&
	    strncasecmp("TFMXSONG",hdr.magic,8) &&
	    strncmp("TFMX",hdr.magic,4))
	{
		fclose(gfd);
		return(2);
	}
	if (!(x=fread(&editbuf,sizeof(int),16384,gfd)))
	{
		perror("fread");
		fclose(gfd);
		return(1);
	}

	/* close file if we have two files for mdat+smpl */
	if (singleFile==0)
	{
        	fclose(gfd);
	}

	mlen=x;
	editbuf[x]=-1;

	if (!hdr.trackstart)
		hdr.trackstart=0x180;
	else
		hdr.trackstart=(ntohl(hdr.trackstart)-0x200)>>2;

	if (!hdr.pattstart)
		hdr.pattstart=0x80;
	else
		hdr.pattstart=(ntohl(hdr.pattstart)-0x200)>>2;

	if (!hdr.macrostart)
		hdr.macrostart=0x100;
	else
		hdr.macrostart=(ntohl(hdr.macrostart)-0x200)>>2;

	if (x<136)
	{
		return(2);
	}

	for (x=0;x<32;x++)
	{
		hdr.start[x]=ntohs(hdr.start[x]);
		hdr.end[x]=ntohs(hdr.end[x]);
		hdr.tempo[x]=ntohs(hdr.tempo[x]);
	}

/* Now that we have pointers to most everything, this would be a good time to
   fix everything we can... ntohs tracksteps, convert pointers to array
   indices, ntohl patterns and macros.  We fix the macros first, then the
   patterns, and then the tracksteps (because we have to know when the
   patterns begin to know when the tracksteps end...) */
	z=hdr.macrostart;
	macros = &editbuf[z];

	for (x=0;x<128;x++)
	{
		y=(ntohl(editbuf[z])-0x200);
		if ((y&3)||((y>>2)>mlen)) /* probably not strictly right */
			break;
		editbuf[z++]=y>>2;
	}
	num_mac=x;

	z=hdr.pattstart;
	patterns = &editbuf[z];
	for (x=0;x<128;x++)
	{
		y=(ntohl(editbuf[z])-0x200);
		if ((y&3)||((y>>2)>mlen))
			break;
		editbuf[z++]=y>>2;
	}
	num_pat=x;

	lg=(U16 *)&editbuf[patterns[0]];
	sh=(U16 *)&editbuf[hdr.trackstart];
	num_ts=(patterns[0]-hdr.trackstart)>>2;
	y=0;
	while (sh<lg)
	{
		x=ntohs(*sh);
		*sh++=x;
	}

/* Now at long last we load the sample file/data. */

	/* different handling for single- and dual-file formats */
	if (singleFile==1)
	{
	        /* jump to smpl start */
	        uint nSmplPos=nTFhd_offset+nTFhd_mdatsize;
		fseek(gfd, nSmplPos, SEEK_SET);
                /* allocate mem */
		if (!(smplbuf=(void *)malloc(nTFhd_smplsize)))
		{
			perror("malloc");
			fclose(gfd);
			return(1);
		}
		/* read samples */
		if (!fread(smplbuf,sizeof(char),nTFhd_smplsize,gfd))
		{
			perror("read");
			fclose(gfd);
			free(smplbuf);
			return(1);
		}
		/* finally close the file */
	        fclose(gfd);
	}
	else
	{
		if ((y=open(sfn,O_RDONLY))<=0)
		{
			perror("fopen");
			return(1);
		}
		if (fstat(y,&s))
		{
			perror("fstat");
			close(y);
			return(1);
		}
		if (!(smplbuf=(void *)malloc(s.st_size)))
		{
			perror("malloc");
			close(y);
			return(1);
		}
		if (!read(y,smplbuf,s.st_size))
		{
			perror("read");
			close(y);
			free(smplbuf);
			return(1);
		}
		close(y);
	}
	return (0);
}


char *pattcmds[]={
(char *)"End --Next track  step--",
(char *)"Loop[count     / step.w]",
(char *)"Cont[patternno./ step.w]",
(char *)"Wait[count 00-FF--------",
(char *)"Stop--Stop this pattern-",
(char *)"Kup^-Set key up/channel]",
(char *)"Vibr[speed     / rate.b]",
(char *)"Enve[speed /endvolume.b]",
(char *)"GsPt[patternno./ step.w]",
(char *)"RoPt-Return old pattern-",
(char *)"Fade[speed /endvolume.b]",
(char *)"PPat[patt./track+transp]",
(char *)"Lock---------ch./time.b]",
(char *)"----------No entry------",
(char *)"Stop-Stop custompattern-",
(char *)"NOP!-no operation-------"
};

char *macrocmds[]={
(char *)"DMAoff+Resetxx/xx/xx flag/addset/vol   ",
(char *)"DMAon (start sample at selected begin) ",
(char *)"SetBegin    xxxxxx   sample-startadress",
(char *)"SetLen      ..xxxx   sample-length     ",
(char *)"Wait        ..xxxx   count (VBI''s)     ",
(char *)"Loop        xx/xxxx  count/step        ",
(char *)"Cont        xx/xxxx  macro-number/step ",
(char *)"-------------STOP----------------------",
(char *)"AddNote     xx/xxxx  note/detune       ",
(char *)"SetNote     xx/xxxx  note/detune       ",
(char *)"Reset   Vibrato-Portamento-Envelope    ",
(char *)"Portamento  xx/../xx count/speed       ",
(char *)"Vibrato     xx/../xx speed/intensity   ",
(char *)"AddVolume   ....xx   volume 00-3F      ",
(char *)"SetVolume   ....xx   volume 00-3F      ",
(char *)"Envelope    xx/xx/xx speed/count/endvol",
(char *)"Loop key up xx/xxxx  count/step        ",
(char *)"AddBegin    xx/xxxx  count/add to start",
(char *)"AddLen      ..xxxx   add to sample-len ",
(char *)"DMAoff stop sample but no clear        ",
(char *)"Wait key up ....xx   count (VBI''s)     ",
(char *)"Go submacro xx/xxxx  macro-number/step ",
(char *)"--------Return to old macro------------",
(char *)"Setperiod   ..xxxx   DMA period        ",
(char *)"Sampleloop  ..xxxx   relative adress   ",
(char *)"-------Set one shot sample-------------",
(char *)"Wait on DMA ..xxxx   count (Wavecycles)",
(char *)"Random play xx/xx/xx macro/speed/mode  ",
(char *)"Splitkey    xx/xxxx  key/macrostep     ",
(char *)"Splitvolume xx/xxxx  volume/macrostep  ",
(char *)"Addvol+note xx/fe/xx note/CONST./volume",
(char *)"SetPrevNote xx/xxxx  note/detune       ",
(char *)"Signal      xx/xxxx  signalnumber/value",
(char *)"Play macro  xx/.x/xx macro/chan/detune ",
(char *)"SID setbeg  xxxxxx   sample-startadress",
(char *)"SID setlen  xx/xxxx  buflen/sourcelen  ",
(char *)"SID op3 ofs xxxxxx   offset            ",
(char *)"SID op3 frq xx/xxxx  speed/amplitude   ",
(char *)"SID op2 ofs xxxxxx   offset            ",
(char *)"SID op2 frq xx/xxxx  speed/amplitude   ",
(char *)"SID op1     xx/xx/xx speed/amplitude/TC",
(char *)"SID stop    xx....   flag (1=clear all)"
};

void dump_pattern(int x)
{
	const char *n1="CCDDEFFGGAAB",*n2=" # #  # # # ";
	UNI a;
	int y=0,z,zz;
	static char n[]={0,0,0,0};
	printf("Pattern %02x:\n",x);
	x=patterns[x];
	a.b.b0=0;
	while (a.b.b0!=0xF0)
	{
		a.l=ntohl(editbuf[x++]);
		if ((z=a.b.b0)<0xF0)
		{
			zz=(z&0x3F)+6;
			n[2]=48+(zz/12);
			zz%=12;
			n[0]=n1[zz];
			n[1]=n2[zz];
		}
		if (z<0x80)
		{
			printf("%04x: %02x %s %02x %x %x %02x\n",
			       y++,
			       a.b.b0,
			       n,
			       a.b.b1,
			       a.b.b2>>4,
			       a.b.b2&0xF,
			       a.b.b3
			       );
		}
		else if (z<0xC0)
		{
			printf("%04x: %02x %s %02x %x %x %02x wait\n",
			       y++,
			       a.b.b0,
			       n,
			       a.b.b1,
			       a.b.b2>>4,
			       a.b.b2&0xF,
			       a.b.b3
			       );
		}
		else if (z<0xF0)
		{
			printf("%04x: %02x %s %02x %x %x %02x porta\n",
			       y++,
			       a.b.b0,
			       n,
			       a.b.b1,
			       a.b.b2>>4,
			       a.b.b2&0xF,
			       a.b.b3
			       );
		}
		else
		{
			printf("%04x: %02x %s %02x %x %x %02x\n",
			       y++,
			       a.b.b0,
			       pattcmds[z-0xF0],
			       a.b.b1,
			       a.b.b2>>4,
			       a.b.b2&0xF,
			       a.b.b3
			       );
		}
	}
}

void do_debug()
{
	char in[81];
	int x,y;
	UNI a;
	while(1)
	{
		for(x=0;x<81;in[x++]=0);
		fgets(in,80,stdin);
		switch(in[0])
		{
		case 'p':
			switch(in[1])
			{
			case 'm': /* dump macro */
				x=atoi(&in[2]);
				printf("Macro %02x:\n",x);
				x=macros[x];
				a.b.b0=0;
				y=0;
				while (a.b.b0!=0x07)
				{
					a.l=ntohl(editbuf[x++]);
					printf("%04x: %02x %02x%04x %s\n",
					       y++,
					       a.b.b0,
					       a.b.b1,
					       a.w.w1,
					       macrocmds[a.b.b0]
					       );
				}
				break;
			case 'p': /* dump pattern */
				x=atoi(&in[2]);
				dump_pattern(x);
				break;
			case 's': /* print voice status */
			default:
				puts("?!");
				break;
			}
			break;
		case 'q':
			return;
		default:
			puts("?!");
			break;
		}
	}
}

int main(int argc, char **argv)
{
	char* tfxloc=0;

	int x;
	char* c=0;
	char mfn[PATHNAME_LENGTH],sfn[PATHNAME_LENGTH];

	over = -1;
	filt = 0;

	/* throw out 'root' */
	if ((0 == getuid())||(0 == geteuid()))
	{
		printf("Do not run tfmx-play as 'root'!\n");
		return(-123);	/* test for this in SakuraPlayer! */
	}
	
	while ((x=getopt(argc,argv,"~GDivSb:8o:f:P:V:p:w:l:"))!=-1)
	{
		switch (x)
		{
		case '?':
		case ':':
			usage(argv[0]);
			exit(2);
		case 'o':
			strncpy(outf,optarg,PATHNAME_LENGTH-1);
			outf[PATHNAME_LENGTH-1]='\0';
			toOutFile=1;
			break;
		case 'P':
			startPat=strtol(optarg,NULL,0);
			break;
		case 'f':
			outRate=strtol(optarg,NULL,0);
			break;
		case 'b':
			blend=strtol(optarg,NULL,0);
			break;
		case 'p':
			songnum=strtol(optarg,NULL,0);
			break;
		case 'w':
			filt=strtol(optarg,NULL,0);
			break;
		case 'l':
			loops=strtol(optarg,NULL,0);
			break;
		case 'v':
			over=0;
			break;
		case 'G':
			gemx=1;
			break;
		case 'D':
			dangerFreakHack=1;
			break;
		case 'S':
			/* left for compatibility, this switch is inactive */
			break;
		case 'i':
			printinfo=1;
			break;
		case 'V':
			c=optarg;
			for(;*c;act[(*c++)&7]=0);
			break;
		case '8':
			force8=1;
			break;
		case '~':
			gubed=1;
			break;
		default:
			fprintf(stderr,"getopt: got code 0x%x\n",x);
		}
	}
	if (optind<argc)
	{
		strncpy(mfn,argv[optind++],PATHNAME_LENGTH-1);
		mfn[PATHNAME_LENGTH-1]='\0';
		strncpy(sfn,"\0",1);
		if (optind<argc)
		{
			strncpy(sfn,argv[optind++],PATHNAME_LENGTH-1);
			sfn[PATHNAME_LENGTH-1]='\0';
			printf("IF\n");
		}
		else
		{
			strncpy(sfn,mfn,PATHNAME_LENGTH-1);
			sfn[PATHNAME_LENGTH-1]='\0';
			if (!(c=strrchr(sfn,'/'))) c=sfn; else c++;
			
			/* start looking for ".tfx" at the first null byte */
			tfxloc=strchr(c,'\0');
			/* filename w/o path must be at least 5 chars long */
			if ((tfxloc-4) > c)
			{
				/* move pointer to the last four chars */
				tfxloc=tfxloc-4;
				if (0 == strncasecmp(tfxloc,".tfx",4))
				{
					/* we are using dos extensions */
					dosExt=1;
				}
			}

			if (dosExt != 1)
			{
				if (strncasecmp(c,"mdat.",5))
				{
					if (strncasecmp(c,"tfmx.",5))
					{
						puts("'mdat'/'tfmx' prefix missing\n");
					}
					else
					{
						singleFile=1;
						sfn[0]='\0';
					}
				}
	
				/*
				* Case-preserving conversion of "mdat" to "smpl"
				*/
				if (singleFile==0)
				{
					(*c++)^='m'^'s';
					(*c++)^='d'^'m';
					(*c++)^='a'^'p';
					(*c++)^='t'^'l';
					c-=4;
				}
			}
			else
			{
				/* we assume DOS extensions are used
				with dual-files only! */
				/*
				* Case-preserving conversion of ".tfx" to ".sam"
				*/
				*tfxloc++; /* skip the dot */
				(*tfxloc++)^='t'^'s';
				(*tfxloc++)^='f'^'a';
				(*tfxloc++)^='x'^'m';
				tfxloc-=4;
			}
		}
	}
	else
	{
		usage(argv[0]);
		exit(2);
	}

/* ------- do all that MD5, magic and single-file header stuff ----------- */

	check_md5_and_headers(mfn);

/* ----------------------------------------------------------------------- */

	if ((x=load_tfmx(mfn,sfn))==1)
	{
		fprintf(stderr,"%s: load_tfmx failed\n",argv[0]);
		exit(1);
	}
	else if (x==2)
	{
		fprintf(stderr,"%s: Not an MDAT/TFMX file\n",c);
		exit(1);
	}

	if (blend) stereo=1;
	blend&=1;
	if (!(c=strrchr(mfn,'/'))) c=mfn; else c++;
	printf("Module: %s\n",c);

	if (printinfo)
	{
		for (x=0;x<6;x++) printf(">%40.40s\n",hdr.text[x]);
		puts("");

		printf("%d tracksteps at 0x%04x\n",num_ts,(hdr.trackstart<<2)+0x200);
		printf("%d patterns at 0x%04x\n",num_pat,(hdr.pattstart<<2)+0x200);
		printf("%d macros at 0x%04x\n",num_mac,(hdr.macrostart<<2)+0x200);
		for (x=0;x<31;x++)
			if (/*(hdr.start[x]!=hdr.end[x]) &&*/ (hdr.end[x]))
				printf("Song %2d: start %3x end %3x\n",x,ntohs(hdr.start[x]),ntohs(hdr.end[x]));

	}
	if (gubed)
	{
		do_debug();
		exit(0);
	}

	/* FIXME debug output */
	if (monkeyHack == 1)
	{
		printf("MONKEY ISLAND DETECTED\n");
	}

/* Now the song is fully loaded.  Everything is done but ntohl'ing the actual
pattern and macro data. The routines that use the data do it for themselves.*/
	if (toOutFile==1)
		open_sndfile();
	else
		open_snddev();
	TfmxInit();
	StartSong(songnum,0);
	x=0;
	x=30;
	hdb[0]=(struct Hdb){0,0x1C01,0x3200,0x15BE,
		&smplbuf[0x4],&smplbuf[0x4+0x1C42],
		0x40,3,&LoopOff,0,NULL};
	play_it();
	TfmxTakedown();
	return(0);
}
