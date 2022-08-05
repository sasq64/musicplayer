
static uint8_t *vgm2s98(uint8_t *ps, uint32_t slen, uint32_t *pdlen)
{
	uint32_t spos = 0x40, dpos = 0x80, psloop, clk, version, dbsize, dbtype,dbwork;
	uint8_t *pd, *dbd = 0;
	size_t dsize = dpos + (slen << 3) + 1;

	if (slen < spos) return 0;

	/* 300%(worst case) */
	pd = (uint8_t *)malloc(dsize);
	if (!pd) return 0;
	XMEMSET(pd, 0, dpos);

	version = GetDwordLE(ps + 0x08);
	SetDwordBE(pd + S98_OFS_MAGIC, S98_MAGIC_V2);
	SetDwordLE(pd + S98_OFS_TIMER_INFO1, 1);
	SetDwordLE(pd + S98_OFS_TIMER_INFO2, SAMPLE_RATE);
	SetDwordLE(pd + S98_OFS_OFSDATA, dpos);
	clk = GetDwordLE(ps + 0x0c);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x00, S98DEVICETYPE_SNG);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x04, clk ? clk : (53693175/15));
	clk = GetDwordLE(ps + 0x10);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x10, S98DEVICETYPE_OPLL);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x14, clk ? clk : (53693175/15));
	if (version >= 0x110) clk = GetDwordLE(ps + 0x2c);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x20, S98DEVICETYPE_OPN2);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x24, clk ? clk : (53693175/7));
	if (version >= 0x110) clk = GetDwordLE(ps + 0x30);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x30, S98DEVICETYPE_OPM);
	SetDwordLE(pd + S98_OFS_DEVICEINFO + 0x34, clk ? clk : 8000000);
	if (version >= 0x150) spos = GetDwordLE(ps + 0x34) + 0x34;

	psloop = GetDwordLE(ps + 0x1c);
	if (psloop) psloop += 0x1c;
	while (spos < slen && ps[spos] != 0x66)
	{
		Uint32 wait = 0;
		if (psloop && psloop == spos) SetDwordLE(pd + S98_OFS_OFSLOOP, dpos);
		switch (ps[spos])
		{
			case 0x4f:	/* GG stereo */
			case 0x50:	/* SNG */
				pd[dpos++] = 0;
				pd[dpos++] = 0x50 - ps[spos++];
				pd[dpos++] = ps[spos++];
				break;
			case 0x51:	/* OPLL */
				spos++;
				pd[dpos++] = 2;
				pd[dpos++] = ps[spos++];
				pd[dpos++] = ps[spos++];
				break;
			case 0x52:	/* OPN2 master */
			case 0x53:	/* OPN2 slave */
				pd[dpos++] = 4 + ps[spos++] - 0x52;
				pd[dpos++] = ps[spos++];
				pd[dpos++] = ps[spos++];
				break;
			case 0x54:	/* OPM */
				spos++;
				pd[dpos++] = 6;
				pd[dpos++] = ps[spos++];
				pd[dpos++] = ps[spos++];
				break;
			case 0x61:
			case 0x62:
			case 0x63:
			{
				switch (ps[spos++])
				{
				  case 0x61:
					wait += GetWordLE(ps + spos);
					spos += 2;
					break;
				  case 0x62:
					wait += 735;
					break;
				  case 0x63:
					wait += 882;
					break;
				  default:
					break;
				}
				break;
			}
			case 0x67:
				dbtype = ps[spos+2];
				dbwork = 0;
				dbsize = GetDwordLE(ps + spos + 3);
				spos += 7;
				dbd = ps + spos;
				spos += dbsize;
				break;
			case 0xe0:
				dbwork = GetDwordLE(ps + spos + 1);
				if (dbwork >= dbsize) dbwork = dbsize - 1;
				spos += 5;
				break;
			default:
			{
				switch(ps[spos] >> 4) {
				  case 3: case 4:
					spos += 2;
					break;
				  case 5:
					spos += 3;
					break;
				  case 7:
					wait += (ps[spos] & 0x0f) + 1;
					spos ++;
					break;
				  case 8:
					wait += (ps[spos] & 0x0f);
					if (dbd && dbtype == 0) {
						pd[dpos++] = 4;
						pd[dpos++] = 0x2a;
						pd[dpos++] = dbd[dbwork++];
						if (dbwork >= dbsize) dbwork = dbsize - 1;
					}
					spos ++;
					break;
				  case 0xa: case 0xb:
					spos += 4;
					break;
				  case 0xc: case 0xd:
					spos += 5;
					break;
				  case 0xe: case 0xf:
					spos += 6;
					break;
				  default:
					spos++;
					break;
				}
			}
		}
		if (wait)
		{
			if (wait == 1)
			{
				pd[dpos++] = 0xff;
			}
			else if (wait == 2) {
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
			wait = 0;
		}
		if (dpos >= (dsize - 8)) {
			free(pd);
			return 0;
		}
	}
	pd[dpos++] = 0xfd;
	*pdlen = dpos;
	return pd;
}
