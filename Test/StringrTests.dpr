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
  UStringr in '..\UStringr.pas',
  TestAtributoLength in 'TestAtributoLength.pas',
  TestAtributoCase in 'TestAtributoCase.pas',
  TestAtributoFormat in 'TestAtributoFormat.pas',
  TestParser in 'TestParser.pas',
  UDefaultParser in '..\UDefaultParser.pas',
  UAtributoLength in '..\UAtributoLength.pas',
  UAtributoCase in '..\UAtributoCase.pas',
  UAtributoFormat in '..\UAtributoFormat.pas',
  UParametro in '..\UParametro.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

