// ---------------------------------------------------------------------------
//	OPN/A/B interface with ADPCM support
//	Copyright (C) cisc 1998, 2003.
// ---------------------------------------------------------------------------
//	$Id: opna.h,v 1.33 2003/06/12 13:14:37 cisc Exp $

#ifndef FM_OPNA_H
#define FM_OPNA_H

#include "fmgen.h"
#include "fmtimer.h"
#include "psg.h"

// ---------------------------------------------------------------------------
//	class OPN/OPNA
//	OPN/OPNA �ɗǂ��������𐶐����鉹�����j�b�g
//	
//	interface:
//	bool Init(uint clock, uint rate, bool, const char* path);
//		����D���̃N���X���g�p����O�ɂ��Ȃ炸�Ă�ł������ƁD
//		OPNA �̏ꍇ�͂��̊֐��Ń��Y���T���v����ǂݍ���
//
//		clock:	OPN/OPNA/OPNB �̃N���b�N��g��(Hz)
//
//		rate:	�������� PCM �̕W�{��g��(Hz)
//
//		path:	���Y���T���v���̃p�X(OPNA �̂ݗL��)
//				�ȗ����̓J�����g�f�B���N�g������ǂݍ���
//				������̖����ɂ� '\' �� '/' �Ȃǂ����邱��
//
//		�Ԃ�l	����ɐ�������� true
//
//	bool LoadRhythmSample(const char* path)
//		(OPNA ONLY)
//		Rhythm �T���v����ǂݒ����D
//		path �� Init �� path �Ɠ����D
//		
//	bool SetRate(uint clock, uint rate, bool)
//		�N���b�N�� PCM ���[�g��ύX����
//		���� Init ���Q�Ƃ̂��ƁD
//	
//	void Mix(FM_SAMPLETYPE* dest, int nsamples)
//		Stereo PCM �f�[�^�� nsamples ���������C dest �Ŏn�܂�z���
//		������(���Z����)
//		�Edest �ɂ� sample*2 ���̗̈悪�K�v
//		�E�i�[�`���� L, R, L, R... �ƂȂ�D
//		�E�����܂ŉ��Z�Ȃ̂ŁC���炩���ߔz����[���N���A����K�v������
//		�EFM_SAMPLETYPE �� short �^�̏ꍇ�N���b�s���O���s����.
//		�E���̊֐��͉��������̃^�C�}�[�Ƃ͓Ɨ����Ă���D
//		  Timer �� Count �� GetNextEvent �ő��삷��K�v������D
//	
//	void Reset()
//		���������Z�b�g(����)����
//
//	void SetReg(uint reg, uint data)
//		�����̃��W�X�^ reg �� data ����������
//	
//	uint GetReg(uint reg)
//		�����̃��W�X�^ reg �̓��e��ǂݏo��
//		�ǂݍ��ނ��Ƃ��o���郌�W�X�^�� PSG, ADPCM �̈ꕔ�CID(0xff) �Ƃ�
//	
//	uint ReadStatus()/ReadStatusEx()
//		�����̃X�e�[�^�X���W�X�^��ǂݏo��
//		ReadStatusEx �͊g���X�e�[�^�X���W�X�^�̓ǂݏo��(OPNA)
//		busy �t���O�͏�� 0
//	
//	bool Count(uint32 t)
//		�����̃^�C�}�[�� t [�ʕb] �i�߂�D
//		�����̓�����Ԃɕω�����������(timer �I�[�o�[�t���[)
//		true ��Ԃ�
//
//	uint32 GetNextEvent()
//		�����̃^�C�}�[�̂ǂ��炩���I�[�o�[�t���[����܂łɕK�v��
//		����[�ʕb]��Ԃ�
//		�^�C�}�[����~���Ă���ꍇ�� ULONG_MAX ��Ԃ��c �Ǝv��
//	
//	void SetVolumeFM(int db)/SetVolumePSG(int db) ...
//		�e�����̉��ʂ��{�|���ɒ��߂���D�W���l�� 0.
//		�P�ʂ͖� 1/2 dB�C�L��͈͂̏���� 20 (10dB)
//
namespace FM
{
	//	OPN Base -------------------------------------------------------
	class OPNBase : public Timer
	{
	public:
		OPNBase();
		
		bool	Init(uint c, uint r);
		virtual void Reset();
		
		void	SetVolumeFM(int db);
		void	SetVolumePSG(int db);
		void	SetLPFCutoff(uint freq) {}	// obsolete

	protected:
		void	SetParameter(Channel4* ch, uint addr, uint data);
		void	SetPrescaler(uint p);
		void	RebuildTimeTable();
		
		int		fmvolume;
		
		uint	clock;				// OPN �N���b�N
		uint	rate;				// FM �����������[�g
		uint	psgrate;			// FMGen  �o�̓��[�g
		uint	status;
		Channel4* csmch;
		

		static  uint32 lfotable[8];
	
	private:
		void	TimerA();
		uint8	prescale;
		
