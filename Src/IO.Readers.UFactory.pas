unit IO.Readers.UFactory;

interface

uses
  SysUtils,
  IO.UTypes, UConfig;

type
  TInputReaderFactory = record
  public
    class function Instance(const InputSource: TInputSource;
      const Encoding: TEncoding = nil): IInputReader;
      static;
  end;

implementation

uses
  IO.Readers.UStdIn, IO.Readers.UClipboard;

{ TInputReaderFactory }

class function TInputReaderFactory.Instance(const InputSource: TInputSource;
  const Encoding: TEncoding): IInputReader;
begin
  case InputSource of
    isStdIn: Result := TStdInReader.Create(Encoding);
    isClipboard: Result := TClipboardReader.Create;
  else
    Result := nil;
  end;
  Assert(Assigned(Result), 'TInputReaderFactory.Instance: Result is nil');
end;

end.
