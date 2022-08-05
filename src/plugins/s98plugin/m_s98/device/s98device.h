#include "s98types.h"

enum {
	S98DEVICETYPE_PSG_YM  = 1,
	S98DEVICETYPE_OPN  = 2,
	S98DEVICETYPE_OPN2 = 3,
	S98DEVICETYPE_OPNA = 4,
	S98DEVICETYPE_OPM  = 5,
	S98DEVICETYPE_OPLL = 6,
	S98DEVICETYPE_OPL  = 7,
	S98DEVICETYPE_OPL2 = 8,
	S98DEVICETYPE_OPL3 = 9,
	S98DEVICETYPE_PSG_AY = 15,
	S98DEVICETYPE_SNG  = 16,
	S98DEVICETYPE_NONE = 0
};

typedef Int32 Sample;

class S98DEVICEIF
{
public:
	virtual ~S98DEVICEIF() {};
	virtual void Init(Uint32 clock, Uint32 rate) = 0;
	virtual void Reset(void) = 0;
	virtual void SetReg(Uint32 addr, Uint32 data) = 0;
	virtual void Mix(Sample* buffer, int nsamples) = 0;
	virtual void Disable(void) = 0;
	virtual void SetPan(Uint32 pan) = 0;
};

S98DEVICEIF *CreateS98DevicePSG(bool);
S98DEVICEIF *CreateS98DeviceOPN(void);
S98DEVICEIF *CreateS98DeviceOPN2(void);
S98DEVICEIF *CreateS98DeviceOPNA(void);
S98DEVICEIF *CreateS98DeviceOPM(void);
S98DEVICEIF *CreateS98DeviceOPLL(void);
S98DEVICEIF *CreateS98DeviceSNG(void);
S98DEVICEIF *CreateS98DeviceOPL(void);
S98DEVICEIF *CreateS98DeviceOPL2(void);
S98DEVICEIF *CreateS98DeviceOPL3(void);
