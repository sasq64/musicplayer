/* X1F file header */
#define X1F_MAGIC		(0x58314600)	/* 'X1F\0' */

static uint8_t *x1f2s98(uint8_t *ps, uint32_t slen, uint32_t *pdlen)
{
	uint32_t spos = 0, dpos = 0x80, psloop = 0;
	uint8_t psgreg = 0;
	uint8_t *pd;
	if ((GetDwordBE(ps) & 0xFFFFFF00) != X1F_MAGIC) return 0;
	/* 150%(worst case) */
	pd = (uint8_t *)malloc(dpos + 1024 + ((slen + slen + slen) >> 1) + 1);
	if (!pd) return 0;
	XMEMSET(pd, 0, dpos);
	SetDwordBE(pd + S98_OFS_MAGIC, S98_MAGIC_V2);
	SetDwordLE(pd + S98_OFS_TIMER_INFO1, 1);
	SetDwordLE(pd + S98_OFS_TIMER_INFO2, 60);
	SetDwordLE(pd + S98_OFS_OFSDATA, dpos);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x00, S98DEVICETYPE_OPM);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x04, 4000000/*3579545*/);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x10, S98DEVICETYPE_PSG_YM);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x14, 4000000/*3579545*/);
	for (spos = 4; spos < 256; spos++)
	{
		pd[dpos++] = 0;
		pd[dpos++] = (uint8_t)spos;
		pd[dpos++] = ps[spos];
	}
	while (spos < slen)
	{
		if (psloop == spos)
		{
			if (psloop) SetDwordLE(pd + S98_OFS_OFSLOOP, dpos);
		}
		switch (ps[spos + 1])
		{
			case 0:
				{
					Uint32 wait = ps[spos + 0];
					if (wait)
					{
						spos += 2;
					} else {
						wait = (((Uint32)ps[spos + 3]) << 8) + ps[spos + 2];
						spos += 4;
					}
					if (wait == 1)
					{
						pd[dpos++] = 0xff;
					}
					else if (wait == 2)
					{
						pd[dpos++] = 0xff;
						pd[dpos++] = 0xff;
					}
					else if (wait > 2)
					{
						wait -= 2;
						pd[dpos++] = 0xfe;
						while (wait > 0x7f)
						{
							pd[dpos++] = (wait & 0x7f) + 0x80;
							wait >>= 7;
						}
						pd[dpos++] = wait & 0x7f;
					}
				}
				break;
			case 2:		// PSG register
				psgreg = ps[spos + 0];
				spos += 2;
				break;
			case 3:		// PSG data
				pd[dpos++] = 2;
				pd[dpos++] = psgreg;
				pd[dpos++] = ps[spos + 0];
				spos += 2;
				break;
			default:
				pd[dpos++] = 0;
				pd[dpos++] = ps[spos + 1];
				pd[dpos++] = ps[spos + 0];
				spos += 2;
				break;
		}
	}
	pd[dpos++] = 0xfd;
	*pdlen = dpos;
	return pd;
}
