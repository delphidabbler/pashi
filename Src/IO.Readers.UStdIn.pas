unit IO.Readers.UStdIn;

interface

uses
  SysUtils,
  IO.UTypes;

type
  TStdInReader = class(TInterfacedObject, IInputReader)
  strict private
    var
      fEncoding: TEncoding;
  public
    constructor Create(const Encoding: TEncoding);
    destructor Destroy; override;
    function Read: string;
  end;

implementation

uses
  UConsts, UStdIO;

{ TStdInReader }

constructor TStdInReader.Create(const Encoding: TEncoding);
begin
  inherited Create;
  fEncoding := Encoding;
end;

destructor TStdInReader.Destroy;
begin
  if not TEncoding.IsStandardEncoding(fEncoding) then
    fEncoding.Free;
  inherited;
end;

function TStdInReader.Read: string;
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
  Result := fEncoding.GetString(Data);
end;

end.
