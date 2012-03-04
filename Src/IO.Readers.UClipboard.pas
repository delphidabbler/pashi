unit IO.Readers.UClipboard;

interface

uses
  SysUtils,
  IO.UTypes;

type
  TClipboardReader = class(TInterfacedObject, IInputReader)
  public
    function Read(const Encoding: TEncoding): string;
  end;

implementation

uses
  Windows, ClipBrd;

{ TClipboardReader }

function TClipboardReader.Read(const Encoding: TEncoding): string;
begin
  // encoding is ignored: always Unicode
  if not Clipboard.HasFormat(CF_UNICODETEXT) then
    Exit('');
  Result := Clipboard.AsText;
end;

end.
