unit UStringr;

interface

uses
  Classes, RegExpr, Generics.Collections, Contnrs;

type
  TElemento = class abstract
  private
    FTexto: WideString;
    FPosicaoInicial: Integer;
    FTamanho: Integer;
    procedure SetTexto(const Value: WideString);
    procedure SetPosicaoInicial(const Value: Integer);
    procedure SetTamanho(const Value: Integer);
  public
    property PosicaoInicial: Integer read FPosicaoInicial write SetPosicaoInicial;
    property Tamanho: Integer read FTamanho write SetTamanho;
    property Texto: WideString read FTexto write SetTexto;
    function ToString: WideString; reintroduce; virtual; abstract;
  end;

  TTexto = class(TElemento)
  private
    FTexto: WideString;
  public
    function ToString: WideString; override;
  end;

  TAtributo = class abstract
  private
    FValor: WideString;
    FNome: WideString;
    procedure SetNome(const Value: WideString);
    procedure SetValor(const Value: WideString);
  public
    property Nome: WideString read FNome write SetNome;
    property Valor: WideString read FValor write SetValor;
    function Transformar(const ValorParametro: WideString): WideString; virtual; abstract;
  end;

  TAtributoLength = class(TAtributo)
  private
    FValor: Integer;
    procedure SetValor(const Value: Integer);
  public
    property Valor: Integer read FValor write SetValor;
    function Transformar(const ValorParametro: WideString): WideString; override;
  end;

  TAtributoCase = class(TAtributo)
  public
    type
      TCharCase = (csNormal, csMaiusculas, csMinusculas);
  private
    FValorCase: TCharCase;
    procedure SetValor(const Value: TCharCase);
  public
    property Valor: TCharCase read FValorCase write SetValor;
    function Transformar(const ValorParametro: WideString): WideString; override;
  end;

  TAtributoFormat = class(TAtributo)
  public
    function Transformar(const ValorParametro: TDateTime): WideString; reintroduce;
  end;

  TParametro = class(TElemento)
  private
    FNome: String;
    FValor: WideString;
    FAtributos: TObjectList;
    procedure SetNome(const Value: String);
    procedure SetValor(const Value: WideString);
    function GetAtributos(const Nome: WideString): TAtributo;
    procedure SetAtributos(const Nome: WideString; Value: TAtributo);
  public
    property Nome: String read FNome write SetNome;
    property Valor: WideString read FValor write SetValor;
    property Atributos[const Nome: WideString]: TAtributo read GetAtributos write SetAtributos;
    function ToString: WideString; override;

    constructor Create;
    destructor Destroy; override;
  end;

  TCustomParser = class abstract
  private
    FTexto: WideString;
    FContemElemento: Boolean;
  public
    property ContemElemento: Boolean read FContemElemento;
    function ProximoElemento: TElemento; virtual; abstract;

    constructor Create(const Texto: WideString);
    destructor Destroy; override;
  end;

  TDefaultParser = class(TCustomParser)
  private
    FTexto: WideString;
    RegEx: TRegExpr;
  public
    function ProximoElemento: TElemento; override;

    constructor Create(const Texto: WideString);
    destructor Destroy; override;
  end;

  TTemplate = class(TObjectList)
  private
    FElementos: TObjectList;
    FTexto: WideString;
    function GetElementos(const Indice: Integer): TElemento;
    procedure SetElementos(const Indice: Integer; const Value: TElemento);
    procedure SetTexto(const Value: WideString);
  public
    property Texto: WideString read FTexto write SetTexto;
    property Elementos[const Indice: Integer]: TElemento read GetElementos write SetElementos;
    procedure NovoElemento(Elemento: TElemento);
    procedure RemoveElemento(const Indice: Integer); overload;
    procedure RemoveElemento(Elemento: TElemento); overload;
    function ToString: WideString; reintroduce;

    constructor Create;
    destructor Destroy; override;
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
  public
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
      begin
        if Length(Valor) > StrToIntDef(ListaAtributos.Values[ATTR_LENGTH], Length(Valor)) then
          Valor := Copy(Valor, 1,
                      StrToIntDef(ListaAtributos.Values[ATTR_LENGTH], Length(Valor)))
        else
          Valor := Valor + StringOfChar(' ',
                            StrToIntDef(ListaAtributos.Values[ATTR_LENGTH], Length(Valor)) - Length(Valor));
      end;
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

{ TListaTemplate }

procedure TListaTemplate.SetNome(const Value: String);
begin
  FNome := Value;
end;

{ TTexto }

function TTexto.ToString: WideString;
begin
  Result := FTexto;
end;

{ TElemento }

procedure TElemento.SetPosicaoInicial(const Value: Integer);
begin
  FPosicaoInicial := Value;
end;

procedure TElemento.SetTamanho(const Value: Integer);
begin
  FTamanho := Value;
end;

