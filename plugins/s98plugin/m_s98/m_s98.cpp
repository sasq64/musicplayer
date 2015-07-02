#include <stdint.h>

#include "device/s98types.h"
#include "m_s98.h"

#define USE_ZLIB 1

#if USE_ZLIB
#include "zlib.h"
#endif

#define SUPPORT_VGM 1
#define SUPPORT_MYM 1

#define KMPMODULE_PLUGIN_VERSION    10
#define KMPMODULE_PLUGIN_NAME       "m_s98.kpi v1.0r8 by Mamiya"
#define KMPMODULE_PLUGIN_COPYRIGHT  "FM Sound Generator rel.008 (C) cisc 1998-2003. / emu2413 by Mitsutaka Okazaki 2001-2004 / zlib " ## ZLIB_VERSION ## " (C) 1995-2005 Jean-loup Gailly and Mark Adler"
#define KMPMODULE_REENTRANT 0

S98DEVICEIF *S98DeviceCreate(int type, int clock, int rate)
{
	S98DEVICEIF *ret = 0;
	switch (type)
	{
		case S98DEVICETYPE_PSG_YM:
			ret = CreateS98DevicePSG(true);
			break;
		case S98DEVICETYPE_PSG_AY:
			ret = CreateS98DevicePSG(false);
			break;
		case S98DEVICETYPE_OPN:
			ret = CreateS98DeviceOPN();
			break;
		case S98DEVICETYPE_OPN2:
			ret = CreateS98DeviceOPN2();
			break;
		case S98DEVICETYPE_OPNA:
			ret = CreateS98DeviceOPNA();
			break;
		case S98DEVICETYPE_OPM:
			ret = CreateS98DeviceOPM();
			break;
		case S98DEVICETYPE_OPLL:
			ret = CreateS98DeviceOPLL();
			break;
		case S98DEVICETYPE_SNG:
			ret = CreateS98DeviceSNG();
			break;
		case S98DEVICETYPE_OPL:
			ret = CreateS98DeviceOPL();
			break;
		case S98DEVICETYPE_OPL2:
			ret = CreateS98DeviceOPL2();
			break;
		case S98DEVICETYPE_OPL3:
			ret = CreateS98DeviceOPL3();
			break;
	}
	if (ret) ret->Init(clock, rate);
	return ret;
}

static void SetDwordLE(Uint8 *p, Uint32 v)
{
	p[0] = (v >> (8 * 0)) & 0xFF;
	p[1] = (v >> (8 * 1)) & 0xFF;
	p[2] = (v >> (8 * 2)) & 0xFF;
	p[3] = (v >> (8 * 3)) & 0xFF;
}
static void SetDwordBE(Uint8 *p, Uint32 v)
{
	p[0] = (v >> (8 * 3)) & 0xFF;
	p[1] = (v >> (8 * 2)) & 0xFF;
	p[2] = (v >> (8 * 1)) & 0xFF;
	p[3] = (v >> (8 * 0)) & 0xFF;
}
static Uint32 GetWordLE(Uint8 *p)
{
	int ret;
	ret  = ((Uint32)(Uint8)p[0]) << 0x00;
	ret |= ((Uint32)(Uint8)p[1]) << 0x08;
	return ret;
}
static Uint32 GetDwordLE(Uint8 *p)
{
	int ret;
	ret  = ((Uint32)(Uint8)p[0]) << 0x00;
	ret |= ((Uint32)(Uint8)p[1]) << 0x08;
	ret |= ((Uint32)(Uint8)p[2]) << 0x10;
	ret |= ((Uint32)(Uint8)p[3]) << 0x18;
	return ret;
}
static Uint32 GetDwordBE(Uint8 *p)
{
	Uint32 ret;
	ret  = ((Uint32)(Uint8)p[0]) << 0x18;
	ret |= ((Uint32)(Uint8)p[1]) << 0x10;
	ret |= ((Uint32)(Uint8)p[2]) << 0x08;
	ret |= ((Uint32)(Uint8)p[3]) << 0x00;
	return ret;
}


s98File::s98File()
{
	s98data = 0;
	number_of_devices = 0;
	memset(devices, 0, sizeof(devices));
}
s98File::~s98File()
{
	Close();
}

void s98File::CalcTime(void)
{
	uint8_t *p = s98top;
	looptime = 0;
	playtime = 0;
	if (!s98data) return;
	while (1)
	{
		if (p == s98loop) looptime = playtime;
		if (*p < 0x80)
		{
			p += 3;
		}
		else if (*p == 0xff)
		{
			playtime += 1;
			p += 1;
		}
		else if (*p == 0xfe)
		{
			int s = 0, n = 0;
			do
			{
				n |= (*(++p) & 0x7f) << s;
				s += 7;
			}
			while (*p & 0x80);
			playtime += n + 2;
			p += 1;
		}
		else
		{
			return;
		}
	}
}