	protected:
		Chip	chip;
		PSG		psg;
	};

	//	OPN2 Base ------------------------------------------------------
	class OPNABase : public OPNBase
	{
	public:
		OPNABase();
		~OPNABase();
		
		uint	ReadStatus() { return status & 0x03; }
		uint	ReadStatusEx();
		void	SetChannelMask(uint mask);
	
	private:
		virtual void Intr(bool) {}

		void	MakeTable2();
	
	protected:
		bool	Init(uint c, uint r, bool);
		bool	SetRate(uint c, uint r, bool);

		void	Reset();
		void 	SetReg(uint addr, uint data);
		void	SetADPCMBReg(uint reg, uint data);
		uint	GetReg(uint addr);	
	
	protected:
		void	FMMix(Sample* buffer, int nsamples);
		void 	Mix6(Sample* buffer, int nsamples, int activech);
		
		void	MixSubS(int activech, ISample**);
		void	MixSubSL(int activech, ISample**);

		void	SetStatus(uint bit);
		void	ResetStatus(uint bit);
		void	UpdateStatus();
		void	LFO();

		void	DecodeADPCMB();
		void	ADPCMBMix(Sample* dest, uint count);

		void	WriteRAM(uint data);
		uint	ReadRAM();
		int		ReadRAMN();
		int		DecodeADPCMBSample(uint);
		
	// FM �����֌W
		uint8	pan[6];
		uint8	fnum2[9];
		
		uint8	reg22;
		uint	reg29;		// OPNA only?
		
		uint	stmask;
		uint	statusnext;

		uint32	lfocount;
		uint32	lfodcount;
		
		uint	fnum[6];
		uint	fnum3[3];
		
	// ADPCM �֌W
		uint8*	adpcmbuf;		// ADPCM RAM
		uint	adpcmmask;		// �������A�h���X�ɑ΂���r�b�g�}�X�N
		uint	adpcmnotice;	// ADPCM �Đ��I�����ɂ��r�b�g
		uint	startaddr;		// Start address
		uint	stopaddr;		// Stop address
		uint	memaddr;		// �Đ����A�h���X
		uint	limitaddr;		// Limit address/mask
		int		adpcmlevel;		// ADPCM ����
		int		adpcmvolume;
		int		adpcmvol;
		uint	deltan;			// ��N
		int		adplc;			// ��g���ϊ��p�ϐ�
		int		adpld;			// ��g���ϊ��p�ϐ������l
		uint	adplbase;		// adpld �̌�
		int		adpcmx;			// ADPCM �����p x
		int		adpcmd;			// ADPCM �����p ��
		int		adpcmout;		// ADPCM ������̏o��
		int		apout0;			// out(t-2)+out(t-1)
		int		apout1;			// out(t-1)+out(t)

		uint	adpcmreadbuf;	// ADPCM ���[�h�p�o�b�t�@
		bool	adpcmplay;		// ADPCM �Đ���
		int8	granuality;		
		bool	adpcmmask_;

		uint8	control1;		// ADPCM �R���g���[�����W�X�^�P
		uint8	control2;		// ADPCM �R���g���[�����W�X�^�Q
		uint8	adpcmreg[8];	// ADPCM ���W�X�^�̈ꕔ��

		int		rhythmmask_;

		Channel4 ch[6];

		uint8 ch6dac_enable;
		uint8 ch6dac_disable;

		static void	BuildLFOTable();
		static int amtable[FM_LFOENTS];
		static int pmtable[FM_LFOENTS];
		static int32 tltable[FM_TLENTS+FM_TLPOS];
		static bool	tablehasmade;

	};

	//	YM2203(OPN) ----------------------------------------------------
	class OPN : public OPNBase
	{
	public:
		OPN();
		virtual ~OPN() {}
		
		bool	Init(uint c, uint r, bool=false, const char* =0);
		bool	SetRate(uint c, uint r, bool=false);
		
		void	Reset();
		void 	Mix(Sample* buffer, int nsamples);
		void 	SetReg(uint addr, uint data);
		uint	GetReg(uint addr);
		uint	ReadStatus() { return status & 0x03; }
		uint	ReadStatusEx() { return 0xff; }
		
		void	SetChannelMask(uint mask);
		void	SetPan(uint pan);
		
		int		dbgGetOpOut(int c, int s) { return ch[c].op[s].dbgopout_; }
		int		dbgGetPGOut(int c, int s) { return ch[c].op[s].dbgpgout_; }
		Channel4* dbgGetCh(int c) { return &ch[c]; }
	
	private:
		virtual void Intr(bool) {}
		
		void	SetStatus(uint bit);
		void	ResetStatus(uint bit);
		
		uint	fnum[3];
		uint	fnum3[3];
		uint8	fnum2[6];
		
		Channel4 ch[3];
		uint8	pan;
	};

	//	YM2608(OPNA) ---------------------------------------------------
	class OPNA : public OPNABase
	{
	public:
		OPNA();
		virtual ~OPNA();
		
