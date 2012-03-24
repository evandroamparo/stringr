unit UAtributoLength;

interface

uses
  UAtributo;

type
  TAtributoLength = class(TAtributo)
  private
    FValor: Integer;
    procedure SetValor(const Value: Integer);
  public
    property Valor: Integer read FValor write SetValor;
    function Transformar(const ValorParametro: WideString): WideString; override;
  end;

implementation

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

end.
