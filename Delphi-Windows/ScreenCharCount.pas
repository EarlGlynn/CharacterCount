unit ScreenCharCount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,
  ShellAPI,  // DragAcceptFiles
  crc32;     // TInteger8, CalcCRC32

type
  TFormCharCount = class(TForm)
    ButtonSelect: TButton;
    StringGrid: TStringGrid;
    OpenDialog: TOpenDialog;
    ButtonControlCodes: TButton;
    LabelInfo1: TLabel;
    LabelInfo2: TLabel;
    CheckBoxFASTA: TCheckBox;
    LabelInfoDeflines: TLabel;
    CheckBoxASCII: TCheckBox;
    procedure ButtonControlCodesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonSelectClick(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure CheckBoxASCIIClick(Sender: TObject);
    

  private
    count       :  ARRAY[0..16, 0..16] OF TInteger8;
    CRC32Value  :  LongWord;
    DeflineCount:  TInteger8;
    LineCount   :  TInteger8;
    TotalBytes  :  TInteger8;

    PROCEDURE UpdateDisplay;
    PROCEDURE ProcessFile(CONST filename:  STRING);
    PROCEDURE ResetStringGrid;
    PROCEDURE WMDROPFILES(var msg : TWMDropFiles); MESSAGE WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  FormCharCount: TFormCharCount;

implementation
{$R *.dfm}

  USES
    Math,   // Min
    ScreenControlCodes;

////////////////////////////////////////////////////////////////////

  FUNCTION ShowASCII(CONST b:  BYTE):  STRING;
  BEGIN
    IF   b IN [32..126]
    THEN RESULT := CHR(b) + ':'
    ELSE RESULT := ''
  END {ShowASCII};

  FUNCTION Plural(CONST n:  TInteger8; CONST singularform,pluralform:  STRING):  STRING;
  BEGIN  {function similar to one on p. 314, Byte, December 1988}
    IF   n = 1
    THEN RESULT := singularform
    ELSE
      IF   pluralform = ''
      THEN RESULT := singularform + 's'
      ELSE RESULT := pluralform
  END {Plural};

    FUNCTION XLeft   (rect:  TRect; canvas:  TCanvas; s:  STRING):  INTEGER;
  BEGIN
    RESULT := rect.Left
  END {XRight};


  FUNCTION XCenter (rect:  TRect; canvas:  TCanvas; s:  STRING):  INTEGER;
  BEGIN
    RESULT := ((rect.Left + rect.Right) - canvas.TextWidth(s)) DIV 2
  END {XCenter};


  FUNCTION XRight (rect:  TRect; canvas:  TCanvas; s:  STRING):  INTEGER;
  BEGIN
    RESULT := rect.Right - canvas.TextWidth(s)
  END {XRight};


  // Top of text is its origin, so adjust by half-height of text to center
  FUNCTION YCenter (rect:  TRect; canvas:  TCanvas; s:  STRING):  INTEGER;
  BEGIN
    RESULT := ((rect.Top + rect.Bottom) - canvas.TextHeight(s)) DIV 2
  END {YCenter};

  TYPE
    TAlignment  = (alLeft, alCenter, alRight);

  PROCEDURE AlignText(CONST Canvas:  TCanvas; CONST Rect:  TRect;
                      CONST alignment:  TAlignment; CONST s:  STRING);
  BEGIN
    CASE alignment OF
      alLeft:   Canvas.TextRect(Rect,
                                XLeft(Rect, Canvas, s),
                                YCenter(Rect, Canvas, s),
                                s);
      alCenter:
        BEGIN
          Canvas.TextRect(Rect,
                          XCenter(Rect, Canvas, s),
                          YCenter(Rect, Canvas, s),
                          s);
        END;

      alRight:  Canvas.TextRect(Rect,
                                XRight(Rect, Canvas, s),
                                YCenter(Rect, Canvas, s),
                                s);
    END
  END {AlignText};

  procedure DeleteRow(yourStringGrid: TStringGrid; ARow: Integer);
    var
      i:  INTEGER;
      j:  INTEGER;
  begin
    WITH YourStringGrid DO
    BEGIN
      FOR i := ARow TO RowCount-2 DO
        FOR j := 0 TO ColCount-1 DO
          Cells[j, i] := Cells[j, i+1];
      RowCount := RowCount - 1
    END
  END;

////////////////////////////////////////////////////////////////////

  PROCEDURE TFormCharCount.UpdateDisplay;
    VAR
      i    :  INTEGER;
      j    :  INTEGER;
      s    :  STRING;
      sum  :  INTEGER;
      width:  INTEGER;
  BEGIN

    FOR j := 0 TO 15 DO
    BEGIN
      FOR i := 0 TO 15 DO
      BEGIN
        IF   count[i,j] > 0
        THEN BEGIN
          IF   count[i,j]   > count[16,j]
          THEN count[16,j] := count[i,j];

          IF   count[i,j]   > count[i,16]
          THEN count[i,16] := count[i,j];

          IF   CheckBoxAscii.Checked
          THEN StringGrid.Cells[i+1,j+1] := ShowASCII(16*j+i) +
                                            FormatFloat(',#', count[i,j])
          ELSE StringGrid.Cells[i+1,j+1] := FormatFloat(',#', count[i,j]);

        END
        ELSE StringGrid.Cells[i+1,j+1] := '';

      END
    END;

    // Hide rows or columns with no entries
    sum := StringGrid.RowHeights[0] + StringGrid.GridLineWidth;
    FOR j := 15 DOWNTO 0 DO
    BEGIN
      IF   count[16,j] = 0
      THEN DeleteRow(StringGrid, j+1)
      ELSE INC(sum, StringGrid.RowHeights[j+1]+StringGrid.GridLineWidth)
    END;
    // Extra 3 pixels needed regardless of GridLineWidth to avoid
    // vertical scrolling.
    StringGrid.Height := sum; // + 5;

    // Hide 0 columns
    width := 0;
    sum := StringGrid.ColWidths[0] + StringGrid.GridLineWidth;
    FOR i := 0 TO 15 DO
    BEGIN
      IF   count[i,16] = 0
      THEN StringGrid.ColWidths[i+1] := -StringGrid.GridLineWidth
      ELSE BEGIN
        s := FormatFloat(',#', count[i,16]);

        IF   CheckBoxASCII.Checked
        THEN s := 'W:' + s;   // Use "W" for widest character

        IF   StringGrid.Canvas.TextWidth(s) > width
        THEN width := StringGrid.Canvas.TextWidth(s);

        // In case column heading is wider than any entry in column
        s := StringGrid.Cells[i+1,0] + ':';
        IF   StringGrid.Canvas.TextWidth(s) > width
        THEN width := StringGrid.Canvas.TextWidth(s);

        StringGrid.ColWidths[i+1] :=
          MulDiv(width, 120, 100);  // Use 120% to leave 10% margins

        INC(sum, StringGrid.ColWidths[i+1] + StringGrid.GridLineWidth)
      END

    END;

    // Extra 3 pixels needed regardless of GridLineWidth.
    // Probably should figure out CLX GetSystemMetrics-like value that
    // defines this instead of using constant.
    StringGrid.Width := sum + StringGrid.GridLineWidth;
    LabelInfo1.Caption := FormatFloat(',#', TotalBytes) +
                          Plural(Totalbytes, ' byte', '');
    IF   CheckBoxFASTA.Checked
    THEN BEGIN
       LabelInfoDeflines.Visible := TRUE;
       LabelInfoDeflines.Caption := FormatFloat(',#', LineCount) +
                                   Plural(LineCount,' line', '') + ', ' +
                                   FormatFloat(',#', DeflineCount) +
                                   Plural(DeflineCount,' defline','');
    END
    ELSE LabelInfoDeflines.Visible := FALSE;

    LabelInfo2.Caption := 'CRC32 = ' + IntToHex(CRC32Value,8);

    Application.ProcessMessages;
    FormCharCount.ClientWidth  := Max(StringGrid.Width  + StringGrid.Left + 6,
                                400   // make sure "Control Codes" button
                                );    // doesn't hide anything
    FormCharCount.ClientHeight := StringGrid.Top + StringGrid.Height +
                            2*StringGrid.Left // keep "left" margin at bottom

  END {UpdateDisplay};

  PROCEDURE TFormCharCount.ResetStringGrid;
    VAR
      i:  INTEGER;
  BEGIN
    FOR i := 1 TO 16 DO
    BEGIN
      StringGrid.Cells[i,0] := IntToHex(i-1,1);
      StringGrid.Cells[0,i] := IntToHex(i-1,1)
    END
  END {ResetStringGrid};


////////////////////////////////////////////////////////////////////


procedure TFormCharCount.ButtonControlCodesClick(Sender: TObject);
begin
  FormControlCodes.ShowModal;
end;

procedure TFormCharCount.FormCreate(Sender: TObject);
begin
  // Make these checks to catch any changes in future definitions
  ASSERT(SizeOf(DWORD) = 4);
  ASSERT(SizeOf(LongWord) = 4);

  ResetStringGrid;
  LabelInfo1.Caption := '';
  LabelInfo2.Caption := '';

  // Allow drag and drop of file names
  DragAcceptFiles(Handle, TRUE)
end;

procedure TFormCharCount.ButtonSelectClick(Sender: TObject);
begin
  IF   OpenDialog.Execute
  THEN ProcessFile(OpenDialog.FileName)

end;

PROCEDURE TFormCharCount.ProcessFile(CONST filename:  STRING);
  VAR
    b         :  BYTE;
    buffer    :  ARRAY[WORD] OF BYTE;    // 64K buffer
    BytesRead :  TInteger8;
    DataFile  :  TextFile;
    i         :  BYTE;
    j         :  BYTE;
    k         :  LongWord;
    Line      :  STRING;
    Stream    :  TFileStream;
begin
  Screen.Cursor := crHourGlass;
  TRY
    FormCharCount.Caption := 'CharCount:  ' + filename;
    StringGrid.RowCount := 17;
    StringGrid.ColCount := 17;
    ResetStringGrid;

    FOR j := 0 TO 16 DO
    BEGIN
      FOR i := 0 TO 16 DO
        count[i,j] := 0;

      // Reassign these values in case previous case set them to zero
      StringGrid.RowHeights[j] := StringGrid.DefaultRowHeight;
      StringGrid.ColWidths[j]  := StringGrid.DefaultColWidth
    END;

    TotalBytes := 0;
    CRC32Value := $FFFFFFFF;   // CRC32 initialization

    IF   CheckBoxFASTA.Checked
    THEN BEGIN
      // Assume ASCII text file and read line-by-line ignoring line ends,
      // and any "deflines" starting with a ">".

      LineCount := 0;
      DeflineCount := 0;
      AssignFile(DataFile, OpenDialog.Filename);
      Reset(DataFile);
      WHILE NOT EOF(DataFile) DO
      BEGIN
        READLN(DataFile, Line);
        IF   COPY(Line,1,1) = '>'
        THEN INC(DeflineCount)
        ELSE BEGIN
          INC(LineCount);

          CalcCRC32(Addr(Line[1]), Length(Line), CRC32Value);
          INC(TotalBytes, Length(Line));

          FOR k := 1 TO Length(Line) DO
          BEGIN
            b := BYTE(Line[k]); // get character
            i := b AND $0F;     // i-th column
            j := b SHR 4;       // j-th row
            INC(count[i,j])
          END

        END
      END
    END
    ELSE BEGIN
      // Treating file as binary is perhaps a bit faster with fewer
      // CalcCRC32 calls.
      Stream := TFileStream.Create(filename, fmOpenRead OR
                                                        fmShareDenyNone);
      TRY

        // Must read file as series of buffers since some files are too large
        // to read completely into a memory stream.  If files are known to
        // be relatively small (say the size of actual memory or less), then
        // the CalcFileCRC32 routine could be used instead.
        BytesRead := Stream.Read(buffer, SizeOf(buffer));

        WHILE (BytesRead > 0) DO
        BEGIN
          CalcCRC32(Addr(buffer[0]), BytesRead, CRC32Value);
          INC(TotalBytes, BytesRead);

          FOR k := 0 TO BytesRead-1 DO
          BEGIN
            b := buffer[k];   // get character
            i := b AND $0F;   // i-th column
            j := b SHR 4;     // j-th row
            INC(count[i,j])
          END;

          BytesRead := Stream.Read(buffer, SizeOf(buffer));
        END

      FINALLY
        Stream.Free
      END
    END;

    CRC32Value := NOT CRC32Value;  // CRC32 Finalization

    UpdateDisplay
  FINALLY
    Screen.Cursor := crDefault
  END

end;


procedure TFormCharCount.StringGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);

  VAR
    index     :  INTEGER;
    MarginRect:  TRect;
    s         :  STRING;
    t         :  STRING;
