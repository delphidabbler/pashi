{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Defines a lightweight object that accesses and saves clipboard data. Used to
 * avoid significant overhead of VCL's ClipBrd unit.
}


unit UClipboardMgr;


interface


uses
  // Project
  Winapi.Messages;


type

  ///  <summary>Lightweight clipboard access object that gets data from
  ///  clipboard and stores data in it and handles opening and closing of
  ///  clipboard.</summary>
  TClipboardMgr = class(TObject)
  private
    fClipWdw: THandle;  // Handle to window used to receive clipboard messages
    procedure Open;
    procedure Close;
    procedure WndProc(var Msg: TMessage);
  public
    function GetDataHandle(const Fmt: Cardinal): THandle;
    procedure SetDataHandle(const Fmt: Cardinal; const Data: THandle);
  end;


implementation


uses
  // Project
  System.SysUtils,
  System.Classes,
  Winapi.Windows;


{ TClipboardMgr }

procedure TClipboardMgr.Close;
begin
  // If we have a clipboard window, close clipboard and release window
  if fClipWdw <> 0 then
  begin
    Winapi.Windows.CloseClipboard;
    System.Classes.DeallocateHWnd(fClipWdw);
    fClipWdw := 0;
  end;
end;

function TClipboardMgr.GetDataHandle(const Fmt: Cardinal): THandle;
begin
  // Open clipboard, get data from windows then close clipboard
  Open;
  try
    Result := Winapi.Windows.GetClipboardData(Fmt);
  finally
    Close;
  end;
end;

procedure TClipboardMgr.Open;
resourcestring
  sError = 'Can''t open clipboard';
begin
  // Create window to receive clipbaord messages if we don't have one
  if fClipWdw = 0 then
  begin
    fClipWdw := System.Classes.AllocateHWnd(WndProc);
    // Try to open clipboard, raising exception on error
    if not OpenClipboard(fClipWdw) then
      raise Exception.Create(sError);
  end;
end;

procedure TClipboardMgr.SetDataHandle(const Fmt: Cardinal;
  const Data: THandle);
begin
  // Open clipboard
  Open;
  try
    // Empty clipboard and store data in it
    Winapi.Windows.EmptyClipboard;
    if Winapi.Windows.SetClipboardData(Fmt, Data) = 0 then
      System.SysUtils.RaiseLastOSError;
  finally
    // Close clipboard
    Close;
  end;
end;

procedure TClipboardMgr.WndProc(var Msg: TMessage);
begin
  // Pass all messages to default handler
  with Msg do
    Result := DefWindowProc(fClipWdw, Msg, wParam, lParam);
end;

end.

