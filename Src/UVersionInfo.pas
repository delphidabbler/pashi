{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014-2022, Peter Johnson (www.delphidabbler.com).
 *
 * Gets details of host program's version number from its version information
 * resources.
}


unit UVersionInfo;


interface


///  <summary>Gets the file version number from version information of the host
///  program.</summary>
function GetFileVersionStr: string;

///  <summary>Gets the legal copyright string from version information of the
///  host program.</summary>
function GetLegalCopyright: string;


implementation


uses
  // Delphi
  SysUtils, Windows;


function GetFileVersionStr: string;
var
  Dummy: DWORD;           // unused variable required in API calls
  VerInfoSize: Integer;   // size of version information data
  VerInfoBuf: Pointer;    // buffer holding version information
  ValPtr: Pointer;        // pointer to a version information value
  FFI: TVSFixedFileInfo;  // fixed file information from version info
begin
  Result := '';
  // Get fixed file info (FFI) from program's version info
  // get size of version info
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize > 0 then
  begin
    // create buffer and read version info into it
    GetMem(VerInfoBuf, VerInfoSize);
    try
      if GetFileVersionInfo(
        PChar(ParamStr(0)), Dummy, VerInfoSize, VerInfoBuf
      ) then
      begin
        // read FFI from version info
        if VerQueryValue(VerInfoBuf, '\', ValPtr, Dummy) then
        begin
          FFI := PVSFixedFileInfo(ValPtr)^;
          // Build version info string from file version fields of FFI
          Result := Format(
            '%d.%d.%d',
            [
              HiWord(FFI.dwFileVersionMS),
              LoWord(FFI.dwFileVersionMS),
              HiWord(FFI.dwFileVersionLS)
            ]
          );
        end
      end;
    finally
      FreeMem(VerInfoBuf);
    end;
  end;
end;

function GetLegalCopyright: string;
var
  Ptr: Pointer;                       // pointer to result of API call
  Len: UINT;                          // length of structure returned from API
  VerInfoSize: Integer;               // size of version information data
  VerInfoBuf: Pointer;                // buffer holding version information
  Dummy: DWORD;                       // unused variable required in API calls
const
  // Sub-block identifying copyright info
  SubBlock = '\StringFileInfo\080904E4\LegalCopyright';
begin
  Result := '';
  // get size of version info
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize <= 0 then
    Exit;
  // create buffer and read version info into it
  GetMem(VerInfoBuf, VerInfoSize);
  try
    if not GetFileVersionInfo(
      PChar(ParamStr(0)), Dummy, VerInfoSize, VerInfoBuf
    ) then Exit;
    if not VerQueryValue(VerInfoBuf, SubBlock, Ptr, Len) then
      Exit;
    Result := PChar(Ptr);
  finally
    FreeMem(VerInfoBuf);
  end;
end;

end.
