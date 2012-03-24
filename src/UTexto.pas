unit UTexto;

interface

uses
  UElemento;

type
  TTexto = class(TElemento)
  public
    function ToString: WideString; override;
  end;

implementation

{ TTexto }

function TTexto.ToString: WideString;
begin
  Result := Texto;
end;

end.
