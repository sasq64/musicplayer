
#define	LOCAL_LOG

#include "m_s98.h"
#include "net_autch_android_s98droid_MS98NativeInterface.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#ifdef	LOCAL_LOG
#include <android/log.h>
#endif

static s98File* theFile = NULL; // THE s98 file
// PMDWin instance is at pmdwin.cpp


/*
 * Class:     net_autch_android_s98droid_MS98NativeInterface
 * Method:    ms98Init
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_net_autch_android_s98droid_MS98NativeInterface_ms98Init
  (JNIEnv *, jclass)
{
}

/*
 * Class:     net_autch_android_s98droid_MS98NativeInterface
 * Method:    ms98Deinit
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_net_autch_android_s98droid_MS98NativeInterface_ms98Deinit
  (JNIEnv *, jclass)
{
	if(theFile != NULL) {
		delete theFile;
		theFile = NULL;
	}
}

int load_s98(const char* cszFileName)
{
	uint32_t bytes_read;
	uint8_t *Buffer = 0;
	int fd = -1, ret = 0;
	struct stat stat_buf;
	do
	{
		fd = ::open(cszFileName, O_RDONLY);
		if (fd < 0) break;
		fstat(fd, &stat_buf);
		if (stat_buf.st_size < 4) break;
		Buffer = new uint8_t[stat_buf.st_size];
		if (!Buffer) break;
		if ((bytes_read = ::read(fd, Buffer, stat_buf.st_size)) < 0) break;
		if (stat_buf.st_size != bytes_read) break;

		if(theFile != NULL) {
			delete theFile;
			theFile = NULL;
		}

		theFile = new s98File;
		if(theFile == NULL) break;
		if(!theFile->OpenFromBuffer(Buffer, bytes_read)) break;
		ret = 1;
	} while (0);
	if (Buffer) delete [] Buffer;
	if (fd != -1) ::close(fd);
	return ret;
}

/*
 * Class:     net_autch_android_s98droid_MS98NativeInterface
 * Method:    ms98OpenFile
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_net_autch_android_s98droid_MS98NativeInterface_ms98OpenFile
  (JNIEnv* env, jclass klass, jstring filename)
{
	int ret = 0;

	if(filename == NULL) return 0;

	const char* cszFileName = env->GetStringUTFChars(filename, NULL);
	char* pPeriod;


	pPeriod = strrchr(cszFileName, '.');
	if(pPeriod == NULL) {
		env->ReleaseStringUTFChars(filename, cszFileName);
		return 0;
	}

	if(strcmp(pPeriod, ".s98") == 0 || strcmp(pPeriod, ".S98") == 0) {
		// this may be a s98
		ret = load_s98(cszFileName);
	}
	env->ReleaseStringUTFChars(filename, cszFileName);
	return ret;
}

/*
 * Class:     net_autch_android_s98droid_MS98NativeInterface
 * Method:    ms98Render
 * Signature: ([BI)I
 */
JNIEXPORT jint JNICALL Java_net_autch_android_s98droid_MS98NativeInterface_ms98Render
  (JNIEnv *env, jclass klass, jbyteArray jbuffer, jint size)
{
	jbyte* buffer = env->GetByteArrayElements(jbuffer, NULL);
	jint ret;

	if(theFile == NULL) return 0;
	memset(buffer, 0, size);
	ret = theFile->Write((Int16*)buffer, (uint32_t)(size / 4)) * 4;

	env->ReleaseByteArrayElements(jbuffer, buffer, 0);

	return ret;
}

/*
 * Class:     net_autch_android_s98droid_MS98NativeInterface
 * Method:    ms98Close
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_net_autch_android_s98droid_MS98NativeInterface_ms98Close
  (JNIEnv *, jclass)
{
	if(theFile != NULL) {
		delete theFile;
		theFile = NULL;
	}
}

