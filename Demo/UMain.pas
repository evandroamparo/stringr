unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtDlgs, Menus, StdCtrls, ExtCtrls;

type
  TFMain = class(TForm)
    MainMenu1: TMainMenu;
    emplate1: TMenuItem;
    OfdTemplate: TOpenDialog;
    MemoSaida: TMemo;
    Abrir1: TMenuItem;
    Gerar1: TMenuItem;
    Panel1: TPanel;
    MemoParametros: TMemo;
    Label1: TLabel;
    MemoTemplate: TMemo;
    Splitter1: TSplitter;
    procedure Abrir1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Gerar1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

uses
  UStringr, UDefaultParser;

{$R *.dfm}

procedure TFMain.Abrir1Click(Sender: TObject);
begin
  if OfdTemplate.Execute() then
    MemoTemplate.Lines.LoadFromFile(OfdTemplate.FileName);
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  OfdTemplate.InitialDir := ExtractFilePath(Application.ExeName);
end;

procedure TFMain.Gerar1Click(Sender: TObject);
var
  Template: TStringr;
  Parser: TDefaultParser;
  i: Integer;
begin
  Parser := TDefaultParser.Create;
  Template := TStringr.Create(Parser);
  Template.Texto := MemoTemplate.Text;
  try
    for i := 0 to MemoParametros.Lines.Count - 1 do
      Template[MemoParametros.Lines.Names[i]] := MemoParametros.Lines.ValueFromIndex[i];
      MemoSaida.Text := Template.ToString;
  finally
    Template.Free;
    Parser.Free;
  end;
end;

end.
