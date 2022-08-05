//extern "C" {
#include "mame/driver.h"
#include "mame/fmopl.h"
#include "mame/ymf262.h"
//}
#include "s98device.h"

using namespace mame;

class S98DEVICE_OPL2 : public S98DEVICEIF {
public:
	S98DEVICE_OPL2(void);
	~S98DEVICE_OPL2();

	void Init(Uint32 clock, Uint32 rate);
	void Reset(void);
	void SetReg(Uint32 addr, Uint32 data);
	void SetPan(Uint32 pan);
	void Mix(Sample* buffer, int nsamples);
	void Disable(void);

private:
	Uint32 uPan;
	bool bEnable;
	void *ifp;
};

class S98DEVICE_OPL3 : public S98DEVICEIF {
public:
	S98DEVICE_OPL3(void);
	~S98DEVICE_OPL3();

	void Init(Uint32 clock, Uint32 rate);
	void Reset(void);
	void SetReg(Uint32 addr, Uint32 data);
	void SetPan(Uint32 pan);
	void Mix(Sample* buffer, int nsamples);
	void Disable(void);

private:
	bool bEnable;
	void *ifp;
};

S98DEVICE_OPL2::S98DEVICE_OPL2(void) :
ifp(NULL)
{
	Disable();
}

S98DEVICE_OPL2::~S98DEVICE_OPL2()
{
	if (ifp) ::YM3812Shutdown(ifp);
}

void S98DEVICE_OPL2::Mix(Sample *pBuffer, int numSamples)
{
	if (!bEnable || !ifp) return;
	OPLSAMPLE write_sample;
	while (numSamples) {
		::YM3812UpdateOne(ifp, &write_sample, 1);
		*(pBuffer++) += (uPan & 1) ? 0 : write_sample;
		*(pBuffer++) += (uPan & 2) ? 0 : write_sample;
		numSamples--;
	}
}


void S98DEVICE_OPL2::Reset(void)
{
	if (ifp)
	{
		YM3812ResetChip(ifp);
		// ägí£ÉÇÅ[ÉhOFF
		::YM3812Write(ifp, 0, 0x1);
		::YM3812Write(ifp, 1, 0x0);
	}
}

void S98DEVICE_OPL2::SetReg(Uint32 addr, Uint32 data)
{
	bEnable = true;
	if (ifp) {
		::YM3812Write(ifp, 0, addr);
		::YM3812Write(ifp, 1, data);
	}
}

void S98DEVICE_OPL2::SetPan(Uint32 pan)
{
	uPan = pan;
}

void S98DEVICE_OPL2::Init(Uint32 clock, Uint32 rate)
{
	if (!ifp) {
		ifp = ::YM3812Init(clock, rate);
	}
	Reset();
}

void S98DEVICE_OPL2::Disable(void)
{
	bEnable = false;
}

S98DEVICE_OPL3::S98DEVICE_OPL3(void) :
ifp(NULL)
{
	Disable();
}

S98DEVICE_OPL3::~S98DEVICE_OPL3()
{
	if (ifp) ::YMF262Shutdown(ifp);
}

void S98DEVICE_OPL3::Mix(Sample *pBuffer, int numSamples)
{
	if (!bEnable) return;

	OPL3SAMPLE *write_sample[4] = {NULL, NULL, NULL, NULL};
	OPL3SAMPLE oLeft1(0), oRight1(0), oLeft2(0), oRight2(0);
	write_sample[0]=&oLeft1;
	write_sample[1]=&oRight1;
	write_sample[2]=&oLeft2;
	write_sample[3]=&oRight2;
	while (numSamples) {
		::YMF262UpdateOne(ifp, write_sample, 1);
		*(pBuffer++) += oLeft1 + oLeft2;
		*(pBuffer++) += oRight1 + oRight2;
		numSamples--;
	}
}


void S98DEVICE_OPL3::Reset(void)
{
	if (ifp)
	{
		::YMF262ResetChip(ifp);
	}
}

void S98DEVICE_OPL3::SetReg(Uint32 addr, Uint32 data)
{
	bEnable = true;
	if (ifp) {
		::YMF262Write(ifp, 0, addr);
		::YMF262Write(ifp, 1, data);
	}
}

void S98DEVICE_OPL3::SetPan(Uint32 pan)
{
}

void S98DEVICE_OPL3::Init(Uint32 clock, Uint32 rate)
{
	if (!ifp) {
		ifp = ::YMF262Init(clock, rate);
	}
	Reset();
}

void S98DEVICE_OPL3::Disable(void)
{
	bEnable = false;
}

S98DEVICEIF *CreateS98DeviceOPL(void) { return new S98DEVICE_OPL2; }
S98DEVICEIF *CreateS98DeviceOPL2(void) { return new S98DEVICE_OPL2; }
S98DEVICEIF *CreateS98DeviceOPL3(void) { return new S98DEVICE_OPL3; }
