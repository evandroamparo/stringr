unit UStringr;

interface

uses
  Classes, RegExpr, Generics.Collections, Contnrs, SysUtils;

type
  ETemplateError = class(Exception);

  TElemento = class abstract
  private
    FTexto: WideString;
    FPosicaoInicial: Integer;
    procedure SetTexto(const Value: WideString);
    procedure SetPosicaoInicial(const Value: Integer);
  public
    property PosicaoInicial: Integer read FPosicaoInicial write SetPosicaoInicial;
    property Texto: WideString read FTexto write SetTexto;
    function ToString: WideString; reintroduce; virtual; abstract;
  end;

  TTexto = class(TElemento)
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
  public
    property Nome: String read FNome write SetNome;
    property Valor: WideString read FValor write SetValor;
    procedure NovoAtributo(Atributo: TAtributo);
    function ToString: WideString; override;

    constructor Create;
    destructor Destroy; override;
  end;

  TCustomParser = class abstract
  private
    FTexto: WideString;
    FFimTag: WideString;
    FInicioTag: WideString;
    FContemElemento: Boolean;
    procedure SetFimTag(const Value: WideString);
    procedure SetInicioTag(const Value: WideString);
    procedure SetContemElemento(const Value: Boolean);
  public
    property InicioTag: WideString read FInicioTag write SetInicioTag;
    property FimTag: WideString read FFimTag write SetFimTag;
    property ContemElemento: Boolean read FContemElemento write SetContemElemento;
    function ProximoElemento: TElemento; virtual; abstract;

    constructor Create(const Texto: WideString);
    destructor Destroy; override;
  end;

  TDefaultParser = class(TCustomParser)
  private
    RegEx: TRegExpr;
    FIniciado: Boolean;
    FTexto: WideString;
    FPosicaoInicial: Integer;
    FExpEncontrada: Boolean;
    function GetContemElemento: Boolean;
    function ExtraiAtributos(S: String): TStringList;

    const INICIO_TAG = '{';
    const FIM_TAG = '}';
    const ER_TAG = INICIO_TAG + '(?gi)(\/?)(((\w+)\.)?(\w+))( (.+?))?' + FIM_TAG;
    const TPL_EXP = '$0';
    const TPL_LISTA_FIM = '$1';
    const TPL_LISTA = '$2';
    const TPL_LISTA_PARAM = '$4';
    const TPL_PARAM = '$5';
    const TPL_PARAM_ATR = '$7';
    const TPL_LISTA_INICIO = '$7';

    const ER_ATRIB = '(?gi)(\w+)=((''((\\''|[^''}])+)'')|([^} ]+))';
    const TPL_ATR = '$1';
    const TPL_VAL_ASPAS = '$4';
    const TPL_VAL_SEM_ASPAS = '$6';

    const PARAM_DATA = 'Date';
    const PARAM_HORA = 'Time';
    const PARAM_DATA_HORA = 'DateTime';

    const ATR_CASE = 'case';
    const ATR_VAL_UPPERCASE = 'upper';
    const ATR_VAL_LOWERCASE = 'lower';
    const	ATR_LENGTH = 'length';
    const ATR_FORMAT = 'format';

    const ESCAPE = '\';
    const ASPAS = '''';

  public
    property ContemElemento: Boolean read GetContemElemento;
    function ProximoElemento: TElemento; override;

    constructor Create(const Texto: WideString;
        InicioTag: WideString = INICIO_TAG; FimTag: WideString = FIM_TAG);
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
  Windows, StrUtils;

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

procedure TElemento.SetTexto(const Value: WideString);
begin
  FTexto := Value;
end;

{ TParametro }

constructor TParametro.Create;
begin
  inherited;
  FAtributos := TObjectList.Create;
  FAtributos.OwnsObjects := True;
end;

destructor TParametro.Destroy;
begin
  FAtributos.Free;
  inherited;
end;

procedure TParametro.NovoAtributo(Atributo: TAtributo);
begin
  FAtributos.Add(Atributo);
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
      Result := WideUpperCase(ValorParametro);
    csMinusculas:
      Result := WideLowerCase(ValorParametro);
    else
      Result := ValorParametro;
  end;
end;

{ TAtributoFormat }

function TAtributoFormat.Transformar(
  const ValorParametro: TDateTime): WideString;
begin
  if Trim(Valor) <> '' then
    Result := FormatDateTime(Valor, ValorParametro)
  else if ValorParametro = Trunc(ValorParametro) then // somente data
    Result := DateToStr(ValorParametro)
  else if ValorParametro = Frac(ValorParametro) then // somente hora
    Result := TimeToStr(ValorParametro)
  else
    Result := DateTimeToStr(ValorParametro);
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

constructor TDefaultParser.Create(const Texto: WideString;
  InicioTag: WideString = INICIO_TAG; FimTag: WideString = FIM_TAG);
var
  ExpRegular: WideString;
begin
  FTexto := Texto;
  FPosicaoInicial := 1;
  FIniciado := False;
  FInicioTag := InicioTag;
  FFimTag := FimTag;
  RegEx := TRegExpr.Create;
  ExpRegular := StringReplace(ER_TAG, INICIO_TAG, FInicioTag, []);
  ExpRegular := StringReplace(ExpRegular, FIM_TAG, FFimTag, []);
  RegEx.Expression := ExpRegular;
  RegEx.InputString := FTexto;
end;

destructor TDefaultParser.Destroy;
begin
  RegEx.Free;
  inherited;
end;

function TDefaultParser.ExtraiAtributos(S: String): TStringList;
var
  Re: TRegExpr;
  Val: String;
begin
  Result := TStringList.Create;
  Re := TRegExpr.Create;
  Re.Expression := ER_ATRIB;
  try
    if Re.Exec(S) then
    begin
      repeat
        Val := Re.Match[4];
        if Val = '' then
          Val := Re.Match[6];
        Val := StringReplace(Val, ESCAPE + ASPAS, ASPAS, [rfReplaceAll]);
        Result.Add(AnsiLowerCase(Re.Match[1]) + '=' + Val);
      until not Re.ExecNext;
    end;
  finally
    Re.Free;
  end;
end;

function TDefaultParser.GetContemElemento: Boolean;
begin
  if not FIniciado then
  begin
    FExpEncontrada := RegEx.Exec(FTexto);
    FIniciado := True;
  end;

  Result := FExpEncontrada or
            (not FExpEncontrada and (FTexto <> ''));
end;

function TDefaultParser.ProximoElemento: TElemento;
var
  ListaAtributos: TStringList;
  i: Integer;
  Atributo: TAtributo;
begin
  if not ContemElemento then
  begin
    Result := nil;
    Exit;
  end;

  if (not FExpEncontrada and (Length(FTexto) > FPosicaoInicial)) then
  begin
    Result := TTexto.Create;
    Result.Texto := Copy(FTexto, FPosicaoInicial, Length(FTexto) - FPosicaoInicial + 1);
    Result.PosicaoInicial := FPosicaoInicial;
    FPosicaoInicial := Length(FTexto) + 1;
  end
  else if RegEx.MatchPos[0] <> FPosicaoInicial then
  begin
    Result := TTexto.Create;
    Result.Texto := Copy(FTexto, FPosicaoInicial, RegEx.MatchPos[0] - FPosicaoInicial);
    Result.PosicaoInicial := FPosicaoInicial;
    FPosicaoInicial := RegEx.MatchPos[0];
  end
  else
  begin
    Result := TParametro.Create;
    (Result as TParametro).Nome := RegEx.Match[5];
    ListaAtributos := ExtraiAtributos(RegEx.Match[7]);
    try
      for i := 0 to ListaAtributos.Count - 1 do
      begin
        if WideCompareText(ListaAtributos.Names[i], ATR_CASE) = 0 then
        begin
          Atributo := TAtributoCase.Create;
          Atributo.Nome := ATR_CASE;
          if WideCompareText(ListaAtributos.ValueFromIndex[i], ATR_VAL_UPPERCASE) = 0 then
            (Atributo as TAtributoCase).Valor := csMaiusculas
          else if WideCompareText(ListaAtributos.ValueFromIndex[i], ATR_VAL_LOWERCASE) = 0 then
            (Atributo as TAtributoCase).Valor := csMinusculas
          else if ListaAtributos.ValueFromIndex[i] <> '' then
            raise ETemplateError.CreateFmt(
                'Parâmetro: %s. Valor inválido para o atributo %s.',
                [RegEx.Match[0], ATR_CASE])
          else
            (Atributo as TAtributoCase).Valor := csNormal;
          (Result as TParametro).NovoAtributo(Atributo);
        end
        else if WideCompareText(ListaAtributos.Names[i], ATR_LENGTH) = 0 then
        begin
          Atributo := TAtributoLength.Create;
          try
            Atributo.Nome := ATR_LENGTH;
            (Atributo as TAtributoLength).Valor :=
              StrToInt(ListaAtributos.ValueFromIndex[i]);
            (Result as TParametro).NovoAtributo(Atributo);
          except
            on E: EConvertError do
            begin
              Atributo.Free;
              raise ETemplateError.CreateFmt(
                'Parâmetro: %s. Valor inválido para o atributo %s.',
                [RegEx.Match[0], ATR_LENGTH]);
            end;
          end;
        end
        else if WideCompareText(ListaAtributos.Names[i], ATR_FORMAT) = 0 then
        begin
          Atributo := TAtributoFormat.Create;
          Atributo.Nome := ATR_FORMAT;
          Atributo.Valor := ListaAtributos.ValueFromIndex[i];
          (Result as TParametro).NovoAtributo(Atributo);
        end
        else
          raise ETemplateError.CreateFmt('Atributo inválido: %s', [ListaAtributos.Names[i]]);
      end;
    finally
      ListaAtributos.Free;
    end;

    Result.Texto := RegEx.Match[0]; // extrair atributos
    Result.PosicaoInicial := RegEx.MatchPos[0];
    FPosicaoInicial := RegEx.MatchPos[0] + RegEx.MatchLen[0];
  end;

  FExpEncontrada := RegEx.ExecPos(FPosicaoInicial);
//
//  if AnsiCompareText(Nome, DATE_PARAM) = 0 then
//  begin
//    if ListaAtributos.Values[ATTR_FORMAT] <> '' then
//      Valor := FormatDateTime(ListaAtributos.Values[ATTR_FORMAT], Date)
//    else
//      Valor := DateToStr(Date);
//  end
//  else if AnsiCompareText(Nome, TIME_PARAM) = 0 then
//  begin
//    if ListaAtributos.Values[ATTR_FORMAT] <> '' then
//      Valor := FormatDateTime(ListaAtributos.Values[ATTR_FORMAT], Time)
//    else
//      Valor := TimeToStr(Time);
//  end
//  else if AnsiCompareText(Nome, DATE_TIME_PARAM) = 0 then
//  begin
//    if ListaAtributos.Values[ATTR_FORMAT] <> '' then
//      Valor := FormatDateTime(ListaAtributos.Values[ATTR_FORMAT], Now)
//    else
//      Valor := DateTimeToStr(Now);
//  end
//  else
//    Valor := FParams.Values[Nome];
//
//  if ListaAtributos.Values[ATTR_CASE] = ATTR_VAL_UPPERCASE then
//    Valor := AnsiUpperCase(Valor)
//  else if ListaAtributos.Values[ATTR_CASE] = ATTR_VAL_LOWERCASE then
//    Valor := AnsiLowerCase(Valor);
//
//  if ListaAtributos.Values[ATTR_LENGTH] <> '' then
//  begin
//    if Length(Valor) > StrToIntDef(ListaAtributos.Values[ATTR_LENGTH], Length(Valor)) then
//      Valor := Copy(Valor, 1,
//                  StrToIntDef(ListaAtributos.Values[ATTR_LENGTH], Length(Valor)))
//    else
//      Valor := Valor + StringOfChar(' ',
//                        StrToIntDef(ListaAtributos.Values[ATTR_LENGTH], Length(Valor)) - Length(Valor));
//  end;
//  FTemplate := StringReplace(FTemplate,
//                             RegExp.Substitute(TPL_EXP),
//                             Valor,
//                             [rfIgnoreCase]);

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

procedure TCustomParser.SetContemElemento(const Value: Boolean);
begin
  FContemElemento := Value;
end;

procedure TCustomParser.SetFimTag(const Value: WideString);
begin
  FFimTag := Value;
end;

procedure TCustomParser.SetInicioTag(const Value: WideString);
begin
  FInicioTag := Value;
end;

end.
