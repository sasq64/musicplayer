
//extern void DisplayError (char *, ...);

extern BOOL IsTagPresent (BYTE *);
extern BOOL IsValidGSF (BYTE *);
extern void setupSound(void);
extern int GSFRun(const char *);
extern void GSFClose(void) ;
extern BOOL EmulationLoop(void);

