#include <stdio.h>
#include <limits.h>
#include "legible.h"
void main()
{
  /* sizes */
  printf("sizeof(BYTE):       %d\n",   sizeof(BYTE));
  printf("sizeof(CHARACTER):  %d\n\n", sizeof(CHARACTER));

  printf("sizeof(REAL):       %d\n",   sizeof(REAL));
  printf("sizeof(REAL64):     %d\n",   sizeof(REAL64));
  printf("sizeof(REAL96):     %d\n\n", sizeof(REAL96));

  printf("sizeof(STRING):     %d\n\n", sizeof(STRING));

  printf("sizeof(INTEGER):    %d\n",   sizeof(INTEGER));
  printf("sizeof(INTEGER16):  %d\n",   sizeof(INTEGER16));
  printf("sizeof(INTEGER32):  %d\n",   sizeof(INTEGER32));
  printf("sizeof(INTEGER64):  %d\n\n", sizeof(INTEGER64));

  printf("sizeof(WORD):       %d\n",   sizeof(WORD));
  printf("sizeof(WORD16):     %d\n",   sizeof(WORD16));
  printf("sizeof(WORD32):     %d\n",   sizeof(WORD32));
  printf("sizeof(WORD64):     %d\n\n", sizeof(WORD64));

  /* limits and formats */
  printf("INTEGER   min/max:  %d to %d\n",       INT_MIN,   INT_MAX);
  printf("INTEGER16 min/max:  %d to %d\n",       SHRT_MIN,  SHRT_MAX);
  printf("INTEGER32 min/max:  %ld to %ld\n",     LONG_MIN,  LONG_MAX);
  printf("INTEGER64 min/max:  %lld to %lld\n\n", LLONG_MIN, LLONG_MAX);

  printf("WORD   max:  %u\n",   UINT_MAX);
  printf("WORD16 max:  %u\n",   USHRT_MAX);
  printf("WORD32 max:  %lu\n",  ULONG_MAX);
  printf("WORD64 max:  %llu\n", ULLONG_MAX);
}

