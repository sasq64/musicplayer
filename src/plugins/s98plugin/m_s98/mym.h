/* MYM file header */
#define MYM_MAGIC_V0	(0x4D594D30)	/* 'MYM0' */
#define MYM_MAGIC_V1	(0x4D594D31)	/* 'MYM1' */
#define MYM_MAGIC_VC	(0x4D594D43)	/* 'MYMC' */

static uint8_t *mym2s98(uint8_t *ps, uint32_t slen, uint32_t *pdlen)
{
	uint32_t spos = 0, dpos = 0x40, psloop;
	uint8_t *pd;
#ifdef X1F_MAGIC
	if ((GetDwordBE(ps) & 0xFFFFFF00) == X1F_MAGIC)
	{
		return x1f2s98(ps, slen, pdlen);
	}
#endif
	/* 150%(worst case) */
	pd = (uint8_t *)malloc(dpos + ((slen + slen + slen) >> 1) + 1);
	if (!pd) return 0;
	XMEMSET(pd, 0, dpos);
	SetDwordBE(pd + S98_OFS_MAGIC, S98_MAGIC_V2);
	SetDwordLE(pd + S98_OFS_OFSDATA, dpos);
	SetDwordLE(pd + S98_OFS_DEVICEINFO, S98DEVICETYPE_OPM);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 4, 3579545);
	if (GetDwordBE(ps) == MYM_MAGIC_V0 || GetDwordBE(ps) == MYM_MAGIC_V1)
	{
		SetDwordLE(pd + S98_OFS_TIMER_INFO1, ps[5] ? ps[5] : 1);
		SetDwordLE(pd + S98_OFS_TIMER_INFO2, 120 * (Uint32)(ps[7] ? ps[7] : 1));
		psloop = (((Uint32)ps[9]) << 24) + (((Uint32)ps[11]) << 16) + (((Uint32)ps[13]) << 8) + ((Uint32)ps[15]);
		spos += 16;
	}
	else
	{
		SetDwordLE(pd + S98_OFS_TIMER_INFO1, 1);
		SetDwordLE(pd + S98_OFS_TIMER_INFO2, 60);
		psloop = 0;
	}
	if (GetDwordBE(&ps[spos]) == MYM_MAGIC_VC)
	{
		SetDwordLE(pd + S98_OFS_DEVICEINFO + 4, (((Uint32)ps[spos + 5]) << 24) + (((Uint32)ps[spos + 7]) << 16) + (((Uint32)ps[spos + 9]) << 8) + ((Uint32)ps[spos + 11]));
		spos += 12;
	}
	while (spos < slen)
	{
		if (psloop == spos)
		{
			if (psloop) SetDwordLE(pd + S98_OFS_OFSLOOP, dpos);
		}
		switch(ps[spos]) {
		  case 0:
			pd[dpos++] = 0xff;
			spos++;
			break;
#if 0
		  case 6: {
			spos++;
			switch(ps[spos]) {
			  case 8:	// ADPCM
			  case 9:	// PCM8
				if (ps[spos] != 5) break;
				spos++;
				int ch = ps[spos++];
				if (ch < 0) {
					// status change
					if (ps[spos] != 5) break;
					spos+=2;
				} else {
					if (ps[spos] != 5) break;
					spos++;
					switch(ps[spos]) {
					  case 0: // stop
						spos++;
						break;
					  default: // play
						spos++;
						if (ps[spos] != 5) break;
						spops+=2;
						break;
					}
				}
				break;
			  case 10:	// LOOP END
				pd[dpos++] = 0xfd;
				spos = slen;
				break;
			  default:
			    spos++;
				break;
			}
			break;
		  }
#endif
		  default:
			pd[dpos++] = 0;
			pd[dpos++] = ps[spos++];
			pd[dpos++] = ps[spos++];
			break;
		}
	}
	pd[dpos++] = 0xfd;
	*pdlen = dpos;
	return pd;
}
