unit IO.UTypes;

interface

uses
  SysUtils;

type
  IInputReader = interface
    ['{0E702A31-2D93-48D7-98F7-76823C209FF9}']
    function Read(const Encoding: TEncoding): string;
  end;

type
  IOutputWriter = interface
    ['{09FB5F10-AD74-41D4-AFBA-A0100819C2BF}']
    procedure Write(const S: string; const Encoding: TEncoding);
  end;

implementation

end.