static Uint32 DivFix(Uint32 p1, Uint32 p2, Uint32 fix)
{
	Uint32 ret;
	ret = p1 / p2;
	p1  = p1 % p2;/* p1 = p1 - p2 * ret; */
	while (fix--)
	{
		p1 += p1;
		ret += ret;
		if (p1 >= p2)
		{
			p1 -= p2;
			ret++;
		}
	}
	return ret;
}

void s98File::Reset(void)
{
	for (int d = 0; d < number_of_devices; d++)
		if (devices[d]) devices[d]->Reset();

#if FADEOUT_TIME
	loopcur = 0;
	fader = 0;
#endif

	s98cur = s98top;
	curtime = 0;

	lefthi = 0;
	leftlo = 0;
	Step();
}

void s98File::Step(void)
{
#if FADEOUT_TIME
	if (fader && ++fader >= FADEOUT_TIME)
	{
		lefthi = 0;
		for (int d = 0; d < number_of_devices; d++) if (devices[d]) devices[d]->Disable();
		return;
	}
#endif
	while (1)
	{
		if (*s98cur < 0x80)
		{
			int d = devicemap[*s98cur >> 1];
			if (d != S98DEVICE_MAX && devices[d])
			{
				if (*s98cur & 1)
					devices[d]->SetReg(0x100 | s98cur[1], s98cur[2]);
				else
					devices[d]->SetReg(s98cur[1], s98cur[2]);
			}
			s98cur += 3;
			continue;
		}
		if (*s98cur == 0xfe || *s98cur == 0xff) break;
		if (*s98cur == 0xfd && s98loop)
		{
			s98cur = s98loop;
#if FADEOUT_TIME
			if (loopnum && !fader &&  ++loopcur == loopnum) fader = 1;
#endif
			continue;
		}
		lefthi = 0;
		for (int d = 0; d < number_of_devices; d++) if (devices[d]) devices[d]->Disable();
		return;
	}
	while (1)
	{
		if (*s98cur == 0xff)
		{
			lefthi += 1;
			s98cur++;
		}
		else if (*s98cur == 0xfe)
		{
			int s = 0, n = 0;
			do
			{
				n |= (*(++s98cur) & 0x7f) << s;
				s += 7;
			} while (*s98cur & 0x80);
			lefthi += n + 2;
			s98cur++;
		}
		else
		{
			break;
		}
	}
	return;
}

uint32_t s98File::SyncToMsec(uint32_t sync)
{
	return (uint32_t)(((double)sync) * ((double)1000) / sync_per_sec);
}

uint32_t s98File::MsecToSync(uint32_t ms)
{
	return (uint32_t)(((double)ms) * sync_per_sec / ((double)1000));
}

uint32_t s98File::SetPosition(uint32_t dwpos_)
{
	if (!s98data) return 0;
	dwpos_ = MsecToSync(dwpos_);
/*
	char buf[1024];
	wsprintf(buf, "s98debug:%d:%d\n", dwpos_, curtime);
	OutputDebugString(buf);
*/
	if (dwpos_ < curtime)
	{
		Reset();
	}
	while (dwpos_ > curtime)
	{
		curtime++;
		if (lefthi && --lefthi == 0) Step();
	}
	return SyncToMsec(curtime);
}

#if SUPPORT_VGM
#include "vgm.h"
#endif
#if SUPPORT_MYM
#include "x1f.h"
#include "mym.h"
#endif
#include "tar.h"

static int default_sample_rate = SAMPLE_RATE;
static int default_loopnum = LOOPNUM;