		bool	Init(uint c, uint r, bool  = false, const char* rhythmpath=0);
		bool	LoadRhythmSample(const char*);
	
		bool	SetRate(uint c, uint r, bool = false);
		void 	Mix(Sample* buffer, int nsamples);

		void	Reset();
		void 	SetReg(uint addr, uint data);
		uint	GetReg(uint addr);

		void	SetVolumeADPCM(int db);
		void	SetVolumeRhythmTotal(int db);
		void	SetVolumeRhythm(int index, int db);

		uint8*	GetADPCMBuffer() { return adpcmbuf; }

		int		dbgGetOpOut(int c, int s) { return ch[c].op[s].dbgopout_; }
		int		dbgGetPGOut(int c, int s) { return ch[c].op[s].dbgpgout_; }
		Channel4* dbgGetCh(int c) { return &ch[c]; }

		
	private:
		struct Rhythm
		{
			uint8	pan;		// �ς�
			int8	level;		// �����傤
			int		volume;		// �����傤�����Ă�
			int16*	sample;		// ����Ղ�
			uint	size;		// ������
			uint	pos;		// ����
			uint	step;		// ���Ă��Ղ�
			uint	rate;		// ����Ղ�̂�[��
		};
	
		void	RhythmMix(Sample* buffer, uint count);

	// ���Y�������֌W
		Rhythm	rhythm[6];
		int8	rhythmtl;		// ���Y���S�̂̉���
		int		rhythmtvol;		
		uint8	rhythmkey;		// ���Y���̃L�[
	};

	//	YM2610/B(OPNB) ---------------------------------------------------
	class OPNB : public OPNABase
	{
	public:
		OPNB();
		virtual ~OPNB();
		
		bool	Init(uint c, uint r, bool = false,
					 uint8 *_adpcma = 0, int _adpcma_size = 0,
					 uint8 *_adpcmb = 0, int _adpcmb_size = 0);
	
		bool	SetRate(uint c, uint r, bool = false);
		void 	Mix(Sample* buffer, int nsamples);

		void	Reset();
		void 	SetReg(uint addr, uint data);
		uint	GetReg(uint addr);
		uint	ReadStatusEx();

		void	SetVolumeADPCMATotal(int db);
		void	SetVolumeADPCMA(int index, int db);
		void	SetVolumeADPCMB(int db);

//		void	SetChannelMask(uint mask);
		
	private:
		struct ADPCMA
		{
			uint8	pan;		// �ς�
			int8	level;		// �����傤
			int		volume;		// �����傤�����Ă�
			uint	pos;		// ����
			uint	step;		// ���Ă��Ղ�

			uint	start;		// �J�n
			uint	stop;		// �I��
			uint	nibble;		// ���� 4 bit
			int		adpcmx;		// �ϊ��p
			int		adpcmd;		// �ϊ��p
		};
	
		int		DecodeADPCMASample(uint);
		void	ADPCMAMix(Sample* buffer, uint count);
		static void InitADPCMATable();
		
	// ADPCMA �֌W
		uint8*	adpcmabuf;		// ADPCMA ROM
		int		adpcmasize;
		ADPCMA	adpcma[6];
		int8	adpcmatl;		// ADPCMA �S�̂̉���
		int		adpcmatvol;		
		uint8	adpcmakey;		// ADPCMA �̃L�[
		int		adpcmastep;
		uint8	adpcmareg[32];
 
		static int jedi_table[(48+1)*16];

		Channel4 ch[6];
	};

	//	YM2612/3438(OPN2) ----------------------------------------------------
	class OPN2 : public OPNABase
	{
	public:
		OPN2();
		virtual ~OPN2();
		
		bool	Init(uint c, uint r, bool=false, const char* =0);
		bool	SetRate(uint c, uint r, bool);
		
		void	Reset();
		void 	Mix(Sample* buffer, int nsamples);
		void 	SetReg(uint addr, uint data);
		uint	GetReg(uint addr);
		uint	ReadStatus() { return status & 0x03; }
		uint	ReadStatusEx() { return 0xff; }
		
		void	SetChannelMask(uint mask);
		void	SetVolumePCM(int db);
		
		void 	PCMMix(Sample* dest, uint count);
		
	private:
		virtual void Intr(bool) {}

		Channel4 ch[6];

	// OPN2 ch6 DAC
		uint8 *ch6dac_fifo;
		uint32 ch6dac_ptr;
		uint32 ch6dac_vol;
		uint8 ch6dac_pan;
		uint8 ch6dac_data;
		bool ch6dac_interpolation;

	};
}

// ---------------------------------------------------------------------------

inline void FM::OPNBase::RebuildTimeTable()
{
	int p = prescale;
	prescale = -1;
	SetPrescaler(p);
}

inline void FM::OPNBase::SetVolumePSG(int db)
{
	psg.SetVolume(db);
}

#endif // FM_OPNA_H
