unit UStringr;

interface

uses
  Classes;

type
  TStringr = class
    FTemplate: String;
    FParams: TStringList;
  private
    function GetParams(const Param: string): String;
    procedure SetParams(const Param, Value: String);
  public
    property Params[const Param: string]: String read GetParams write SetParams; default;
    constructor Create(Template: String);
    destructor Destroy; override;
    function Render: String;
  end;

implementation

uses
  Windows, SysUtils;

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

function TStringr.Render: String;
var
  i: Integer;
begin
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
