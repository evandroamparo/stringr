unit UListaTemplate;

interface

type

  TListaTemplate = class(TInterfacedObject)
  private
    FNome: String;
    procedure SetNome(const Value: String);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  public
    property Nome: String read FNome write SetNome;
  end;

implementation

{ TListaTemplate }

procedure TListaTemplate.SetNome(const Value: String);
begin
  FNome := Value;
end;

end.
