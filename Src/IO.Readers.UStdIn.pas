unit IO.Readers.UStdIn;

interface

uses
  SysUtils,
  IO.UTypes;

type
  TStdInReader = class(TInterfacedObject, IInputReader)
  public
    function Read(const Encoding: TEncoding): string;
  end;

implementation

uses
  UConsts, UStdIO;

{ TStdInReader }

function TStdInReader.Read(const Encoding: TEncoding): string;
const
  ChunkSize = 1024 * 16;
var
  Buffer: TBytes;
  Data: TBytes;
  BytesRead: Cardinal;
  TotalBytes: Cardinal;
  Offset: Cardinal;
begin
  // read data from stdin to Data in chunks
  SetLength(Buffer, ChunkSize);
  TotalBytes := 0;
  repeat
    BytesRead := TStdIO.ReadBuf(Buffer[0], ChunkSize);
    if BytesRead = 0 then
      Break;
    Offset := TotalBytes;
    Inc(TotalBytes, BytesRead);
    SetLength(Data, TotalBytes);
    Move(Buffer[0], Data[Offset], BytesRead);
  until False;
  // Data now contains all data from stdin
  Result := Encoding.GetString(Data);
end;

end.
