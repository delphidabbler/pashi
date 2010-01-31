{
 * UUtils.pas
 *
 * Various utility routines.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is UUtils.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2006-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UUtils;


interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  // Delphi
  Windows;


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

end.

