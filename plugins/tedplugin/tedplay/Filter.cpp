#include <math.h>
#include "Filter.h"

Filter::Filter(unsigned int cutoffFrq, unsigned int sampleFrq, unsigned int order) : 
	order_((order >> 1) << 1),
	sampleFrq_(sampleFrq),
	windowTable_(0),
	sampleHistory_(0),
	precision_(12),
	mixingVolume(2.0)
{
#if 1
	setCutoffFrq(double(cutoffFrq)/double(sampleFrq));
#else
	setCutoffFrq(.000001);
#endif
}

void Filter::setCutoffFrq(double fc)
{
	fc_ = fc;
	reCalcWindowTable();
}

void Filter::setFilterOrder(unsigned int order)
{
	order_ = (order >> 1) << 1;
	reCalcWindowTable();
}

Filter::~Filter()
{
	delete [] windowTable_;
	delete [] sampleHistory_;
}


void Filter::reCalcWindowTable()
{
	int i;
	const double pi = 4 * atan(1.0);
	const double f = fc_;
	double gain = double(1 << precision_) - 1.0; // 4095.0
	double kernelSum = 0;
	
	// #intervals between time steps for resampling
	timeStep = 1U;

	windowTableSize = order_ * int(timeStep);
	int midorder = windowTableSize / 2;
	double *dblCoeffs = new double[windowTableSize + 1];

	if (sampleHistory_) delete [] sampleHistory_;
	sampleHistory_ = new int [windowTableSize + 1];

	if (windowTable_) delete [] windowTable_;
	windowTable_ = new int[windowTableSize + 1];

	// this is used for resampling
	for (i = 0; i < windowTableSize; i++) {
		double j = i - midorder;
		double x = pi * j / double(timeStep);

		// Blackman has better stop-band attenuation
		double blackman = 0.42 + 0.5 * cos(2 * x / double(windowTableSize)) 
			- 0.08*cos(4 * pi * j / double(windowTableSize));
		// Hamming has 20% faster roll-off
		double hamming = 0.54 + 0.46 * cos(2 * x / double(windowTableSize));
		// von Hann is in between
		double vonHann = 0.5 * (1.0 + cos(2 * x / double(windowTableSize)));
		// Blackman-Harris window
		double a0 = 0.35875, a1 = 0.48229, a2 = 0.14128, a3 = 0.01168;
		double blackmanHarris = a0 + a1 * cos(2 * x / double(windowTableSize)) 
			- a2 * cos(4 * x / double(windowTableSize))
			+ a3 * cos(6 * x / double(windowTableSize));

		double c = (j == 0) ? 2.0 * f : sin(2.0 * f * x ) / x;

		c *= vonHann;
		dblCoeffs[i] = c;
		kernelSum += c;
	}

	for (i = 0; i < windowTableSize; i++) {
		double rebasedCoeff = dblCoeffs[i] / kernelSum * gain * mixingVolume;
		windowTable_[i] = (int)(rebasedCoeff + 0.5);
		sampleHistory_[i] = 0;
	}
	// Now decrease filter order if side coeffs are zero...
	i = 0;
	while (0 == windowTable_[i] && i < midorder) i++;
	if (i) {
		int k;
		int drop = i;

		i = 0;
		for(k = drop; k <= midorder; k++, i++)
			windowTable_[i] = windowTable_[k];
		order_ = order_ - drop * 2;

		if (i > 1) {
			int *b = windowTable_ + i - 2;
			do {
				windowTable_[i] = *b--;
			} while (++i < order_);
		}
		midorder = (order_ - 1) / 2;
	}
	windowTableSize = order_ * int(timeStep);
	if (!windowTableSize) {
		windowTableSize = 1;
		windowTable_[0] = int(gain);
		windowTable_[1] = 0;
	}

	sampleBufPtr_ = 0;
	sampleBufMask_ = (midorder << 1) + 1;

	delete [] dblCoeffs;
}

void Filter::setMixingVolume(unsigned int vol)
{
	mixingVolume = vol;
	// FIXME?
	reCalcWindowTable();
};

short Filter::lowPass(short from)
{
	int i;
	int filteredSample = 0;

	int ptr = sampleBufPtr_;
	sampleBufPtr_ = (sampleBufPtr_ + 1) % windowTableSize;
	
	// store input sample to history ring buffer
	sampleHistory_[ptr] = int(from);
	// last coeff not used...
	i = windowTableSize - 1;
	//
	do {
		// convolve sample input with filter kernel
		filteredSample += sampleHistory_[ptr] * windowTable_[i];
		// get previous sample from ring buffer
		ptr -= 1;
		if (ptr < 0) 
			ptr += windowTableSize;
	} while (i--);
	short output = short(filteredSample >> precision_);
	return (short) output;
}
