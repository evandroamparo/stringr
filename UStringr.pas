unit UStringr;

interface

uses
  RegExpr, Contnrs, SysUtils, UElemento, Classes, UCustomParser, UTexto;

type
  ETemplateError = class(Exception);

  TStringr = class
  private
    FParametros: TStringList;
    FTexto: WideString;
    FParser: ICustomParser;
    procedure SetTexto(const Value: WideString);
    function GetParametros(const Nome: WideString): WideString;
    procedure SetParametros(const Nome, Valor: WideString);
    procedure SetParser(const Value: ICustomParser);
    procedure CheckParser(Parser: ICustomParser);
  public
    property Parser: ICustomParser read FParser write SetParser;
    property Texto: WideString read FTexto write SetTexto;
    property Parametros[const Nome: WideString]: WideString read GetParametros write SetParametros; default;
    function ToString: WideString; reintroduce;

    constructor Create(Parser: ICustomParser); overload;
    destructor Destroy; override;
  end;


implementation

uses
  Windows, StrUtils, UParametro;

{ TTemplate }

procedure TStringr.CheckParser(Parser: ICustomParser);
begin
  if not Assigned(Parser) then
    raise ETemplateError.Create('Parser não definido.');
end;

constructor TStringr.Create(Parser: ICustomParser);
begin
  CheckParser(Parser);
  FParser := Parser;
  FParametros := TStringList.Create;
end;

destructor TStringr.Destroy;
begin
  FParametros.Free;
  inherited;
end;

function TStringr.GetParametros(const Nome: WideString): WideString;
begin
  Result := FParametros.Values[WideLowerCase(Nome)];
end;

procedure TStringr.SetParametros(const Nome, Valor: WideString);
var
  NovoNome: WideString;
begin
  NovoNome := WideLowerCase(Nome);

  if (NovoNome <> 'date') and
     (NovoNome <> 'time') and
     (NovoNome <> 'datetime') then
    FParametros.Values[NovoNome] := Valor;
end;

procedure TStringr.SetParser(const Value: ICustomParser);
begin
  FParser := Value;
end;

procedure TStringr.SetTexto(const Value: WideString);
begin
  FTexto := Value;
end;

function TStringr.ToString: WideString;
var
  Elemento: TElemento;
begin
  CheckParser(FParser);

  Result := '';

  FParser.Inicializa(FTexto);

  while FParser.ContemElemento do
  begin
    Elemento := FParser.ProximoElemento;
    if Elemento is TTexto then
      Result := Result + Elemento.ToString
    else if Elemento is TParametro then
    begin
      (Elemento as TParametro).Valor :=
        FParametros.Values[WideLowerCase((Elemento as TParametro).Nome)];
      Result := Result + Elemento.ToString;
    end;
  end;
end;

end.
