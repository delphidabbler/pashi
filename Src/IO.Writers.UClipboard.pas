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
 * Provides a class that can write output data to the clipboard
}


unit IO.Writers.UClipboard;

interface

uses
  SysUtils,
  IO.UTypes;

type
  TClipboardWriter = class(TInterfacedObject, IOutputWriter)
  public
    procedure Write(const S: string; const Encoding: TEncoding);
  end;

implementation

uses
  Windows,
  UClipboardMgr, UClipboardStreams;

{ TClipboardWriter }

procedure TClipboardWriter.Write(const S: string; const Encoding: TEncoding);
var
  GH: HGLOBAL;    // global memory handle for clipboard data block
  Ptr: Pointer;   // pointer to buffer used to pass data to clipboard
  DataSize: Integer;
  ClipMgr: TClipboardMgr;
resourcestring
  sCantAlloc = 'Can''t allocate memory block for clipboard';
  sCantGetPtr = 'Can''t get pointer to memory block for clipboard';
begin
  // TODO: make a general "Add" method in TClipboardMgr with this code
  DataSize := (Length(S) + 1) * SizeOf(Char);
  // Allocate buffer to store data to on clipboard
  GH := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, DataSize);
  if GH = 0 then
    raise EInOutError.Create(sCantAlloc);
  // Lock block to get pointer: raise exception & free mem if can't do so
  Ptr := GlobalLock(GH);
  if not Assigned(Ptr) then
  begin
    GlobalFree(GH);
    raise EInOutError.Create(sCantGetPtr);
  end;
  // Copy string to clipboard memory block
  try
    Move(PChar(S)^, Ptr^, DataSize); // this copies data + terminating #0
    // Hand block over to clipboard
    ClipMgr := TClipboardMgr.Create;
    try
      ClipMgr.SetDataHandle(CF_UNICODETEXT, GH);
    finally
      ClipMgr.Free;
    end;
  finally
    // Unlock block - don't free mem since clipboard now owns it
    GlobalUnlock(GH);
  end;
end;

end.
