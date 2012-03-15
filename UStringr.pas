unit UStringr;

interface

uses
  Classes, RegExpr, Generics.Collections, Contnrs, SysUtils, UElemento;

type
  ETemplateError = class(Exception);

  TStringr = class
  private
    FElementos: TObjectList;
    FTexto: WideString;
    function GetElementos(const Indice: Integer): TElemento;
    procedure SetElementos(const Indice: Integer; const Value: TElemento);
    procedure SetTexto(const Value: WideString);
  public
    property Texto: WideString read FTexto write SetTexto;
    property Elementos[const Indice: Integer]: TElemento read GetElementos write SetElementos;
    procedure NovoElemento(Elemento: TElemento);
    procedure RemoveElemento(const Indice: Integer); overload;
    procedure RemoveElemento(Elemento: TElemento); overload;
    function ToString: WideString; reintroduce;

    constructor Create;
    destructor Destroy; override;
  end;


implementation

uses
  Windows, StrUtils;

{ TTemplate }

constructor TStringr.Create;
begin
  FElementos := TObjectList.Create;
end;

destructor TStringr.Destroy;
begin
  FElementos.Free;
  inherited;
end;

function TStringr.GetElementos(const Indice: Integer): TElemento;
begin
  if not (Indice in [0..FElementos.Count - 1]) then
    raise ERangeError.CreateFmt('Índice do elemento fora do intervalo (%d)', [Indice]);

  Result := FElementos[Indice] as TElemento;
end;

procedure TStringr.NovoElemento(Elemento: TElemento);
begin
  FElementos.Add(Elemento);
end;

procedure TStringr.RemoveElemento(Elemento: TElemento);
begin
  FElementos.Remove(Elemento);
end;

procedure TStringr.RemoveElemento(const Indice: Integer);
begin
  if not (Indice in [0..FElementos.Count - 1]) then
    raise ERangeError.CreateFmt('Índice do elemento fora do intervalo(%d)', [Indice]);

  FElementos.Delete(Indice);
end;

procedure TStringr.SetElementos(const Indice: Integer; const Value: TElemento);
begin
  if not (Indice in [0..FElementos.Count - 1]) then
    raise ERangeError.CreateFmt('Índice do elemento fora do intervalo(%d)', [Indice]);

  FElementos[Indice] := Value;
end;

procedure TStringr.SetTexto(const Value: WideString);
begin
  FTexto := Value;
end;

function TStringr.ToString: WideString;
begin

end;

end.
