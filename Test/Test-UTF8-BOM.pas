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
  S: string;
begin
  Result := '';
  while not EOF do
  begin
    ReadLn(Input, S);
    Result := Result + S + CRLF;
  end;
end;

end.
