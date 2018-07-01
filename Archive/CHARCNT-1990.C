/* CHARCNT.  EFG, 8/18/90.  Rework of CHARCNT.PAS */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>       /* log10 */

#define max(A,B) ((A) > (B) ? (A) : (B))

void main(argc, argv)
int argc;
char *argv[];
{
  FILE *in;
  char i, j, s[12], width[16];
  int  c;
  unsigned int checksum=0;
  long MaxCol[16], MaxRow[16], total=0;
  union
  {
    long vector[256];
    long matrix[16][16];
  } freq;
 
  if (argc != 2)
  {
    printf("Syntax:  CharCnt filename.ext\n");
    exit(1);
  }
 
  for (c = 0; c < 256; c++)
    freq.vector[c] = 0;
 
  if  ((in = fopen(argv[1],"rb")) == NULL)
  {
    fprintf(stderr,"Cannot open file \"%s\"\n",argv[1]);
    exit(2);
  }
 
  while ((c = getc(in)) != EOF)
  {
    freq.vector[c]++;
    checksum += c;
  }
  fclose (in);
 
  for (j = 0; j < 16; j++)
  {
    MaxCol[j] = MaxRow[j] = 0;
  }
 
  for (i = 0; i < 16; i++)
  {
    for (j = 0; j < 16; j++)
    {
      MaxCol[j] = max( MaxCol[j], freq.matrix[i][j] );
      MaxRow[i] = max( MaxRow[i], freq.matrix[i][j] );
      total += freq.matrix[i][j];
    }
  }
 
  printf("%s   %6d bytes",argv[1],total);
  printf("     checksum:  %5u\n",checksum);
  printf("\n  ");
  for (j = 0; j < 16; j++)
  {
    width[j] = MaxCol[j]==0 ? 0:(char) 2+log10((double) MaxCol[j]);
    if   (width[j] > 0)
    printf("%*X",width[j],j);
  }
  printf("\n  ");
  for (j = 0; j < 16; j++)
    if   (width[j] > 0)
    printf("%*c",width[j],'-');
  printf("\n");
 
  for (i = 0; i < 16; i++)
  {
    if (MaxRow[i] > 0)
    {
      printf("%2X",i);
      for (j = 0; j < 16; j++)
        if   (width[j] > 0)
          printf("%*ld",width[j],freq.matrix[i][j]);
      printf("\n");
    }
  }
 
  exit(0);
}
