unit UDefaultParser;

interface

uses
  UStringr, RegExpr, Classes, UCustomParser, UElemento;

type
  TDefaultParser = class(TInterfacedObject, ICustomParser)
  private
    RegEx: TRegExpr;
    FIniciado: Boolean;
    FTexto: WideString;
    FPosicaoInicial: Integer;
    FExpEncontrada: Boolean;
    FDelimitadorFim: WideString;
    FDelimitadorInicio: WideString;
    function ExtraiAtributos(S: String): TStringList;
    procedure SetTexto(const Value: WideString);
    procedure InicializaExpRegular;
    procedure SetDelimitadorFim(const Value: WideString);
    procedure SetDelimitadorInicio(const Value: WideString);

    const DELIMITADOR_INICIO = '{';
    const DELIMITADOR_FIM = '}';
    const ER_TAG = DELIMITADOR_INICIO + '(?gi)(\/?)(((\w+)\.)?(\w+))( (.+?))?' + DELIMITADOR_FIM;
    const SUB_EXP_PARAM = 5;
    const SUB_EXP_PARAM_ATRIB = 7;

    const SUB_EXP_LISTA_FIM = 1;
    const SUB_EXP_LISTA = 2;
    const SUB_EXP_LISTA_PARAM = 4;
    const SUB_EXP_LISTA_INICIO = 7;

    const ER_ATRIB = '(?gi)(\w+)=((''((\\''|[^''}])+)'')|([^} ]+))';
    const SUB_EXP_ATRIB = 1;
    const SUB_EXP_VAL_ASPAS = 4;
    const SUB_EXP_VAL_SEM_ASPAS = 6;

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
    property Texto: WideString read FTexto write SetTexto;
    property DelimitadorInicio: WideString read FDelimitadorInicio write SetDelimitadorInicio;
    property DelimitadorFim: WideString read FDelimitadorFim write SetDelimitadorFim;
    procedure Inicializa(const Texto: WideString);
    function ContemElemento: Boolean;
    function ProximoElemento: TElemento;

    constructor Create(const DelimitadorInicio: WideString = DELIMITADOR_INICIO;
      const DelimitadorFim: WideString = DELIMITADOR_FIM);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils, UAtributo, UTexto, UParametro, UAtributoCase, UAtributoLength,
  UAtributoFormat;

{ TDefaultParser }

function TDefaultParser.ContemElemento: Boolean;
begin
  if not FIniciado then
  begin
    FExpEncontrada := RegEx.Exec(FTexto);
    FIniciado := True;
  end;

  Result := FExpEncontrada or ((FTexto <> '') and (FPosicaoInicial <= Length(FTexto)));
end;

constructor TDefaultParser.Create(const DelimitadorInicio: WideString;
      const DelimitadorFim: WideString);
begin
  FPosicaoInicial := 1;
  FIniciado := False;
  FDelimitadorInicio := DelimitadorInicio;
  FDelimitadorFim := DelimitadorFim;
  RegEx := TRegExpr.Create;
  InicializaExpRegular;
end;

destructor TDefaultParser.Destroy;
begin
  RegEx.Free;
  inherited;
end;

procedure TDefaultParser.Inicializa(const Texto: WideString);
begin
  FTexto := Texto;
end;

procedure TDefaultParser.InicializaExpRegular;
var
  ExpRegular: WideString;
begin
  ExpRegular := StringReplace(ER_TAG, DELIMITADOR_INICIO, Self.DelimitadorInicio, []);
  ExpRegular := StringReplace(ExpRegular, DELIMITADOR_FIM, Self.DelimitadorFim, []);
  RegEx.Expression := ExpRegular;
  RegEx.InputString := FTexto;
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
        Val := Re.Match[SUB_EXP_VAL_ASPAS];
        if Val = '' then
          Val := Re.Match[SUB_EXP_VAL_SEM_ASPAS];
        Val := StringReplace(Val, ESCAPE + ASPAS, ASPAS, [rfReplaceAll]);
        Result.Add(AnsiLowerCase(Re.Match[SUB_EXP_ATRIB]) + '=' + Val);
      until not Re.ExecNext;
    end;
  finally
    Re.Free;
  end;
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

  if (not FExpEncontrada and (Length(FTexto) >= FPosicaoInicial)) then
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
    (Result as TParametro).Nome := RegEx.Match[SUB_EXP_PARAM];
    ListaAtributos := ExtraiAtributos(RegEx.Match[SUB_EXP_PARAM_ATRIB]);
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
            raise EParserError.CreateFmt(
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
              raise EParserError.CreateFmt(
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
          raise EParserError.CreateFmt('Atributo inválido: %s', [ListaAtributos.Names[i]]);
      end;
    finally
      ListaAtributos.Free;
    end;

    Result.Texto := RegEx.Match[0];
    Result.PosicaoInicial := RegEx.MatchPos[0];
    FPosicaoInicial := RegEx.MatchPos[0] + RegEx.MatchLen[0];
  end;

  FExpEncontrada := RegEx.ExecPos(FPosicaoInicial);
end;

procedure TDefaultParser.SetDelimitadorFim(const Value: WideString);
begin
  FDelimitadorFim := Value;
  InicializaExpRegular;
end;

procedure TDefaultParser.SetDelimitadorInicio(const Value: WideString);
begin
  FDelimitadorInicio := Value;
  InicializaExpRegular;
end;

procedure TDefaultParser.SetTexto(const Value: WideString);
begin
  FTexto := Value;
  FIniciado := False;
end;

end.
