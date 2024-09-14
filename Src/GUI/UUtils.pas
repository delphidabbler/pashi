{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2022, Peter Johnson (www.delphidabbler.com).
 *
 * Various utility routines.
}


unit UUtils;


interface


uses
  // Delphi
  System.Classes,
  Winapi.Windows;


function IsDirectory(const DirName: string): Boolean;

function TaskAllocWideString(const S: string): PWChar;

function StringFromStream(const Stm: TStream): string;

function ListFiles(const Dir, Wildcard: string; const List: TStrings): Boolean;

function IsStrInList(const Str: string; const List: array of string;
  CaseSensitive: Boolean): Boolean;


implementation


uses
  // Delphi
  System.SysUtils,
  Winapi.ActiveX;


function IsDirectory(const DirName: string): Boolean;
var
  Attr: Integer;  // directory's file attributes
begin
  Attr := FileGetAttr(DirName);
  Result := (Attr <> -1)
    and (Attr and faDirectory = faDirectory);
end;

function TaskAllocWideString(const S: string): PWChar;
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

function ListFiles(const Dir, Wildcard: string; const List: TStrings): Boolean;
var
  FileSpec: string;         // search file specification
  SR: System.SysUtils.TSearchRec;  // file search result
  Success: Integer;         // success code for FindXXX routines
begin
  Assert(Assigned(List));
  // Check if true directory and exit if not
  Result := IsDirectory(Dir);
  if not Result then
    Exit;
  // Build file spec from directory and wildcard
  FileSpec := IncludeTrailingPathDelimiter(Dir);
  if Wildcard = '' then
    FileSpec := FileSpec + '*.*'
  else
    FileSpec := FileSpec + Wildcard;
  // Initialise search for matching files
  Success := FindFirst(FileSpec, faAnyFile, SR);
  try
    // Loop for all files in directory
    while Success = 0 do
    begin
      // only add true files or directories to list
      if (SR.Name <> '.') and (SR.Name <> '..') then
        List.Add(SR.Name);
      // get next file
      Success := FindNext(SR);
    end;
  finally
    // Tidy up
    FindClose(SR);
  end;
end;

function IsStrInList(const Str: string; const List: array of string;
  CaseSensitive: Boolean): Boolean;
var
  TestFn: function(const A, B: string): Boolean;
  Elem: string;
begin
  if CaseSensitive then
    TestFn := SameStr
  else
    TestFn := SameText;
  Result := False;
  for Elem in List do
    if TestFn(Elem, Str) then
      Exit(True);
end;

end.

