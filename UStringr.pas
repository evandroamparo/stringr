unit UStringr;

interface

uses
  Classes, RegExpr;

type
  TParametroBase = class abstract(TInterfacedObject)
  private
    FValor: String;
    FNome: String;
    procedure SetNome(const Value: String);
    procedure SetValor(const Value: String);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }

  published
    { published declarations }
    property Nome: String read FNome write SetNome;
    property Valor: String read FValor write SetValor;
  end;

  TParametro = class(TInterfacedObject)
  private
    FValor: String;
    FNome: String;
    procedure SetNome(const Value: String);
    procedure SetValor(const Value: String);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }

  published
    property Nome: String read FNome write SetNome;
    property Valor: String read FValor write SetValor;
  end;

  TListaTemplate = class(TInterfacedObject)
  private
    FNome: String;
    procedure SetNome(const Value: String);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  published
    property Nome: String read FNome write SetNome;
  end;

  TStringr = class
    FTemplate: String;
    FParams: TStringList;
  private
    RegExp: TRegExpr;

    const EXP = '{(?gi)(\/?)(((\w+)\.)?(\w+))( (.+))?}';
    const DATE_PARAM = 'Date';
    const TIME_PARAM = 'Time';
    function GetParams(const Param: string): String;
    procedure SetParams(const Param, Value: String);

  protected
    procedure ProcessSpecialParams;
    procedure ProcessDateTime(*DataHora: TDataHora*);
  public
    property Params[const Param: string]: String read GetParams write SetParams; default;
    constructor Create(Template: String);
    destructor Destroy; override;
    function Render: String;
  end;

implementation

uses
  Windows, SysUtils, StrUtils;

{ TStringr }

constructor TStringr.Create(Template: String);
begin
  FTemplate := Template;
  FParams := TStringList.Create;
  RegExp := TRegExpr.Create;
end;

destructor TStringr.Destroy;
begin
  FreeAndNil(FParams);
  FreeAndNil(RegExp);
end;

function TStringr.GetParams(const Param: string): String;
begin
  Result := FParams.Values[Param];
end;

procedure TStringr.ProcessDateTime(*DataHora: TDataHora*);
var
  PosInicialParamentro, PosInicialFormato, PosFinal, i: Integer;
  Parametro, Formato: String;
  ParamName, ParamValue: string;
begin
//  case DataHora of
//    dhData: ParamName := DATE_PARAM;
//    dhHora: ParamName := TIME_PARAM;
//  end;

  FTemplate := StringReplace(FTemplate, '{' + ParamName + '}', DateToStr(Date),
      [rfReplaceAll, rfIgnoreCase]);

  PosFinal := 0;

  while AnsiContainsText(FTemplate, '{' + ParamName + ':') do
  begin
    Formato := '';
    PosInicialParamentro :=
        AnsiPos(AnsiUpperCase('{' + ParamName + ':'),
                AnsiUpperCase(FTemplate)) + 1;
    for i := PosInicialParamentro + 1 to Length(FTemplate) do
    begin
      if FTemplate[i] = '}' then
      begin
        PosFinal := i;
        Parametro := Copy(FTemplate,
                          PosInicialParamentro - 1,
                          PosFinal - PosInicialParamentro + 2);
        Break;
      end;
    end;
    for i := 1 to Length(Parametro) do
    begin
      if Parametro[i] = ':' then
      begin
        PosInicialFormato := i + 1;
        Formato := Copy(Parametro, PosInicialFormato, Length(Parametro) - PosInicialFormato);
        Break;
      end;
    end;
//    if Formato <> '' then
//      case DataHora of
//        dhData: ParamValue := FormatDateTime(Formato, Date);
//        dhHora: ParamValue := FormatDateTime(Formato, Time);
//      end;
//      FTemplate := StuffString(
//                      FTemplate,
//                      PosInicialParamentro - 1,
//                      PosFinal - PosInicialParamentro + 3,
//                      ParamValue);
  end;

  FTemplate := StringReplace(FTemplate, '{time}', TimeToStr(Time),
      [rfReplaceAll, rfIgnoreCase]);
end;

procedure TStringr.ProcessSpecialParams;
var
  PosInicialParamentro, PosInicialFormato, PosFinal, i: Integer;
  Parametro, Formato: String;
begin
  ProcessDateTime(*dhData*);
  ProcessDateTime(*dhHora*);
end;

function TStringr.Render: String;
var
  i: Integer;
  Nome: String;
begin
  { TODO : Processar parâmetros que estão no template mas não tem valor definido:
           renderizar como '' }
//  ProcessSpecialParams;

  RegExp.Expression := EXP;

  if RegExp.Exec(FTemplate) then
  begin
    repeat { proceed results}
      Nome := RegExp.Substitute('$5');
      FTemplate := StringReplace(FTemplate,
                                 RegExp.Substitute('$0'),
                                 FParams.Values[Nome],
                                 [rfIgnoreCase]);
    until not RegExp.ExecNext;
  end;
  Result := FTemplate;
end;

procedure TStringr.SetParams(const Param, Value: String);
begin
  FParams.Values[Param] := Value;
end;

{ TParametro }

procedure TParametro.SetNome(const Value: String);
begin
  FNome := Value;
end;

procedure TParametro.SetValor(const Value: String);
begin
  FValor := Value;
end;

{ TListaTemplate }

procedure TListaTemplate.SetNome(const Value: String);
begin
  FNome := Value;
end;

{ TParametroBase }

procedure TParametroBase.SetNome(const Value: String);
begin
  FNome := Value;
end;

procedure TParametroBase.SetValor(const Value: String);
begin
  FValor := Value;
end;

end.
