unit UAtributoCase;

interface

uses
  UAtributo;
type
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

implementation

uses
  SysUtils;

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

end.
