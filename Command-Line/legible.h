// $Id: legible.h,v 1.2 1998/04/21 04:15:21 earl Exp $
/* Legible Style for C/C++
 *
 * Copyright (C) 1992-1993, Earl F. Glynn, Overland Park, KS.
 * Fixed WORD64 and INTEGER64 for Windows PCs, July 4, 2018.
 *
 */

#ifndef _STYLE_H_
#define _STYLE_H_

#define GLOBAL  extern
#define LOCAL   static

enum    BOOLEAN  {
//                 FALSE=0,   // kludge for Alpha compile
//                 TRUE=1,

                   OFF=0,
                   ON=1,

                   NO=0,
                   YES=1
                 };

#define CONSTANT  const

typedef char                CHARACTER;
typedef char *              STRING;

typedef unsigned char       BYTE;           /* assume 8 bits/byte */
typedef unsigned char *     BYTE_STRING;

                                           /* use WORD as synonym for unsigned int */
typedef unsigned int        WORD;
typedef unsigned short int  WORD16;        /* portability between PCs and Suns */
typedef unsigned       int  WORD32;
typedef unsigned long  long WORD64;

typedef int                 INTEGER;
typedef short int           INTEGER16;
typedef       int           INTEGER32;
typedef long  long          INTEGER64;

typedef double              REAL;
typedef double              REAL64;
typedef long double         REAL96;

#define OBJECT     class
#define CONSTRUCTOR
#define DESTRUCTOR  ~

#define PROCEDURE  void
#define FUNCTION

#define FOR        {for(
#define IF         {if(
#define WHILE      {while(
#define BEGIN      ){
#define THEN       ){
#define ELSE       ;} else {
#define END        ;}}

#define REPEAT     {do {
#define UNTIL(x)       } while(!(x));}

#define SELECT     {if (0) {
#define WHEN(x)    ;} else if (x) {

#define AND        &&
#define OR         ||
#define NOT        !

#define IS         ==
#define IS_NOT     !=

#define STRING_MATCH 0

#endif
