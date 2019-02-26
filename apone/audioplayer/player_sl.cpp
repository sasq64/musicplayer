
#include "player_sl.h"

#include <coreutils/log.h>

using namespace std;


void InternalPlayer::bqPlayerCallback(SLAndroidSimpleBufferQueueItf bq, void *context)
{
	auto *p = (InternalPlayer*)context;
	if(!p->paused) {
		p->callback(&p->buffer[0], 32768);
		(*(p->bqPlayerBufferQueue))->Enqueue(p->bqPlayerBufferQueue, &p->buffer[0], 32768*2);
	//notifyThreadLock(p->outlock);
	}
}

void InternalPlayer::init() {
	unsigned int freq = 44100;
	unsigned int channels = 2;

	LOGD("SOUND INIT");

	auto result = slCreateEngine(&engineObject, 0, nullptr, 0, nullptr, nullptr);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");
	result = (*engineObject)->Realize(engineObject, SL_BOOLEAN_FALSE);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");
	result = (*engineObject)->GetInterface(engineObject, SL_IID_ENGINE, &engineEngine);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	SLDataLocator_AndroidSimpleBufferQueue loc_bufq = { SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, 2 };

	const SLInterfaceID ids[] = {SL_IID_VOLUME};
	const SLboolean req[] = {SL_BOOLEAN_FALSE};
	result = (*engineEngine)->CreateOutputMix(engineEngine, &outputMixObject, 1, ids, req);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	result = (*outputMixObject)->Realize(outputMixObject, SL_BOOLEAN_FALSE);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");
   
	unsigned int speakers = SL_SPEAKER_FRONT_CENTER;
	if(channels > 1) 
		speakers = SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT;

	SLDataFormat_PCM format_pcm = {SL_DATAFORMAT_PCM, channels, freq * 1000,
				SL_PCMSAMPLEFORMAT_FIXED_16, SL_PCMSAMPLEFORMAT_FIXED_16,
				speakers, SL_BYTEORDER_LITTLEENDIAN};

	SLDataSource audioSrc = {&loc_bufq, &format_pcm};

	// configure audio sink
	SLDataLocator_OutputMix loc_outmix = {SL_DATALOCATOR_OUTPUTMIX, outputMixObject};
	SLDataSink audioSnk = {&loc_outmix, NULL};

	// create audio player
	const SLInterfaceID ids1[] = {SL_IID_ANDROIDSIMPLEBUFFERQUEUE};
	const SLboolean req1[] = {SL_BOOLEAN_TRUE};
	result = (*engineEngine)->CreateAudioPlayer(engineEngine, &bqPlayerObject, &audioSrc, &audioSnk, 1, ids1, req1);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	// realize the player
	result = (*bqPlayerObject)->Realize(bqPlayerObject, SL_BOOLEAN_FALSE);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	// get the play interface
	result = (*bqPlayerObject)->GetInterface(bqPlayerObject, SL_IID_PLAY, &bqPlayerPlay);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	// get the buffer queue interface
	result = (*bqPlayerObject)->GetInterface(bqPlayerObject, SL_IID_ANDROIDSIMPLEBUFFERQUEUE, &bqPlayerBufferQueue);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	// register callback on the buffer queue
	result = (*bqPlayerBufferQueue)->RegisterCallback(bqPlayerBufferQueue, bqPlayerCallback, this);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	// set the player's state to playing
	result = (*bqPlayerPlay)->SetPlayState(bqPlayerPlay, SL_PLAYSTATE_PLAYING);
	if(result != SL_RESULT_SUCCESS) throw sl_exception("failed");

	LOGD("SOUND CALLING");

	buffer.resize(32768);
	callback(&buffer[0], 32768);
	(*bqPlayerBufferQueue)->Enqueue(bqPlayerBufferQueue, &buffer[0], 32768*2);

}

//void AudioPlayer::write(uint16_t *data, int len) {
//	(*bqPlayerBufferQueue)->Enqueue(bqPlayerBufferQueue, data, len*sizeof(short));
//}
