unit UElemento;

interface

type
  TElemento = class abstract
  private
    FTexto: WideString;
    FPosicaoInicial: Integer;
    procedure SetTexto(const Value: WideString);
    procedure SetPosicaoInicial(const Value: Integer);
  public
    property PosicaoInicial: Integer read FPosicaoInicial write SetPosicaoInicial;
    property Texto: WideString read FTexto write SetTexto;
    function ToString: WideString; reintroduce; virtual; abstract;
  end;

implementation

{ TElemento }

procedure TElemento.SetPosicaoInicial(const Value: Integer);
begin
  FPosicaoInicial := Value;
end;

procedure TElemento.SetTexto(const Value: WideString);
begin
  FTexto := Value;
end;

end.
