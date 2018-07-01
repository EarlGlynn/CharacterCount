/* CHARCNT.  EFG, 8/18/90.  Rework of CHARCNT.PAS */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>       /* log10 */
#include "legible.h"    /* readable, portable style */

#define max(A,B) ((A) > (B) ? (A) : (B))

INTEGER main(INTEGER argc, STRING argv[])
{
  INTEGER  c;
  WORD32   checksum      =  0;
  BYTE     i;
  FILE    *in;
  BYTE     j;
  WORD64   MaxCol[16];
  WORD64   MaxRow[16];
  WORD64   total         =  0;
  BYTE     width[16];

  union
  {
    WORD64 vector[256];
    WORD64 matrix[16][16];
  } freq;
 
  IF  argc IS_NOT 2
  THEN
    printf("Syntax:  charcnt filename.ext\n");
    exit(2)
  END
 
  FOR  c = 0; c < 256; c++
  BEGIN
    freq.vector[c] = 0
  END

  IF  (in = fopen(argv[1],"rb"))  IS  NULL
  THEN
    fprintf(stderr,"Cannot open file \"%s\"\n",argv[1]);
    exit(3)
  END
 
  WHILE  (c = getc(in))  IS_NOT  EOF
  BEGIN
    freq.vector[c]++;
    checksum += c
  END
  fclose (in);
 
  FOR  j = 0; j < 16; j++
  BEGIN 
    MaxCol[j] = 0;
    MaxRow[j] = 0
  END
 
  FOR  i = 0; i < 16; i++
  BEGIN
    FOR  j = 0; j < 16; j++
    BEGIN
      MaxCol[j] = max( MaxCol[j], freq.matrix[i][j] );
      MaxRow[i] = max( MaxRow[i], freq.matrix[i][j] );
      total += freq.matrix[i][j]
    END
  END
 
  printf("%s   %6ld bytes",argv[1],total);
  printf("     checksum:  %5u\n",checksum);
  printf("\n  ");
  FOR  j = 0; j < 16; j++
  BEGIN
    width[j] = MaxCol[j]==0 ? 0:(char) 2+log10((double) MaxCol[j]);
    IF   width[j] > 0
    THEN  
      printf("%*X",width[j],j);
    END
  END
  printf("\n  ");

  FOR  j = 0; j < 16; j++
  BEGIN
    IF   width[j] > 0
    THEN
      printf("%*c",width[j],'-')
    END
  END
  printf("\n");
 
  FOR  i = 0; i < 16; i++
  BEGIN
    IF  MaxRow[i] > 0
    THEN
      printf("%2X",i);
      FOR  j = 0; j < 16; j++
      BEGIN
        IF   width[j] > 0
        THEN
          printf("%*ld",width[j],freq.matrix[i][j])
        END
      END
      printf("\n")
    END 
  END

  return (total IS 0);
}
