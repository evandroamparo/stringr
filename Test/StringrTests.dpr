program StringrTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestStringr in 'TestStringr.pas',
  TestAtributoLength in 'TestAtributoLength.pas',
  TestAtributoCase in 'TestAtributoCase.pas',
  TestAtributoFormat in 'TestAtributoFormat.pas',
  TestParser in 'TestParser.pas',
  UAtributoCase in '..\src\UAtributoCase.pas',
  UAtributoFormat in '..\src\UAtributoFormat.pas',
  UAtributoLength in '..\src\UAtributoLength.pas',
  UDefaultParser in '..\src\UDefaultParser.pas',
  UParametro in '..\src\UParametro.pas',
  UStringr in '..\src\UStringr.pas',
  RegExpr in '..\src\Utils\RegExpr.pas',
  UCustomParser in '..\src\UCustomParser.pas',
  UElemento in '..\src\UElemento.pas',
  UAtributo in '..\src\UAtributo.pas',
  UTexto in '..\src\UTexto.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

