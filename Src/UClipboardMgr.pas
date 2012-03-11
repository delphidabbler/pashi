{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Defines a lightweight object that accesses and saves clipboard data. Used to
 * avoid significant overhead of VCL's ClipBrd unit.
}


unit UClipboardMgr;


interface


uses
  // Project
  Messages;


type

  {
  TClipboardMgr:
    Lightweight clipboard access object that gets data from clipboard and stores
    data in it and handles opening and closing of clipboard.
  }
  TClipboardMgr = class(TObject)
  private
    fClipWdw: THandle;  // Handle to window used to receive clipboard messages
    procedure Open;
      {Opens clipboard if closed.
      }
    procedure Close;
      {Closes clipboard if open.
      }
    procedure WndProc(var Msg: TMessage);
      {Window procedure for our clipboard window.
        @param Msg [in/out] Message passed to window procedure.
      }
  public
    function GetDataHandle(const Fmt: Cardinal): THandle;
      {Gets handle to data on clipboard with given format.
        @param Fmt [in] Required clipboard format.
        @return handle to required data on clipboard.
      }
    procedure SetDataHandle(const Fmt: Cardinal; const Data: THandle);
      {Stores data on clipboard in a required format.
        @param Fmt [in] Type of clipboard format to used.
        @param Data [in] Handle to data to store on clipboard.
      }
  end;


implementation


uses
  // Project
  SysUtils, Classes, Windows;


{ TClipboardMgr }

procedure TClipboardMgr.Close;
  {Closes clipboard if open.
  }
begin
  // If we have a clipboard window, close clipboard and release window
  if fClipWdw <> 0 then
  begin
    Windows.CloseClipboard;
    Classes.DeallocateHWnd(fClipWdw);
    fClipWdw := 0;
  end;
end;

function TClipboardMgr.GetDataHandle(const Fmt: Cardinal): THandle;
  {Gets handle to data on clipboard with given format.
    @param Fmt [in] Required clipboard format.
    @return handle to required data on clipboard.
  }
begin
  // Open clipboard, get data from windows then close clipboard
  Open;
  try
    Result := Windows.GetClipboardData(Fmt);
  finally
    Close;
  end;
end;

procedure TClipboardMgr.Open;
  {Opens clipboard if closed.
  }
resourcestring
  sError = 'Can''t open clipboard';
begin
  // Create window to receive clipbaord messages if we don't have one
  if fClipWdw = 0 then
  begin
    fClipWdw := Classes.AllocateHWnd(WndProc);
    // Try to open clipboard, raising exception on error
    if not OpenClipboard(fClipWdw) then
      raise Exception.Create(sError);
  end;
end;

procedure TClipboardMgr.SetDataHandle(const Fmt: Cardinal;
  const Data: THandle);
  {Stores data on clipboard in a required format.
    @param Fmt [in] Type of clipboard format to used.
    @param Data [in] Handle to data to store on clipboard.
  }
begin
  // Open clipboard
  Open;
  try
    // Empty clipboard and store data in it
    Windows.EmptyClipboard;
    if Windows.SetClipboardData(Fmt, Data) = 0 then
      SysUtils.RaiseLastOSError;
  finally
    // Close clipboard
    Close;
  end;
end;

procedure TClipboardMgr.WndProc(var Msg: TMessage);
  {Window procedure for our clipboard window.
    @param Msg [in/out] Message passed to window procedure.
  }
begin
  // Pass all messages to default handler
  with Msg do
    Result := DefWindowProc(fClipWdw, Msg, wParam, lParam);
end;

end.

