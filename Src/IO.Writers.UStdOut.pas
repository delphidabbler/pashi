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
begin
  Bytes := Encoding.GetBytes(S);
  TStdIO.Write(stdOut, Pointer(Bytes)^, Length(Bytes));
end;

end.
