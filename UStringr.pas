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
    const EXP_ATTR = '(?gi)(\w+)=((''((\\''|[^''}])+)'')|([^} ]+))';
    const DATE_PARAM = 'Date';
    const TIME_PARAM = 'Time';
    const DATE_TIME_PARAM = 'DateTime';
    function GetParams(const Param: string): String;
    procedure SetParams(const Param, Value: String);

  protected
    procedure ProcessSpecialParams;
    procedure ProcessDateTime(*DataHora: TDataHora*);
    function ParseAtributes(S: String): TStringList;
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

function TStringr.ParseAtributes(S: String): TStringList;
var
  RegEx: TRegExpr;
  Val: String;
begin
  Result := TStringList.Create;
  RegEx := TRegExpr.Create;
  RegEx.Expression := EXP_ATTR;
  try
    if RegEx.Exec(S) then
    begin
      repeat
        Val := RegEx.Substitute('$4'); // com aspas
        if Val = '' then
          Val := RegEx.Substitute('$6'); // sem aspas
        Val := StringReplace(Val, '\''', '''', [rfReplaceAll]);
        Result.Add(AnsiLowerCase(RegEx.Substitute('$1')) + '=' + Val);
      until not RegEx.ExecNext;
    end;
  finally
    RegEx.Free;
  end;
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
  Nome, Valor, StrAtributos: String;
  ListaAtributos: TStringList;
begin
  RegExp.Expression := EXP;

  if RegExp.Exec(FTemplate) then
  begin
    repeat
      Nome := RegExp.Substitute('$5');
      ListaAtributos := ParseAtributes(RegExp.Substitute('$7'));

      if AnsiCompareText(Nome, DATE_PARAM) = 0 then
      begin
        if ListaAtributos.Values['format'] <> '' then
          Valor := FormatDateTime(ListaAtributos.Values['format'], Date)
        else
          Valor := DateToStr(Date);
      end
      else if AnsiCompareText(Nome, TIME_PARAM) = 0 then
      begin
        if ListaAtributos.Values['format'] <> '' then
          Valor := FormatDateTime(ListaAtributos.Values['format'], Time)
        else
          Valor := TimeToStr(Time);
      end
      else if AnsiCompareText(Nome, DATE_TIME_PARAM) = 0 then
      begin
        if ListaAtributos.Values['format'] <> '' then
          Valor := FormatDateTime(ListaAtributos.Values['format'], Date)
        else
          Valor := DateTimeToStr(Now);
      end
      else
        Valor := FParams.Values[Nome];

      if ListaAtributos.Values['case'] = 'upper' then
        Valor := AnsiUpperCase(Valor)
      else if ListaAtributos.Values['case'] = 'lower' then
        Valor := AnsiLowerCase(Valor);

      if ListaAtributos.Values['length'] <> '' then
        Valor := Copy(Valor, 1,
                      StrToIntDef(ListaAtributos.Values['length'], Length(Valor)));

      FTemplate := StringReplace(FTemplate,
                                 RegExp.Substitute('$0'),
                                 Valor,
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
