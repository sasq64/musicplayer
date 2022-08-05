/*
  Linux 2SF player - main program
  Rewritten by Jesse N. Richardson

*/

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <termios.h>
#include <unistd.h>

#include "ao.h"
#include "corlett.h"
#include "vio2sf/vio2sf.h"

// Color Codes library file
#include "../color.h"

static uint8 *buffer; // buffer containing 2sf file
static uint32 size;   // size of buffer
static corlett_t *c = NULL;

char *xsf_tagget(const char *tag, const char *pData, int dwSize);


/* ao_get_lib: called to load secondary files */
int xsf_get_lib(char *filename, void **buffer, unsigned int *length)
{
  uint8 *filebuf;
  uint32 size;
  FILE *auxfile;

  auxfile = fopen(filename, "rb");
  if (!auxfile)
    {
      RED();
      printf("Unable to find auxiliary file %s\n", filename);
      NORMAL();
      return AO_FAIL;
    }

  fseek(auxfile, 0, SEEK_END);
  size = ftell(auxfile);
  fseek(auxfile, 0, SEEK_SET);

  filebuf = malloc(size);

  if (!filebuf)
    {
      fclose(auxfile);
      RED();
      printf("ERROR: could not allocate %d bytes of memory\n", size);
      NORMAL();
      return AO_FAIL;
    }

  fread(filebuf, size, 1, auxfile);
  fclose(auxfile);

  *buffer = filebuf;
  *length = (uint64)size;

  return AO_SUCCESS;
}

static void do_frame(uint32 size, int16 *buffer)
{
  xsf_gen(buffer, size);
}

// load and set up a 2sf file
int load_file(char *name)
{
  FILE *file;
  uint32 filesig;
  uint8 *filedata;
  uint64 file_len;

  file = fopen(name, "rb");

  if (!file)
    {
      RED();
      printf("ERROR: could not open file %s\n", name);
      NORMAL();
      return -1;
    }

  // get the length of the file by seeking to the end then reading the current
  // position
  fseek(file, 0, SEEK_END);
  size = ftell(file);
  // reset the pointer
  fseek(file, 0, SEEK_SET);

  buffer = malloc(size);

  if (!buffer)
    {
      fclose(file);
      RED();
      printf("ERROR: could not allocate %d bytes of memory\n", size);
      NORMAL();
      return -1;
    }

  // read the file
  fread(buffer, size, 1, file);
  fclose(file);

  // init our *SF engine so we can get tags
  if (corlett_decode(buffer, size, &filedata, &file_len, &c) != AO_SUCCESS)
    {
      RED();
      printf("ERROR: What the..!? I can't read these tags!\n");
      MAGENTA();
      printf("File I tried to load: %s\n", name);
      NORMAL();
      return -1;
    }
  free(filedata);	// we don't use this

  if (xsf_start(buffer, size) != XSF_TRUE)
    {
      RED();
      printf("ERROR: What the..!? I can't read this!\n");
      printf("File I tried to load: %s\n", name);
      NORMAL();
      return -1;
    }

  m1sdr_Init(44100);
  m1sdr_SetCallback(do_frame);
  m1sdr_PlayStart();

  if ((c != NULL) && (c->inf_title != NULL))
    {
      BOLD();
      //printf("Playing \"%s\" by %s from %s.  Copyright %s %s.\nFilename: %s\n", c->inf_title, c->inf_artist, c->inf_game, c->inf_copy, c->inf_year, name);
      printf("Playing \"%s\" by %s from %s.\n", c->inf_title, c->inf_artist, c->inf_game);
      printf("Copyright %s %s.\n", c->inf_copy, c->inf_year);
      printf("Filename: %s.\n", name);
      NONBOLDYELLOW();
      printf("----------------------------------------------------------------\n");
      NORMAL();
    }
  else
    {
      BOLD();
      printf("Playing %s\n", name);
      NORMAL();
    }

  return 0;
}

int main(int argv, char *argc[])
{
  struct termios tp;
  struct timeval tv;
  int fds;
  fd_set watchset;
  char ch = 0;
  int song;

  MAGENTA();
  //printf("VIO2SF Linux player version 3.3 (vio2sf 0.15)\n\n");
  printf("NDS Music Player for Linux\n");
  printf("Version 3.6\n");
  printf("Using vio2sf 0.15\n");
  NORMAL();
  // check if an argument was given
  if (argv < 2)
    {
      RED();
      printf("Error: must specify a filename or names!\n");
      NORMAL();
      return -1;
    }

  GREEN();
  printf("Press ESC or Q to stop. p = previous song, n = next song\n\n", argc[1]);
  NORMAL();

  if (load_file(argc[1]) < 0)
    {
      return -1;
    }

  tcgetattr(STDIN_FILENO, &tp);
  tp.c_lflag &= ~ICANON;
  tp.c_lflag &= ~(ECHO | ECHOCTL | ECHONL);
  tcsetattr(STDIN_FILENO, TCSANOW, &tp);

  ch = 0;
  song = 1;
  while ((ch != 27) && (ch != 'q') && (ch != 'Q'))
    {
      fds = STDIN_FILENO;
      FD_ZERO(&watchset);
      FD_SET(fds, &watchset);
      tv.tv_sec = 0;
      tv.tv_usec = 16666/2;	// timeout every 1/120th of a second
      if (select(fds+1, &watchset, NULL, NULL, &tv))
	{
	  ch = getchar();	// (blocks until something is pressed)
	}
      else
	{
	  ch = 0;
	}

      m1sdr_TimeCheck();

      // Added the ability to press the n key to goto the next song
      if ((ch == 'n') && ((song+1) < argv))
	{
	  xsf_term();
	  m1sdr_Exit();
	  if (c)
	    {
	      free(c);
	      c = NULL;
	    }
	  free(buffer);
	  song++;

	  if (load_file(argc[song]) < 0)
	    {
	      ch = 27;
	    }
	}

      if ((ch == 'p') && (song > 1))
	{
	  xsf_term();
	  m1sdr_Exit();
	  if (c)
	    {
	      free(c);
	      c = NULL;
	    }
	  free(buffer);
	  song--;

	  if (load_file(argc[song]) < 0)
	    {
	      ch = 27;
	    }
	}
    }

  xsf_term();

  tcgetattr(STDIN_FILENO, &tp);
  tp.c_lflag |= ICANON;
  tp.c_lflag |= (ECHO | ECHOCTL | ECHONL);
  tcsetattr(STDIN_FILENO, TCSANOW, &tp);

  free(buffer);

  return 1;
}
