{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Provides a class that can read input data from the clipboard.
}


unit IO.Readers.UClipboard;

interface

uses
  System.SysUtils,
  IO.UTypes;

type
  TClipboardReader = class(TInterfacedObject, IInputReader)
  public
    function Read: TArray<string>;
  end;

implementation

uses
  Winapi.Windows,
  UClipboardMgr;

{ TClipboardReader }

function TClipboardReader.Read: TArray<string>;
var
  ClipMgr: TClipboardMgr;
  DataHandle: THandle;
  Data: PChar;
begin
  ClipMgr := TClipboardMgr.Create;
  try
    DataHandle := ClipMgr.GetDataHandle(CF_UNICODETEXT);
  finally
    ClipMgr.Free;
  end;
  if DataHandle = 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  // Get a pointer to clipboard memory block and record its size
  Data := GlobalLock(DataHandle);
  try
    SetLength(Result, 1);
    Result[0] := Data;
  finally
    GlobalUnlock(DataHandle);
  end;
end;

end.

