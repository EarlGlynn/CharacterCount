program CharCount;

uses
  QForms,
  ScreenCharCount in 'ScreenCharCount.pas' {FormCharCount},
  CRC32 in 'crc32.pas',
  ScreenControlCodes in 'ScreenControlCodes.pas' {FormControlCodes};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormCharCount, FormCharCount);
  Application.CreateForm(TFormControlCodes, FormControlCodes);
  Application.Run;
end.
