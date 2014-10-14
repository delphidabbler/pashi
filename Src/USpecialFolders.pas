{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Provides access to locations of Windows special folders.
}


unit USpecialFolders;

interface

uses
  ShlObj;

type
  TSpecialFolders = record
  strict private
    class procedure FreePIDL(PIDL: PItemIDList); static;
    class function PIDLToFolderPath(PIDL: PItemIDList): string; static;
    class function SpecialFolderPath(CSIDL: Integer): string; static;
  public
    class function UserAppData: string; static;
    class function CommonAppData: string; static;
  end;

implementation

uses
  SysUtils, Windows, ActiveX;

{ TSpecialFolders }

class function TSpecialFolders.CommonAppData: string;
begin
  Result := SpecialFolderPath(CSIDL_COMMON_APPDATA);
end;

class procedure TSpecialFolders.FreePIDL(PIDL: PItemIDList);
var
  Malloc: IMalloc;  // shell's allocator
begin
  if Succeeded(SHGetMalloc(Malloc)) then
    Malloc.Free(PIDL);
end;

class function TSpecialFolders.PIDLToFolderPath(PIDL: PItemIDList): string;
begin
  SetLength(Result, MAX_PATH);
  if SHGetPathFromIDList(PIDL, PChar(Result)) then
    Result := PChar(Result)
  else
    Result := '';
end;

class function TSpecialFolders.SpecialFolderPath(CSIDL: Integer): string;
var
  PIDL: PItemIDList;  // PIDL of the special folder
begin
  Result := '';
  if Succeeded(SHGetSpecialFolderLocation(0, CSIDL, PIDL)) then
  begin
    try
      Result := ExcludeTrailingPathDelimiter(PIDLToFolderPath(PIDL));
    finally
      FreePIDL(PIDL);
    end;
  end
end;

class function TSpecialFolders.UserAppData: string;
begin
  Result := SpecialFolderPath(CSIDL_APPDATA);
end;

end.
