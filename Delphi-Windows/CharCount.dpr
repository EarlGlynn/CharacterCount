program CharCount;

uses
  Forms,
  ScreenCharCount in 'ScreenCharCount.pas' {FormCharCount},
  ScreenControlCodes in 'ScreenControlCodes.pas' {FormControlCodes};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormCharCount, FormCharCount);
  Application.CreateForm(TFormControlCodes, FormControlCodes);
  Application.Run;
end.
