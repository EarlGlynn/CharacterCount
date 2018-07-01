/* CHARCNT.  efg, 1990-08-18.  Rework of CHARCNT.PAS */
/* Linear output for a file.  efg, 2015-03-12.       */

#include <stdio.h>
#include <stdlib.h>
#include "legible.h"    /* readable, portable style */

#define max(A,B) ((A) > (B) ? (A) : (B))

INTEGER main(INTEGER argc, STRING argv[])
{
  INTEGER  c;
  BYTE     i;
  FILE    *in;
  BYTE     j;
  WORD64   total  =  0;
  BYTE     width[16];

  union
  {
    WORD64 vector[256];
    WORD64 matrix[16][16];
  } freq;
 
  IF  argc IS_NOT 2
  THEN
    printf("Syntax:  charcnt2 filename.ext\n");
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
    total++
  END
  fclose (in);
 
  printf("%s,",argv[1]); 
 
  FOR  c = 0; c < 256; c++
  BEGIN        
    printf("%ld,",freq.vector[c])     
  END

  printf("%ld\n",total);

  return (total IS 0);
}
