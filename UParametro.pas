unit UParametro;

interface

uses
  UStringr, Contnrs, UElemento, UAtributo;

type
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

implementation

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

end.
