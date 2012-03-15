unit UAtributoFormat;

interface

uses
  UAtributo;
type
  TAtributoFormat = class(TAtributo)
  public
    function Transformar(const ValorParametro: TDateTime): WideString; reintroduce;
  end;

implementation

uses
  SysUtils;

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

end.