procedure TElemento.SetTexto(const Value: WideString);
begin
  FTexto := Value;
end;

{ TParametro }

constructor TParametro.Create;
begin
  inherited;
  FAtributos := TObjectList.Create;
end;

destructor TParametro.Destroy;
begin
  FAtributos.Free;
  inherited;
end;

function TParametro.GetAtributos(const Nome: WideString): TAtributo;
var
  i: Integer;
begin
  for i := 0 to FAtributos.Count - 1 do
    if (FAtributos[i] as TAtributo).Nome = Nome then
    begin
      Result := (FAtributos[i] as TAtributo);
      Break;
    end;

  Result := nil;
end;

procedure TParametro.SetAtributos(const Nome: WideString; Value: TAtributo);
var
  i, iEncontrado: Integer;
begin
  iEncontrado := -1;

  for i := 0 to FAtributos.Count - 1 do
    if (FAtributos[i] as TAtributo).Nome = Nome then
    begin
      iEncontrado := i;
      Break;
    end;

  if iEncontrado <> -1 then
  begin
    FAtributos[i].Free;
    FAtributos[i] := Value;
  end;
end;

procedure TParametro.SetNome(const Value: String);
begin
  FNome := Value;
end;

procedure TParametro.SetValor(const Value: WideString);
begin
  FValor := Value;
end;

function TParametro.ToString: WideString;
var
  i: Integer;
begin
  Result := Valor;

  if Valor <> '' then
    for i := 0 to FAtributos.Count - 1 do
      Result := TAtributo(FAtributos[i]).Transformar(Result);
end;

{ TAtributo }

procedure TAtributo.SetNome(const Value: WideString);
begin
  FNome := Value;
end;

procedure TAtributo.SetValor(const Value: WideString);
begin
  FValor := Value;
end;

{ TAtributoLength }

procedure TAtributoLength.SetValor(const Value: Integer);
begin
  FValor := Value;
end;

function TAtributoLength.Transformar(
  const ValorParametro: WideString): WideString;
begin
  if Length(ValorParametro) > Valor then
    Result := Copy(ValorParametro, 1, Valor)
  else
    Result := ValorParametro + StringOfChar(' ', Valor - Length(ValorParametro));
end;

{ TAtributoCase }

procedure TAtributoCase.SetValor(const Value: TCharCase);
begin
  FValorCase := Value;
end;

function TAtributoCase.Transformar(
  const ValorParametro: WideString): WideString;
begin
  case Valor of
    csMaiusculas:
      Result := AnsiUpperCase(ValorParametro);
    csMinusculas:
      Result := AnsiLowerCase(ValorParametro);
    else
      Result := ValorParametro;
  end;
end;

{ TAtributoFormat }

function TAtributoFormat.Transformar(
  const ValorParametro: TDateTime): WideString;
begin
  Result := FormatDateTime(Valor, ValorParametro);
end;

{ TTemplate }

constructor TTemplate.Create;
begin
  FElementos := TObjectList.Create;
end;

destructor TTemplate.Destroy;
begin
  FElementos.Free;
  inherited;
end;

function TTemplate.GetElementos(const Indice: Integer): TElemento;
begin
  if not (Indice in [0..FElementos.Count - 1]) then
    raise ERangeError.CreateFmt('Índice do elemento fora do intervalo (%d)', [Indice]);

  Result := FElementos[Indice] as TElemento;
end;

procedure TTemplate.NovoElemento(Elemento: TElemento);
begin
  FElementos.Add(Elemento);
end;

procedure TTemplate.RemoveElemento(Elemento: TElemento);
begin
  FElementos.Remove(Elemento);
end;

procedure TTemplate.RemoveElemento(const Indice: Integer);
begin
  if not (Indice in [0..FElementos.Count - 1]) then
    raise ERangeError.CreateFmt('Índice do elemento fora do intervalo(%d)', [Indice]);

  FElementos.Delete(Indice);
end;

procedure TTemplate.SetElementos(const Indice: Integer; const Value: TElemento);
begin
  if not (Indice in [0..FElementos.Count - 1]) then
    raise ERangeError.CreateFmt('Índice do elemento fora do intervalo(%d)', [Indice]);

  FElementos[Indice] := Value;
end;

procedure TTemplate.SetTexto(const Value: WideString);
begin
  FTexto := Value;
end;

function TTemplate.ToString: WideString;
begin

end;

{ TParser }

constructor TDefaultParser.Create(const Texto: WideString);
begin
  inherited;
  RegEx := TRegExpr.Create;
end;

destructor TDefaultParser.Destroy;
begin
  RegEx.Free;
  inherited;
end;

function TDefaultParser.ProximoElemento: TElemento;
begin

end;

{ TCustomParser }

constructor TCustomParser.Create(const Texto: WideString);
begin
  FTexto := Texto;
end;

destructor TCustomParser.Destroy;
begin

  inherited;
end;

end.
