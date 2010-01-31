{
 * UClipboardWriteStream.pas
 *
 * Class that provides a TStream interface to use when writing data to the
 * Windows clipboard.
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
 * The Original Code is UClipboardWriteStream.pas
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


unit UClipboardWriteStream;

{$WARN UNSAFE_CODE OFF}

interface


uses
  // Delphi
  Classes, ActiveX;

type

  {
  TClipboardWriteStream:
    Write-only stream that stores data in clipboard.
  }
  TClipboardWriteStream = class(TMemoryStream)
  private
    fFmt: TClipFormat;
      {Clipboard format used to store data}
  public
    constructor Create(const Fmt: TClipFormat);
      {Class constructor. Creates instance of stream to write to clipboard in
      a specific format.
        @param Fmt [in] Required clipboard format.
      }
    destructor Destroy; override;
      {Class destructor. Updates clipboard and tears down object.
        @except EStreamError raised if can't allocate memory block for clipboard
          or can't access it.
      }
  end;


implementation


uses
  // Delphi
  Windows, Clipbrd;


resourcestring
  // Error messages
  sCantAlloc = 'Can''t allocate memory block for clipboard format %0.8X';
  sCantGetPtr = 'Can''t get pointer to memory block for clipboard format %0.8X';
  sCantRead = 'Can''t read from a clipboard write stream';


{ TClipboardWriteStream }

constructor TClipboardWriteStream.Create(const Fmt: TClipFormat);
  {Class constructor. Creates instance of stream to write to clipboard in a
  specific format.
    @param Fmt [in] Required clipboard format.
  }
begin
  inherited Create;
  fFmt := Fmt;
end;

destructor TClipboardWriteStream.Destroy;
  {Class destructor. Updates clipboard and tears down object.
    @except EStreamError raised if can't allocate memory block for clipboard or
      can't access it.
  }
var
  GH: HGLOBAL;    // global memory handle for clipboard data block
  Ptr: Pointer;   // pointer to buffer used to pass data to clipboard
begin
  try
    // Get memory block: raise exception if can't do this
    GH := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, Self.Size);
    if GH = 0 then
      raise EStreamError.CreateFmt(sCantAlloc, [fFmt]);
    // Lock block to get pointer: raise exception & free mem if can't do so
    Ptr := GlobalLock(GH);
    if not Assigned(Ptr) then
    begin
      GlobalFree(GH);
      raise EStreamError.CreateFmt(sCantGetPtr, [fFmt]);
    end;
    try
      // Copy stream contents to clipboard memory block
      Move(Memory^, Ptr^, Self.Size);
      // Hand block over to clipboard
      Clipboard.SetAsHandle(fFmt, GH);
    finally
      // Unlock block - don't free mem since clipboard now owns it
      GlobalUnlock(GH);
    end;
  finally
    inherited;
  end;
end;

end.

