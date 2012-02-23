program Stringr;

uses
  Forms,
  UStringr in 'UStringr.pas',
  RegExpr in 'Utils\RegExpr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
