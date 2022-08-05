
#include <cstdint>
//extern void DisplayError (char *, ...);

extern bool IsTagPresent (uint8_t *);
extern bool IsValidGSF (uint8_t *);
extern void setupSound();
extern int GSFRun(const char *);
extern void GSFClose() ;
extern bool EmulationLoop();

