unit UAtributo;

interface

type
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

implementation

{ TAtributo }

procedure TAtributo.SetNome(const Value: WideString);
begin
  FNome := Value;
end;

procedure TAtributo.SetValor(const Value: WideString);
begin
  FValor := Value;
end;

end.
