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

    const EXP = '{(?gi)(\/?)(((\w+)\.)?(\w+))( (.+?))?}';
    const TPL_EXP = '$0';
    const TPL_LIST_END = '$1';
    const TPL_LIST = '$2';
    const TPL_LIST_PARAM = '$4';
    const TPL_PARAM = '$5';
    const TPL_PARAM_ATTR = '$7';
    const TPL_LIST_BEGIN = '$7';

    const EXP_ATTR = '(?gi)(\w+)=((''((\\''|[^''}])+)'')|([^} ]+))';
    const TPL_ATTR = '$1';
    const TPL_VAL_QUOTES = '$4';
    const TPL_VAL_NOQUOTES = '$6';

    const DATE_PARAM = 'Date';
    const TIME_PARAM = 'Time';
    const DATE_TIME_PARAM = 'DateTime';

    const ATTR_CASE = 'case';
    const ATTR_VAL_UPPERCASE = 'upper';
    const ATTR_VAL_LOWERCASE = 'lower';
    const	ATTR_LENGTH = 'length';
    const ATTR_FORMAT = 'format';

    const ESC_CHAR = '\';
    const QUOTES = '''';
    const TAG_BEGIN = '{';
    const TAG_END = '}';

    function GetParams(const Param: string): String;
    procedure SetParams(const Param, Value: String);

  protected
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
        Val := RegEx.Substitute(TPL_VAL_QUOTES);
        if Val = '' then
          Val := RegEx.Substitute(TPL_VAL_NOQUOTES);
        Val := StringReplace(Val, ESC_CHAR + QUOTES, QUOTES, [rfReplaceAll]);
        Result.Add(AnsiLowerCase(RegEx.Substitute(TPL_ATTR)) + '=' + Val);
      until not RegEx.ExecNext;
    end;
  finally
    RegEx.Free;
  end;
end;

function TStringr.Render: String;
var
  Nome, Valor: String;
  ListaAtributos: TStringList;
begin
  RegExp.Expression := EXP;

  if RegExp.Exec(FTemplate) then
  begin
    repeat
      Nome := RegExp.Substitute(TPL_PARAM);
      ListaAtributos := ParseAtributes(RegExp.Substitute(TPL_PARAM_ATTR));

      if AnsiCompareText(Nome, DATE_PARAM) = 0 then
      begin
        if ListaAtributos.Values[ATTR_FORMAT] <> '' then
          Valor := FormatDateTime(ListaAtributos.Values[ATTR_FORMAT], Date)
        else
          Valor := DateToStr(Date);
      end
      else if AnsiCompareText(Nome, TIME_PARAM) = 0 then
      begin
        if ListaAtributos.Values[ATTR_FORMAT] <> '' then
          Valor := FormatDateTime(ListaAtributos.Values[ATTR_FORMAT], Time)
        else
          Valor := TimeToStr(Time);
      end
      else if AnsiCompareText(Nome, DATE_TIME_PARAM) = 0 then
      begin
        if ListaAtributos.Values[ATTR_FORMAT] <> '' then
          Valor := FormatDateTime(ListaAtributos.Values[ATTR_FORMAT], Now)
        else
          Valor := DateTimeToStr(Now);
      end
      else
        Valor := FParams.Values[Nome];

      if ListaAtributos.Values[ATTR_CASE] = ATTR_VAL_UPPERCASE then
        Valor := AnsiUpperCase(Valor)
      else if ListaAtributos.Values[ATTR_CASE] = ATTR_VAL_LOWERCASE then
        Valor := AnsiLowerCase(Valor);

      if ListaAtributos.Values[ATTR_LENGTH] <> '' then
        Valor := Copy(Valor, 1,
                      StrToIntDef(ListaAtributos.Values[ATTR_LENGTH], Length(Valor)));

      FTemplate := StringReplace(FTemplate,
                                 RegExp.Substitute(TPL_EXP),
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
