program StringrDemo;

uses
  Forms,
  UMain in 'UMain.pas' {FMain},
  UStringr in '..\UStringr.pas',
  RegExpr in '..\Utils\RegExpr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
