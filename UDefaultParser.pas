unit UDefaultParser;

interface

uses
  UStringr, RegExpr, Classes, UCustomParser, UElemento;

type
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

implementation

uses
  SysUtils, UAtributo, UTexto, UParametro, UAtributoCase, UAtributoLength,
  UAtributoFormat;

{ TDefaultParser }

constructor TDefaultParser.Create(const Texto: WideString; InicioTag,
  FimTag: WideString);
var
  ExpRegular: WideString;
begin
  FTexto := Texto;
  FPosicaoInicial := 1;
  FIniciado := False;
  Self.InicioTag := InicioTag;
  Self.FimTag := FimTag;
  RegEx := TRegExpr.Create;
  ExpRegular := StringReplace(ER_TAG, INICIO_TAG, Self.InicioTag, []);
  ExpRegular := StringReplace(ExpRegular, FIM_TAG, Self.FimTag, []);
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

    Result.Texto := RegEx.Match[0];
    Result.PosicaoInicial := RegEx.MatchPos[0];
    FPosicaoInicial := RegEx.MatchPos[0] + RegEx.MatchLen[0];
  end;

  FExpEncontrada := RegEx.ExecPos(FPosicaoInicial);
end;

end.
