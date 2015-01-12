#ifndef _SERIAL_H
#define _SERIAL_H

#include "SDL/SDL.h"

class CSerial {

protected:
	static unsigned int NrOfDevicesAttached;
    static CSerial *RootDevice;
    static CSerial *LastDevice;
	CSerial *PrevDevice;
    CSerial *NextDevice;
	char Name[16];
public:
	CSerial();
	~CSerial();
	CSerial(unsigned int DevNr);
	// State of IEC lines (bit 7 - DATA, bit 6 - CLK, bit 4 - ATN)
	static Uint8 Line[16];
	static void InitPorts();
	Uint8 ReadBus();
	Uint32 DeviceNr;
	virtual void UpdateSerialState(Uint8 ) { };
	//virtual void ReadSerialState(Uint8 ) { };
	static class CSerial *Devices[16];

	friend class TEDMEM;
};

// class for not real devices (printer)
class CRealSerialIEC : public CSerial {
	virtual void NewSerialState(Uint8 Clk);
};

class IEC;

// class for not real devices (printer)
class CFakeSerialIEC : public CSerial {
	virtual void NewSerialState(Uint8 Clk);
	IEC *iec;
};

// class for true serial drive emulation
class CTrueSerialIEC : public CSerial {
	virtual void NewSerialState(Uint32 Clk);
};

#endif // _SERIAL_H

