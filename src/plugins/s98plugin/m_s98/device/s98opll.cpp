#include "emu2413/emu2413.h"
#include "s98device.h"

class S98DEVICE_OPLL : public S98DEVICEIF {

public:
	S98DEVICE_OPLL(void);
	~S98DEVICE_OPLL();

	void Init(Uint32 clock, Uint32 rate);
	void Reset(void);
	void SetReg(Uint32 addr, Uint32 data);
	void SetPan(Uint32 pan);
	void Mix(Sample* buffer, int nsamples);
	void Disable(void);

private:
	Uint32 uClock;
	Uint32 uFreq;
	bool bEnable;
	OPLL *ifp;
};

void S98DEVICE_OPLL::Mix(Sample *pBuffer, int numSamples)
{
	Int32 i;
	for (i = 0; i < numSamples; i++)
	{
		e_int16 d;
		d = (bEnable && ifp) ? OPLL_calc(ifp) << 1 : 0;
		*pBuffer++ += d;
		*pBuffer++ += d;
	}
}


void S98DEVICE_OPLL::Reset(void)
{
	if (ifp)
	{
		OPLL_reset(ifp);
		OPLL_reset_patch(ifp, 0);
	}
}

void S98DEVICE_OPLL::SetReg(Uint32 addr, Uint32 data)
{
	bEnable = true;
	if (ifp) OPLL_writeReg(ifp, addr, data);
}

void S98DEVICE_OPLL::SetPan(Uint32 pan)
{
	if (ifp)
	{
		for (int i=0; i  < 15; i++)
			OPLL_set_pan(ifp, i, ~pan & 3);
	}
}

void S98DEVICE_OPLL::Init(Uint32 clock, Uint32 rate)
{
	uClock = clock;
	uFreq = rate;

	if (ifp) OPLL_delete(ifp);
	ifp = OPLL_new(uClock, uFreq);
	if (ifp) OPLL_set_quality(ifp, 1);

	Reset();
}

void S98DEVICE_OPLL::Disable(void)
{
	bEnable = false;
}

S98DEVICE_OPLL::S98DEVICE_OPLL(void)
: uClock(3579545),ifp(NULL)
{
	Disable();
}

S98DEVICE_OPLL::~S98DEVICE_OPLL()
{
	if (ifp) OPLL_delete(ifp);
}

S98DEVICEIF *CreateS98DeviceOPLL(void) { return new S98DEVICE_OPLL; }
