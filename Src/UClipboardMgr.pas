{
 * UClipboardMgr.pas
 *
 * Defines a lightweight object that accesses and saves clipboard data. Used to
 * avoid overhead of ClipBrd unit.
 *
 * $Rev$
 * $Date$
 *
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
 * The Original Code is UClipboardMgr.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
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