bool s98File::OpenFromBuffer(const uint8_t *Buffer, uint32_t dwSize /*, SOUNDINFO *pInfo*/)
{
	int sample_rate = SAMPLE_RATE; //(pInfo->dwSamplesPerSec == 0) ? default_sample_rate : pInfo->dwSamplesPerSec;

	Close();

	uint32_t dataofs, loopofs;
	uint8_t *buf = 0;
	uint32_t length = dwSize;
	uint32_t magic = 0;

	do
	{
		if (length < 0x40) break;
		buf = (uint8_t *)malloc(length);
		if (!buf) break;
		XMEMCPY(buf, Buffer, length);
#if USE_ZLIB
		/* Uncompress GZIP */
		if (buf[0] == 0x1f && buf[1] == 0x8b)
		{
			uint8_t *des = 0;
			uint8_t *gzp;
			unsigned deslen = 4096;
			int z_err;
			z_stream zs;

			des = (uint8_t *)malloc(deslen);
			if (!des) break;

			XMEMSET(&zs, 0, sizeof(z_stream));

			gzp = buf + 10;
			if (buf[3] & 4)
			{
				uint32_t extra = *gzp++;
				extra += *gzp++ << 8;
				gzp += extra;
			}
			if (buf[3] & 8) while (*gzp++);
			if (buf[3] & 16) while (*gzp++);
			if (buf[3] & 2) gzp += 2;

			zs.next_in = gzp;
			zs.avail_in = length - (gzp - buf);
			zs.next_out = des;
			zs.avail_out = deslen;
			zs.zalloc = (alloc_func)0;
			zs.zfree = (free_func)0;
			zs.opaque = (voidpf)0;

			z_err = inflateInit2(&zs, -MAX_WBITS);
			if (z_err != Z_OK)
			{
				inflateEnd(&zs);
				break;
			}
			inflateReset(&zs);
			while (1)
			{
				z_err = inflate(&zs, Z_SYNC_FLUSH);
				if (z_err == Z_STREAM_END) break;
				if (z_err != Z_OK || zs.avail_in == 0)
				{
					free(des);
					des = 0;
					break;
				}
				if (zs.avail_out == 0)
				{
					uint8_t *p;
					p = (uint8_t *)realloc(des, deslen + 4096);
					if (!p)
					{
						free(des);
						des = 0;
						break;
					}
					des = p;
					zs.next_out = des + deslen;
					zs.avail_out += 4096;
					deslen += 4096;
				}
			};
			if (des)
			{
				free(buf);
				buf = des;
				length = zs.total_out;
			}
			inflateEnd(&zs);
			if (!des) break;
		}
#endif
		/* skip TAR header */
		s98head = buf;
		if (length >= 512)
		{
			uint32_t lentarheader = IsTarHeader(s98head);
			s98head += lentarheader;
			length -= lentarheader;
		}
		if (length < 0x40) break;
		magic = GetDwordBE(s98head + S98_OFS_MAGIC);
		if (S98_MAGIC_V0 <= magic && magic <= S98_MAGIC_VZ)
		{
			/* version check */
			if (S98_MAGIC_V3 < magic) break;
		}
#if SUPPORT_VGM
		else if (VGM_MAGIC == magic)
		{
			uint32_t cnvs98length;
			uint8_t *cnvs98;
			cnvs98 = vgm2s98(s98head, length, &cnvs98length);
			if (!cnvs98) break;
			free(buf);
			s98head = buf = cnvs98;
			length = cnvs98length;
		}
#endif
		else
		{
#if SUPPORT_MYM
			uint32_t cnvs98length;
			uint8_t *cnvs98;
			cnvs98 = mym2s98(s98head, length, &cnvs98length);
			if (!cnvs98) break;
			free(buf);
			s98head = buf = cnvs98;
			length = cnvs98length;
#else
			break;
#endif
		}
		loopofs = GetDwordLE(s98head + S98_OFS_OFSLOOP);
		dataofs = GetDwordLE(s98head + S98_OFS_OFSDATA);
		/* Uncompress internal deflate(old gimmick) */
		if (GetDwordLE(s98head + S98_OFS_COMPRESSING))
		{
#if !USE_ZLIB
			break;	/* NOT SUPPORT */
#else
			uLongf dessize;
			uint8_t *des;
			uint32_t compofs;
			if (S98_MAGIC_V2 == magic)
			{
				compofs = GetDwordLE(s98head + S98_OFS_OFSCOMP);
			}
			if (!compofs) compofs = dataofs;
			des = (uint8_t *)malloc(compofs + GetDwordLE(s98head + S98_OFS_COMPRESSING));
			if (!des) break;
			XMEMCPY(des, s98head, compofs);
			if (Z_OK != uncompress(&des[compofs], &dessize, s98head + compofs, length - compofs))
			{
				free(des);
				break;
			}
			length = dessize;
			s98head = des;
			s98data = des;
			s98top  = s98head + dataofs;
			s98loop = loopofs ? (s98head + loopofs) : 0;
			des = 0;
#endif
		}
		else
		{
			s98data = buf;
			s98top  = s98head + dataofs;
			s98loop = loopofs ? (s98head + loopofs) : 0;
			buf = 0;
		}
		/* if (length <= loopofs) s98loop = 0; */
	} while(0);
	if (buf) free(buf);

	if (!s98data) return false;

	timerinfo1 = GetDwordLE(s98head + S98_OFS_TIMER_INFO1);
	timerinfo2 = GetDwordLE(s98head + S98_OFS_TIMER_INFO2);
	if (timerinfo1 == 0) timerinfo1 = 10;
	if (timerinfo2 == 0) timerinfo2 = 1000;

	int d;
	for (d = 0; d < 0x40; d++) devicemap[d] = S98DEVICE_MAX;
	number_of_devices = 0;
	if ((S98_MAGIC_V3 != magic && !GetDwordLE(s98head + S98_OFS_DEVICEINFO)) ||
		(S98_MAGIC_V3 == magic && !GetDwordLE(s98head + S98_OFS_DEVICECOUNT)))
	{
		devices[0] = S98DeviceCreate(S98DEVICETYPE_OPNA, MASTER_CLOCK, sample_rate);
		if (devices[0])
		{
			devicemap[0] = 0;
			number_of_devices = 1;
		}
	}
	else
	{
		int devicemax = S98DEVICE_MAX;
		uint8_t *devinfo = s98head + S98_OFS_DEVICEINFO;
		if (S98_MAGIC_V3 == magic && GetDwordLE(s98head + S98_OFS_DEVICECOUNT))
		{
			devicemax = GetDwordLE(s98head + S98_OFS_DEVICECOUNT);
		}
		for (d = 0; d < devicemax; d++)
//		for (d = 0; d < devicemax && GetDwordLE(devinfo); d++)
		{
			devices[number_of_devices] = S98DeviceCreate(GetDwordLE(devinfo), GetDwordLE(devinfo + 4), sample_rate);
			if (devices[number_of_devices])
			{
				devicemap[d] = number_of_devices++;
				devices[d]->SetPan(GetDwordLE(devinfo + 8));
			} else {
				number_of_devices++;
			}
			devinfo += 16;
		}
	}

	double dsps;
	double sample_per_sec = (double)sample_rate;
	sync_per_sec = ((double)timerinfo2) / ((double)timerinfo1);
	if (sync_per_sec > sample_per_sec)
	{
		dsps = sample_per_sec / sync_per_sec;
		spsmode = SAMPLE_PER_SYNC;
	}
	else
	{
		dsps = sync_per_sec / sample_per_sec;
		spsmode = SYNC_PER_SAMPLE;
	}
	sps = (uint32_t)(dsps * (double)SPS_LIMIT);
	if (sps >= SPS_LIMIT)
	{
		sps = SPS_LIMIT;
		spsmode = SYNC_PER_SAMPLE;
	}
	/* �����_�ł͍��𑜓xS98�͑��݂��Ȃ� */
	if (spsmode == SAMPLE_PER_SYNC) return false;

	CalcTime();
	Reset();
	return true;
}

