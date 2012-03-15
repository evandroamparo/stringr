unit UCustomParser;

interface

uses
  UStringr, UElemento;

type
  TCustomParser = class abstract
  private
    FTexto: WideString;
    FFimTag: WideString;
    FInicioTag: WideString;
    FContemElemento: Boolean;
    procedure SetFimTag(const Value: WideString);
    procedure SetInicioTag(const Value: WideString);
    procedure SetContemElemento(const Value: Boolean);
  public
    property InicioTag: WideString read FInicioTag write SetInicioTag;
    property FimTag: WideString read FFimTag write SetFimTag;
    property ContemElemento: Boolean read FContemElemento write SetContemElemento;
    function ProximoElemento: TElemento; virtual; abstract;

    constructor Create(const Texto: WideString);
    destructor Destroy; override;
  end;

implementation

{ TCustomParser }

constructor TCustomParser.Create(const Texto: WideString);
begin
   FTexto := Texto;
end;

destructor TCustomParser.Destroy;
begin

  inherited;
end;

procedure TCustomParser.SetContemElemento(const Value: Boolean);
begin
  FContemElemento := Value;
end;

procedure TCustomParser.SetFimTag(const Value: WideString);
begin
  FFimTag := Value;
end;

procedure TCustomParser.SetInicioTag(const Value: WideString);
begin
  FInicioTag := Value;
end;

end.
