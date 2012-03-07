{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Provides a class that can read input data from standard input.
}


unit IO.Readers.UStdIn;

interface

uses
  SysUtils,
  IO.UTypes;

type
  TStdInReader = class(TInterfacedObject, IInputReader)
  public
    function Read: string;
  end;

implementation

uses
  UConsts, UStdIO, IO.UHelper;

{ TStdInReader }

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
  // convert to string, detecting encoding
  Result := TIOHelper.BytesToString(Data);
end;

end.
