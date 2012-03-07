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
 * Provides a method only record that provides methods to assist with IO
 * operations.
}


unit IO.UHelper;

interface

uses
  SysUtils;

type
  TIOHelper = record
  public
    class function FileToBytes(const FileName: string): TBytes; static;
    class function BytesToString(const Bytes: TBytes): string; static;
    class function FileToString(const FileName: string): string; static;
  end;

implementation

uses
  Classes;

{ TIOHelper }

class function TIOHelper.BytesToString(const Bytes: TBytes): string;
var
  Encoding: TEncoding;
  PreambleSize: Integer;
begin
  Encoding := nil;
  PreambleSize := TEncoding.GetBufferEncoding(Bytes, Encoding);
  try
    // get text using required encoding
    Result := Encoding.GetString(
      Bytes, PreambleSize, Length(Bytes) - PreambleSize
    );
  finally
    if Assigned(Encoding) and not TEncoding.IsStandardEncoding(Encoding) then
      Encoding.Free;
  end;
end;

class function TIOHelper.FileToBytes(const FileName: string): TBytes;
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Result, FS.Size);
    FS.ReadBuffer(Pointer(Result)^, FS.Size);
  finally
    FS.Free;
  end;
end;

class function TIOHelper.FileToString(const FileName: string): string;
begin
  Result := BytesToString(FileToBytes(FileName));
end;

end.
