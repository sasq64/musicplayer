#pragma once

class Filter
{
public:
	Filter(unsigned int cutoffFrq, unsigned int inputFrq, unsigned int order);
	virtual ~Filter();
	void setCutoffFrq(double fc);
	void setFilterOrder(unsigned int order);
	void reCalcWindowTable();
	short lowPass(short from);
	void setMixingVolume(unsigned int vol);
protected:
	int order_;
	int *windowTable_;
	int windowTableSize;
	int *sampleHistory_;
	unsigned int sampleBufPtr_;
	unsigned int sampleBufMask_;
	double fc_;
	unsigned int timeStep;
	unsigned int sampleFrq_;
	const unsigned int precision_;
	double mixingVolume;
};
