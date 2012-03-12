{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Various utility routines.
}


unit UUtils;


interface


uses
  // Delphi
  Classes, Windows;


function IsDirectory(const DirName: string): Boolean;
  {Checks if a directory exists.
    @param DirName [in] Name of directory to check.
    @return True if DirName is valid directory.
  }

function TaskAllocWideString(const S: string): PWChar;
  {Converts an ANSI string to a wide string and stores it in a buffer allocated
  by the Shell's task allocator. Caller is responsible for freeing the buffer
  and must use shell's allocator to do this.
    @param S [in] ANSI string to convert.
    @return Pointer to buffer containing wide string.
  }

function StringFromStream(const Stm: TStream): string;

implementation


uses
  // Delphi
  SysUtils, ActiveX;


function IsDirectory(const DirName: string): Boolean;
  {Checks if a directory exists.
    @param DirName [in] Name of directory to check.
    @return True if DirName is valid directory.
  }
var
  Attr: Integer;  // directory's file attributes
begin
  Attr := FileGetAttr(DirName);
  Result := (Attr <> -1)
    and (Attr and faDirectory = faDirectory);
end;

function TaskAllocWideString(const S: string): PWChar;
  {Converts an ANSI string to a wide string and stores it in a buffer allocated
  by the Shell's task allocator. Caller is responsible for freeing the buffer
  and must use shell's allocator to do this.
    @param S [in] ANSI string to convert.
    @return Pointer to buffer containing wide string.
  }
var
  StrLen: Integer;  // length of string in bytes
begin
  // Store length of string allowing for terminal #0
  StrLen := Length(S) + 1;
  // Alloc buffer for wide string using task allocator
  Result := CoTaskMemAlloc(StrLen * SizeOf(WideChar));
  if Assigned(Result) then
    // Convert string to wide string and store in buffer
    StringToWideChar(S, Result, StrLen);
end;

function StringFromStream(const Stm: TStream): string;
var
  Bytes: TBytes;
  Encoding: TEncoding;
  PreambleSize: Integer;
begin
  SetLength(Bytes, Stm.Size);
  if Length(Bytes) = 0 then
    Exit('');
  Stm.Position := 0;
  Stm.ReadBuffer(Pointer(Bytes)^, Length(Bytes));
  Encoding := nil;
  PreambleSize := TEncoding.GetBufferEncoding(Bytes, Encoding);
  try
    Result := Encoding.GetString(
      Bytes, PreambleSize, Length(Bytes) - PreambleSize
    );
  finally
    if not TEncoding.IsStandardEncoding(Encoding) then
      Encoding.Free;
  end;
end;

end.

