unit ULoop;

interface

uses
  Classes, Contnrs, UParametro;

type
  TLoopEvent = procedure(Sender: TObject; Loop: String; var FimLoop: Boolean) of object;

  TLoop = class(TParametro)
  private
    FNome: String;
    procedure SetNome(const Value: String);
    function GetParametros(const Nome: WideString): WideString;
    procedure SetParametros(const Nome, Value: WideString);
  public
    property Nome: String read FNome write SetNome;
    property Parametros[const Nome: WideString]: WideString read GetParametros write SetParametros; default;

    function ToString: WideString; override;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TLoop }

constructor TLoop.Create;
begin

end;

destructor TLoop.Destroy;
begin

  inherited;
end;

function TLoop.GetParametros(const Nome: WideString): WideString;
begin

end;

procedure TLoop.SetNome(const Value: String);
begin
  FNome := Value;
end;

procedure TLoop.SetParametros(const Nome, Value: WideString);
begin

end;

function TLoop.ToString: WideString;
begin

end;

end.