begin

    s := StringGrid.Cells[ACol, ARow];

    StringGrid.Canvas.Font.Color := clBlack;

    IF   (ACol < StringGrid.FixedCols) OR (ARow < StringGrid.FixedRows)
    THEN StringGrid.Canvas.Brush.Color := clBtnFace
    ELSE StringGrid.Canvas.Brush.Color := clWhite;

    StringGrid.Canvas.FillRect(Rect);

    IF  (StringGrid.RowHeights[ARow] > 0)  AND
        (StringGrid.ColWidths[ACol]  > 0)
    THEN BEGIN

    IF   (ARow = 0) OR (ACol = 0)
    THEN BEGIN
      StringGrid.Canvas.Font.Color := clBlack;
      AlignText(StringGrid.Canvas, Rect, alCenter, s)
    END
    ELSE BEGIN
      WITH MarginRect DO
      BEGIN
       Left   := Rect.Left   + MulDiv(Rect.Right - Rect.Left,  5,100);  // 5% margins
       Top    := Rect.Top    + MulDiv(Rect.Bottom - Rect.Top,  5,100);
       Right  := Rect.Left   + MulDiv(Rect.Right - Rect.Left, 95,100);
       Bottom := Rect.Top    + MulDiv(Rect.Bottom - Rect.Top, 95,100);
      END;
      index := POS(':', s);

      IF   index > 0
      THEN BEGIN
        t := COPY(s, 1, index-1);
        StringGrid.Canvas.Font.Color := clRed;
        AlignText(StringGrid.Canvas, MarginRect, alLeft,  t)
      END;

      StringGrid.Canvas.Brush.Style := bsClear;
      StringGrid.Canvas.Font.Color := clBlue;
      t := COPY(s, index+1, LENGTH(s)-index);
      AlignText(StringGrid.Canvas, MarginRect, alRight, t);

    END
  END
end;


procedure TFormCharCount.CheckBoxASCIIClick(Sender: TObject);
begin
  UpdateDisplay
end;


// Handle files being dropped on a form
PROCEDURE TFormCharCount.WMDROPFILES(var msg: TWMDropFiles) ;
  CONST
    MAXFILENAME = 255;
  VAR
    // cnt:  INTEGER;
    fileCount:  INTEGER;
    fileName :  array [0..MAXFILENAME] of CHAR;
begin
  // how many files dropped?
  fileCount := DragQueryFile(msg.Drop, $FFFFFFFF, fileName, MAXFILENAME);

  // For now, process only first file.
  IF   fileCount > 0
  THEN BEGIN
    DragQueryFile(msg.Drop, 0, fileName, MAXFILENAME);
    ProcessFile(STRING(filename))
  END;

  // query for file names
  //for cnt := 0 to -1 + fileCount do
  //begin
  //  DragQueryFile(msg.Drop, cnt, fileName, MAXFILENAME);
    //do something with the file(s)
  //  memo1.Lines.Insert(0, fileName) ;
  //end;

  //release memory
  DragFinish(msg.Drop) ;
end;


end.


