unit UCustomParser;

interface

uses
  UElemento, SysUtils;

type
  ICustomParser = interface
    procedure Inicializa(const Texto: WideString);
    function ContemElemento: Boolean;
    function ProximoElemento: TElemento;
  end;

implementation

end.
