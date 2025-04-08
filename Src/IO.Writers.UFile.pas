{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Provides a class that can write output data to a file
}


unit IO.Writers.UFile;

interface

uses
  System.SysUtils,
  IO.UTypes;

type
  TFileWriter = class(TInterfacedObject, IOutputWriter)
  strict private
    var
      fFileName: string;
  public
    constructor Create(const FileName: string);
    procedure Write(const S: string; const Encoding: TEncoding);
  end;

implementation

uses
  System.Classes;

{ TFileWriter }

constructor TFileWriter.Create(const FileName: string);
begin
  inherited Create;
  fFileName := FileName;
end;

procedure TFileWriter.Write(const S: string; const Encoding: TEncoding);
var
  Bytes: TBytes;
  FS: TFileStream;
  Preamble: TBytes;
begin
  Preamble := Encoding.GetPreamble;
  Bytes := Encoding.GetBytes(S);
  FS := TFileStream.Create(fFileName, fmCreate);
  try
    if Length(Preamble) > 0 then
      FS.WriteBuffer(Pointer(Preamble)^, Length(Preamble));
    FS.WriteBuffer(Pointer(Bytes)^, Length(Bytes));
  finally
    FS.Free;
  end;
end;

end.

