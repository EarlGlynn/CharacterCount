PROGRAM CharCnt;

 {This program forms a frequency count of every possible byte, $00..$FF,
  within a file and prints a table of these values.  Optionally, a
  translate table is produced for use by the XLATE program.

  Earl F. Glynn, Overland Park, KS, January 14, 1989.

  {Usage:  CharCnt [fromfile.ext [xlate.tbl [/H] ] ]          }


  USES DOS; {DateTime, FExpand, GetFTime, PathStr, UnPackTime}

  VAR
    b         :  BYTE;
    BytesRead :  WORD;
    Count     :  ARRAY[0..255] OF LongInt;
    CountTable:  ARRAY[0..15,0..15] OF LongInt ABSOLUTE Count;
    FileTime  :  DateTime;
    FromFile  :  FILE;
    FromName  :  PathStr;    {STRING[79]}
    HexFlag   :  BOOLEAN;
    InBuffer  :  ARRAY[1..50000] OF BYTE; {speed up I/O with large buffer}
    i,j       :  WORD;
    LongTemp  :  LongInt;
    MaxCol    :  ARRAY[0..15] OF WORD;
    NonZeroRow:  ARRAY[0..15] OF BOOLEAN;
    sTemp     :  STRING[12];
    xlate     :  BOOLEAN;
    XlateName :  PathStr;
    XlateFile :  TEXT;

  PROCEDURE FilePrompt (Prompt:  STRING; VAR filename:  PathStr);
  BEGIN
    WRITE (Prompt,' (or EXIT):  ');
    READLN (filename);
    IF   (filename = 'EXIT') OR (filename = 'exit')
    THEN HALT
  END {FilePrompt};

  PROCEDURE ProcessParms;
    VAR error:  WORD;
  BEGIN
    IF   ParamCount = 0
    THEN FilePrompt ('Enter Filename',FromName)
    ELSE FromName := ParamStr(1);
    error := 0;
    REPEAT
      IF   error <> 0
      THEN BEGIN
        WRITELN;
        WRITELN ('File ''',FromName,''' cannot be found.');
        FilePrompt ('Enter Filename',FromName)
      END;
      FromName := FExpand(FromName);
      ASSIGN (FromFile,FromName);
      FileMode := 0;    {Change System unit variable to R/O from R/W}
      {$I-} RESET (FromFile,1); {$I+}
      error := IOResult
    UNTIL error = 0;

    xlate := (ParamCount >= 2);
    IF   xlate
    THEN BEGIN
      IF   ParamCount >= 3
      THEN HexFlag := (ParamStr(3)='/h') OR (ParamStr(3)='/H')
      ELSE HexFlag := FALSE;
      XlateName := ParamStr(2);
      error := 0;
      REPEAT
        IF   error <> 0
        THEN BEGIN
          WRITELN;
          WRITELN ('Invalid XLATE Table Filename ''',XlateName,'''.');
          FilePrompt ('Enter New Filename',XlateName)
        END;
        ASSIGN (XlateFile,XlateName);
        {$I-} REWRITE (XlateFile); {$I+}
        error := IOResult
      UNTIL error = 0
    END
  END {ProcessParms};

  FUNCTION HexDigit(idx:  INTEGER):  CHAR;
    CONST
      Digits:  ARRAY[0..15] OF CHAR = ('0','1','2','3','4','5','6','7',
                                       '8','9','A','B','C','D','E','F');
  BEGIN
    HexDigit := Digits[idx]
  END {HexDigit};

BEGIN {CharCnt}
  ProcessParms;              {Get input file}

  FOR i := 0 TO 255 DO       {Initialize counters}
    Count[i] := 0;

  REPEAT                     {Read file; increment counters}
    BlockRead (FromFile,InBuffer,SizeOf(InBuffer),BytesRead);
    FOR i := 1 TO BytesRead DO
      INC (Count[InBuffer[i]]);
  UNTIL (BytesRead = 0) OR (BytesRead <> SizeOf(InBuffer));

  FOR i := 0 TO 15 DO BEGIN
    MaxCol[i] := 0;
    NonZeroRow[i] := FALSE
  END;

  FOR i := 0 TO 15 DO BEGIN  {Find largest value by column and row}
    FOR j := 0 TO 15 DO BEGIN
      IF   CountTable[i,j] > MaxCol[j]
      THEN MaxCol[j] := CountTable[i,j];
      NonZeroRow[i] := NonZeroRow[i] OR (CountTable[i,j] > 0)
    END
  END;

  FOR j := 0 TO 15 DO        {Find minimum column width by column}
    IF   MaxCol[j] > 0
    THEN BEGIN
      STR(MaxCol[j],sTemp);
      MaxCol[j] := LENGTH(sTemp)+1
    END
    ELSE MaxCol[j] := 0;

  GetFTime (FromFile,LongTemp);                {Get file date and time}
  UnPackTime (LongTemp,filetime);
  WRITELN (FromName,'   ',
    FileTime.month:2,'/',FileTime.day,'/',FileTime.year,' ',
    FileTime.hour:2,':',FileTime.min DIV 10:1,FileTime.min MOD 10:1,':',
    FileTime.sec DIV 10:1,FileTime.sec MOD 10:1,'   ',
    FileSize(FromFile),' bytes');
  WRITELN;
  IF  xlate
  THEN BEGIN
    WRITELN (XlateFile, FromName);
    WRITELN (XlateFile);
    WRITE (XlateFile,'   ')
  END;
  WRITE ('  ');
  FOR j := 0 TO 15 DO BEGIN                 {Print column headings}
    IF   MaxCol[j] > 0
    THEN WRITE (' ':MaxCol[j]-1,HexDigit(j));
    IF   xlate
    THEN WRITE (XlateFile,'  ',HexDigit(j))
  END;
  WRITELN;
  IF   xlate
  THEN BEGIN
    WRITELN (XlateFile);
    WRITE   (XlateFile,'   ')
  END;
  WRITE ('  ');
  FOR j := 0 TO 15 DO BEGIN
    IF   MaxCol[j] > 0
    THEN WRITE (' ':MaxCol[j]-1,'-');
    IF  xlate
    THEN WRITE (XlateFile,' --')
  END;
  WRITELN;
  IF   xlate
  THEN WRITELN (XlateFile);

  FOR i := 0 TO 15 DO BEGIN
    IF   NonZeroRow[i]                      {Print nonzero rows}
    THEN BEGIN
      WRITE (' ',HexDigit(i));
      FOR j := 0 TO 15 DO
        IF   MaxCol[j] > 0                  {Print nonzero columns}
        THEN WRITE (CountTable[i,j]:MaxCol[j]);
      WRITELN
    END;
    IF   xlate
    THEN BEGIN
      WRITE (XlateFile, HexDigit(i),' |');
      FOR j := 0 TO 15 DO
        IF   CountTable[i,j] = 0
        THEN WRITE (XlateFile,'  .')
        ELSE BEGIN
          b := 16*i+j;
          IF   HexFlag
          THEN
            IF  b IN [$21..$2D,$2F..$7E]
            THEN WRITE (XlateFile,'  ',CHR(b))
            ELSE WRITE (XlateFile,' ',HexDigit(i),HexDigit(j))
          ELSE
            IF  b IN [$00,$07,$08,$09,$0A,$0C,$0D,$1A,$20,$2E,$FF]
            THEN WRITE (XlateFile,' ',HexDigit(i),HexDigit(j))
            ELSE WRITE (XlateFile,'  ',CHR(b))
        END;
      WRITELN (XlateFile)
    END
  END;

  CLOSE (FromFile);
  IF   xlate
  THEN CLOSE (XlateFile)

END {CharCnt}.
