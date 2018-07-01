unit ScreenCharCount;

interface

uses
  SysUtils, Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QGrids;

type
  TFormCharCount = class(TForm)
    StringGrid: TStringGrid;
    OpenDialog: TOpenDialog;
    ButtonSelect: TButton;
    LabelInfo1: TLabel;
    LabelInfo2: TLabel;
    CheckBoxASCII: TCheckBox;
    Button1: TButton;
    procedure ButtonSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure CheckBoxASCIIClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    count     :  ARRAY[0..16, 0..16] OF Int64;
    CRC32Value:  LongWord;
    TotalBytes:  Int64;

    PROCEDURE UpdateDisplay;
  public
    { Public declarations }
  end;

var
  FormCharCount: TFormCharCount;

implementation
{$R *.xfm}

  USES
    CRC32, ScreenControlCodes;

    
  FUNCTION ShowASCII(CONST b:  BYTE):  STRING;
  BEGIN
    IF   b IN [32..126]
    THEN RESULT := CHR(b) + ':'
    ELSE RESULT := ''
  END {ShowASCII};


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
        THEN
          IF   CheckBoxAscii.Checked
          THEN StringGrid.Cells[i+1,j+1] := ShowASCII(16*j+i) +
                                            FormatFloat(',#', count[i,j])
          ELSE StringGrid.Cells[i+1,j+1] := FormatFloat(',#', count[i,j])
        ELSE StringGrid.Cells[i+1,j+1] := '';

        IF   count[i,j]   > count[16,j]
        THEN count[16,j] := count[i,j];

        IF   count[i,j]   > count[i,16]
        THEN count[i,16] := count[i,j];
      END
    END;

    // Hide rows or columns with no entries
    sum := StringGrid.RowHeights[0] + StringGrid.GridLineWidth;;
    FOR j := 0 TO 15 DO
    BEGIN
      IF   count[16,j] = 0
      THEN StringGrid.RowHeights[j+1] := -StringGrid.GridLineWidth
      ELSE INC(sum, StringGrid.RowHeights[j+1]+StringGrid.GridLineWidth)
    END;
    // Extra 3 pixels needed regardless of GridLineWidth to avoid
    // vertical scrolling.
    StringGrid.Height := sum + 3;

    width := 0;
    sum := StringGrid.ColWidths[0] + StringGrid.GridLineWidth;
    FOR i := 0 TO 15 DO
    BEGIN
      IF   count[i,16] = 0
      THEN StringGrid.ColWidths[i+1] := -StringGrid.GridLineWidth
      ELSE BEGIN
        s := FormatFloat(',#', count[i,16]);

        IF   CheckBoxASCII.Checked
        THEN s := 'I:' + s;

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
    StringGrid.Width := sum + 3;
    LabelInfo1.Caption := FormatFloat(',#', TotalBytes) + ' bytes';
    LabelInfo2.Caption := 'CRC-32 = ' + IntToHex(CRC32Value,8);

    FormCharCount.Width  := StringGrid.Width  + 2*StringGrid.Left + 2;
    FormCharCount.Height := StringGrid.Height + StringGrid.Top + StringGrid.Left

  END {UpdateDisplay};

procedure TFormCharCount.ButtonSelectClick(Sender: TObject);
  VAR
    b         :  BYTE;
    buffer    :  ARRAY[0..32767] OF BYTE;
    BytesRead :  LongInt;
    i         :  INTEGER;
    j         :  INTEGER;
    k         :  LongWord;
    Stream    :  TFileStream;
begin
  IF   OpenDialog.Execute
  THEN BEGIN
    Screen.Cursor := crHourGlass;

    TRY

      FormCharCount.Caption := 'Char Count:  ' + OpenDialog.FileName;

      FOR j := 0 TO 16 DO
      BEGIN
        FOR i := 0 TO 16 DO
          count[i,j] := 0;

        // Reassign these values in case previous case set them to zero
        StringGrid.RowHeights[j] := StringGrid.DefaultRowHeight;
        StringGrid.ColWidths[j]  := StringGrid.DefaultColWidth
      END;

      TotalBytes := 0;
      CRC32Value := $FFFFFFFF;   // CRC-32 initialization

      Stream := TFileStream.Create(OpenDialog.FileName, fmOpenRead OR fmShareDenyNone);
      TRY

        // Must read file as series of buffers since some files are too large
        // to read completely into a memory stream.
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
      END;

      CRC32Value := NOT CRC32Value;  // CRC-32 Finalization

      UpdateDisplay
    FINALLY
      Screen.Cursor := crDefault
    END
  END
end;

procedure TFormCharCount.FormCreate(Sender: TObject);
  VAR
    i:  INTEGER;
begin
  FOR i := 1 TO 16 DO
  BEGIN
    StringGrid.Cells[i,0] := IntToHex(i-1,1);
    StringGrid.Cells[0,i] := IntToHex(i-1,1)
  END;

  LabelInfo1.Caption := '';
  LabelInfo2.Caption := '';

end;


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

  type
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

    StringGrid.Canvas.Font.Color := clBlue;
    t := COPY(s, index+1, LENGTH(s)-index);
    AlignText(StringGrid.Canvas, MarginRect, alRight, t);

  END

end;

procedure TFormCharCount.CheckBoxASCIIClick(Sender: TObject);
begin
  UpdateDisplay
end;

procedure TFormCharCount.Button1Click(Sender: TObject);
begin
  FormControlCodes.ShowModal
end;

end.
