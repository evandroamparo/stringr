{ replace all occurence of "MyObject" with your object name }
unit {UnitName};

interface

uses
  Windows, Messages, SysUtils, Classes;

type
  T{MyObject} = class(TObject)
  private
    { Private declarations }
  public
    constructor Create;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  {MyObject}: T{MyObject};

implementation

{ Object constructor }
constructor T{MyObject}.Create;
begin
  inherited Create;
  { enter your code here }
end;

destructor T{MyObject}.Destroy;
begin
  { enter your code here }
  inherited;
end;

end.
