unit ScreenControlCodes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons;

TYPE
  TControlCode =
    RECORD
      code:  BYTE;
      abbr:  STRING;
      desc:  STRING
    END;

  VAR
  ControlCode:  ARRAY[0..33] OF TControlCode =
    ( (code:  $00; abbr:  'nul'; desc:  'null'),
      (code:  $01; abbr:  'soh'; desc:  'start of heading'),
      (code:  $02; abbr:  'stx'; desc:  'start of text'),
      (code:  $03; abbr:  'etx'; desc:  'end of text'),
      (code:  $04; abbr:  'eot'; desc:  'end of transmission'),
      (code:  $05; abbr:  'enq'; desc:  'enquiry'),
      (code:  $06; abbr:  'ack'; desc:  'acknowledge'),
      (code:  $07; abbr:  'bel'; desc:  'bell'),
      (code:  $08; abbr:  'bs';  desc:  'backspace'),
      (code:  $09; abbr:  'ht';  desc:  'horizontal tab'),
      (code:  $0a; abbr:  'lf';  desc:  'line feed (nl = new line)'),
      (code:  $0b; abbr:  'vt';  desc:  'vertical tab'),
      (code:  $0c; abbr:  'ff';  desc:  'form feed (np = new page)'),
      (code:  $0d; abbr:  'cr';  desc:  'carriage return'),
      (code:  $0e; abbr:  'so';  desc:  'shift out'),
      (code:  $0f; abbr:  'si';  desc:  'shift in'),
      (code:  $10; abbr:  'dle'; desc:  'data link escape'),
      (code:  $11; abbr:  'dcl'; desc:  'device control 1'),
      (code:  $12; abbr:  'dc2'; desc:  'device control 2'),
      (code:  $13; abbr:  'dc3'; desc:  'device control 3'),
      (code:  $14; abbr:  'dc4'; desc:  'device control 4'),
      (code:  $15; abbr:  'nak'; desc:  'negative acknowledge'),
      (code:  $16; abbr:  'syn'; desc:  'synchronous idle'),
      (code:  $17; abbr:  'etb'; desc:  'end of block'),
      (code:  $18; abbr:  'can'; desc:  'cancel'),
      (code:  $19; abbr:  'em';  desc:  'end of medium'),
      (code:  $1a; abbr:  'sub'; desc:  'substitute'),
      (code:  $1b; abbr:  'esc'; desc:  'escape'),
      (code:  $1c; abbr:  'fs';  desc:  'file separator'),
      (code:  $1d; abbr:  'gs';  desc:  'group separator'),
      (code:  $1e; abbr:  'rs';  desc:  'record separator'),
      (code:  $1f; abbr:  'us';  desc:  'unit separator'),
      (code:  $20; abbr:  'sp';  desc:  'space'),
      (code:  $7f; abbr:  'del'; desc:  '(delete)')
    );

type
  TFormControlCodes = class(TForm)
    BitBtn1: TBitBtn;
    StringGridCodes: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormControlCodes: TFormControlCodes;

implementation

{$R *.dfm}

procedure TFormControlCodes.FormCreate(Sender: TObject);
 VAR
    i:  INTEGER;
begin
  StringGridCodes.Cells[0,0] := 'Hex';
  StringGridCodes.Cells[1,0] := 'Code';
  StringGridCodes.Cells[2,0] := 'Description';

  StringGridCodes.ColWidths[0] := 60;
  StringGridCodes.ColWidths[1] := 60;
  StringGridCodes.ColWidths[2] := 150;

  FOR i := Low(ControlCode) TO High(ControlCode) DO
  BEGIN
    WITH ControlCode[i] DO
    BEGIN
      StringGridCodes.Cells[0, i+1] := IntToHex(code, 2);
      StringGridCodes.Cells[1, i+1] := abbr;
      StringGridCodes.Cells[2, i+1] := desc
    END
  END
end;

end.
