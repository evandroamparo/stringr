unit UStringr;

interface

uses
  Classes;

type
  TDataHora = (dhData, dhHora);

  TStringr = class
    FTemplate: String;
    FParams: TStringList;
  private
    const DATE_PARAM = 'Date';
    const TIME_PARAM = 'Time';
    function GetParams(const Param: string): String;
    procedure SetParams(const Param, Value: String);

  protected
    procedure ProcessSpecialParams;
    procedure ProcessDateTime(DataHora: TDataHora);
  public
    property Params[const Param: string]: String read GetParams write SetParams; default;
    constructor Create(Template: String);
    destructor Destroy; override;
    function Render: String;
  end;

implementation

uses
  Windows, SysUtils, StrUtils;

{ TStringr }

constructor TStringr.Create(Template: String);
begin
  FTemplate := Template;
  FParams := TStringList.Create;
end;

destructor TStringr.Destroy;
begin
  FreeAndNil(FParams);
end;

function TStringr.GetParams(const Param: string): String;
begin
  Result := FParams.Values[Param];
end;

procedure TStringr.ProcessDateTime(DataHora: TDataHora);
var
  PosInicialParamentro, PosInicialFormato, PosFinal, i: Integer;
  Parametro, Formato: String;
  ParamName, ParamValue: string;
begin
  case DataHora of
    dhData: ParamName := DATE_PARAM;
    dhHora: ParamName := TIME_PARAM;
  end;

  FTemplate := StringReplace(FTemplate, '{' + ParamName + '}', DateToStr(Date),
      [rfReplaceAll, rfIgnoreCase]);

  PosFinal := 0;

  while AnsiContainsText(FTemplate, '{' + ParamName + ':') do
  begin
    Formato := '';
    PosInicialParamentro :=
        AnsiPos(AnsiUpperCase('{' + ParamName + ':'),
                AnsiUpperCase(FTemplate)) + 1;
    for i := PosInicialParamentro + 1 to Length(FTemplate) do
    begin
      if FTemplate[i] = '}' then
      begin
        PosFinal := i;
        Parametro := Copy(FTemplate,
                          PosInicialParamentro - 1,
                          PosFinal - PosInicialParamentro + 2);
        Break;
      end;
    end;
    for i := 1 to Length(Parametro) do
    begin
      if Parametro[i] = ':' then
      begin
        PosInicialFormato := i + 1;
        Formato := Copy(Parametro, PosInicialFormato, Length(Parametro) - PosInicialFormato);
        Break;
      end;
    end;
    if Formato <> '' then
      case DataHora of
        dhData: ParamValue := FormatDateTime(Formato, Date);
        dhHora: ParamValue := FormatDateTime(Formato, Time);
      end;
      FTemplate := StuffString(
                      FTemplate,
                      PosInicialParamentro - 1,
                      PosFinal - PosInicialParamentro + 3,
                      ParamValue);
  end;

  FTemplate := StringReplace(FTemplate, '{time}', TimeToStr(Time),
      [rfReplaceAll, rfIgnoreCase]);
end;

procedure TStringr.ProcessSpecialParams;
var
  PosInicialParamentro, PosInicialFormato, PosFinal, i: Integer;
  Parametro, Formato: String;
begin
  ProcessDateTime(dhData);
  ProcessDateTime(dhHora);
end;

function TStringr.Render: String;
var
  i: Integer;
begin
  { TODO : Processar parâmetros que estão no template mas não tem valor definido:
           renderizar como '' }
  ProcessSpecialParams;

  for i := 0 to FParams.Count - 1 do
  begin
    FTemplate := StringReplace(FTemplate, FParams.Names[i], FParams.ValueFromIndex[i],
      [rfReplaceAll, rfIgnoreCase]);
  end;
  Result := FTemplate;
end;

procedure TStringr.SetParams(const Param, Value: String);
begin
  FParams.Values['{' + Param + '}'] := Value;
end;

end.
