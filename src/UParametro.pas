unit UParametro;

interface

uses
  UStringr, Contnrs, UElemento, UAtributo;

type
  TParametro = class(TElemento)
  private
    FNome: String;
    FValor: WideString;
    FAtributos: TObjectList;
    procedure SetNome(const Value: String);
    procedure SetValor(const Value: WideString);
  public
    property Nome: String read FNome write SetNome;
    property Valor: WideString read FValor write SetValor;
    procedure NovoAtributo(Atributo: TAtributo);
    function ToString: WideString; override;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses UAtributoCase, UAtributoFormat, UAtributoLength, SysUtils;

{ TParametro }

constructor TParametro.Create;
begin
  inherited;
  FAtributos := TObjectList.Create;
  FAtributos.OwnsObjects := True;
end;

destructor TParametro.Destroy;
begin
  FAtributos.Free;
  inherited;
end;

procedure TParametro.NovoAtributo(Atributo: TAtributo);
begin
  if (Atributo is TAtributoFormat) then
    FAtributos.Insert(0, Atributo)
  else
    FAtributos.Add(Atributo);
end;

procedure TParametro.SetNome(const Value: String);
begin
   FNome := Value;
end;

procedure TParametro.SetValor(const Value: WideString);
begin
  FValor := Value;
end;

function TParametro.ToString: WideString;
var
  i: Integer;
begin
  if (LowerCase(Nome) = 'date') then
    FValor := DateToStr(Date)
  else if (LowerCase(Nome) = 'time') then
    FValor := TimeToStr(Time)
  else if (LowerCase(Nome) = 'datetime') then
    FValor := DateTimeToStr(Now);

  Result := FValor;

//  if Valor <> '' then
    for i := 0 to FAtributos.Count - 1 do
    begin
      if (FAtributos[i] is TAtributoFormat) then
      begin
        if (LowerCase(Nome) = 'date') then
          Result := (FAtributos[i] as TAtributoFormat).Transformar(Date)
        else if (LowerCase(Nome) = 'time') then
          Result := (FAtributos[i] as TAtributoFormat).Transformar(Time)
        else if (LowerCase(Nome) = 'datetime') then
          Result := (FAtributos[i] as TAtributoFormat).Transformar(Now);
      end
      else if (FAtributos[i] is TAtributoLength) then
        Result := (FAtributos[i] as TAtributoLength).Transformar(Result)
      else if (FAtributos[i] is TAtributoCase) then
        Result := (FAtributos[i] as TAtributoCase).Transformar(Result);
    end;
end;

end.
