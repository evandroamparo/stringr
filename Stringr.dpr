program Stringr;

uses
  Forms,
  UMain in 'UMain.pas' {Form1},
  UStringr in 'UStringr.pas',
  RegExpr in 'Utils\RegExpr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
