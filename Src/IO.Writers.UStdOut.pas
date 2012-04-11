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
 * Provides a class that can write output data to standard output
}


unit IO.Writers.UStdOut;

interface

uses
  SysUtils,
  IO.UTypes;

type
  TStdOutWriter = class(TInterfacedObject, IOutputWriter)
  public
    procedure Write(const S: string; const Encoding: TEncoding);
  end;

implementation

uses
  UStdIO;

{ TStdOutWriter }

procedure TStdOutWriter.Write(const S: string; const Encoding: TEncoding);
var
  Bytes: TBytes;
  Preamble: TBytes;
begin
  Preamble := Encoding.GetPreamble;
  Bytes := Encoding.GetBytes(S);
  if Length(Preamble) > 0 then
    TStdIO.Write(stdOut, Pointer(Preamble)^, Length(Preamble));
  TStdIO.Write(stdOut, Pointer(Bytes)^, Length(Bytes));
end;

end.