void s98File::Close(void)
{
	if (s98data) { free(s98data); s98data = 0; }
	for (int d = 0; d < number_of_devices; d++) if (devices[d]) delete devices[d];
	number_of_devices = 0;
}

void s98File::WriteSub(Int16 *Buffer, uint32_t numSample)
{
	uint32_t i, len;
	while (numSample)
	{
		len = (numSample > UNIT_RENDER) ? UNIT_RENDER : numSample;
		XMEMSET(bufdev, 0, len * 2 * sizeof(Sample));
		for (int d = 0; d < number_of_devices; d++)
			if (devices[d]) devices[d]->Mix(bufdev, len);
		for (i = 0; i < len * 2; i++)
		{
			Sample s;
			s = bufdev[i];
			if (((Uint32)(s + 0x8000)) > 0xffff)
			{
				s = (s > 0x7fff) ? 0x7fff : -0x8000;
			}
			*Buffer++ = (Int16)s; 
		}
		numSample -= len;
	}
}

uint32_t s98File::Write(Int16 *Buffer, uint32_t numSample)
{
	uint32_t pos, numWrite = 0;
	if (!s98data) return numWrite;
	if (numSample == 0) return numWrite;

	for (pos = 0; pos < numSample; pos++)
	{
		if (lefthi)
		{
			leftlo += sps;
			if (leftlo >= SPS_LIMIT)
			{
				leftlo -= SPS_LIMIT;
				lefthi -= 1;
				curtime += 1;
			}
			if (lefthi == 0)
			{
				if (Buffer) WriteSub(&Buffer[numWrite * 2], pos + 1 - numWrite);
				numWrite = pos + 1;
				Step();
				if (lefthi == 0) break;
			}
		}
	}
	if (/*lefthi && */numWrite != numSample)
	{
		if (Buffer) WriteSub(&Buffer[numWrite * 2], numSample - numWrite);
		numWrite = numSample;
	}
	return numWrite;
}
