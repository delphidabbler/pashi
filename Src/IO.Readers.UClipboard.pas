unit IO.Readers.UClipboard;

interface

uses
  IO.UTypes;

type
  TClipboardReader = class(TInterfacedObject, IInputReader)
  public
    function Read: string;
  end;

implementation

uses
  Windows, ClipBrd;

{ TClipboardReader }

function TClipboardReader.Read: string;
begin
  if not Clipboard.HasFormat(CF_UNICODETEXT) then
    Exit('');
  Result := Clipboard.AsText;
end;

end.
