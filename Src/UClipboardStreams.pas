{
 * UClipboardStreams.pas
 *
 * Defines objects that can read and write the clipboard via a TStream
 * interface.
 *
 * v1.0 of 28 May 2005  - Original version.
 * v1.1 of 29 May 2009  - Corrected error where required clipboard format was
 *                        beging ignored and CF_TEXT always used in its place.
 *                      - Removed all but $WARN compiler directives.
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
 * The Original Code is UClipboardStreams.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


unit UClipboardStreams;

{$WARN UNSAFE_TYPE OFF}

interface


uses
  // Delphi
  Classes, Windows;


type

  {
  TClipboardReadStream:
    Enables reading of clipboard data of a specified format using a TStream
    interface. Since clipboard data cannot be altered by writing, the Write
    method raises an exception.
  }
  TClipboardReadStream = class(TCustomMemoryStream)
  private
    fPBuf: Pointer;   // Pointer to start of clipboard data memory block
    fClipH: THandle;  // Handle to clipboard data
  public
    constructor Create(const Fmt: Cardinal);
      {Class constructor: creates memory stream onto clipboard data.
        @param Fmt [in] Required clipboard format.
        @except Exception raised when required clipboard format unavailable.
      }
    destructor Destroy; override;
      {Class destructor: tears down object and releases clipboard data.
      }
    function Write(const Buffer; Count: Longint): Longint; override;
      {Raise exception: this is a read only stream.
        @param Buffer [in] unused.
        @param Count [in] unused.
        @return No return value due to exception.
        @except EStreamError always raised when method is called.
      }
  end;

  {
  TClipboardWriteStream:
    Enables writing of data to clipboard in a single specified format using a
    TStream interface. Written data can be read back, but any existing data on
    clipboard cannot be read - use TClipboardReadStream for this purpose.
  }
  TClipboardWriteStream = class(TMemoryStream)
  private
    fFmt: UINT; // Clipboard format to used to store data
  public
    constructor Create(const Fmt: Cardinal);
      {Class constructor: creates instance of stream for specified clipboard
      format.
        @param Fmt [in] Required clipboard format.
      }
    destructor Destroy; override;
      {Class destructor: updates clipboard and tears down object.
        @except Exception raised if can't allocate memory block for clipboard or
          can't access it.
      }
  end;


implementation


uses
  // Project
  UClipboardMgr;


{ TClipboardReadStream }

resourcestring
  // Error messages
  sCantOpenFmt = 'Can''t open format clipboard format %0.8X for reading';
  sCantWrite = 'Can''t write to a clipboard read stream';

constructor TClipboardReadStream.Create(const Fmt: Cardinal);
  {Class constructor: creates memory stream onto clipboard data.
    @param Fmt [in] Required clipboard format.
    @except Exception raised when required clipboard format unavailable.
  }
var
  Size: Integer;            // size of buffer in clipboard
  ClipMgr: TClipboardMgr;   // object that accesses clipboard data
begin
  inherited Create;
  // Get a handle to the memory where the RTF code or text is stored
  ClipMgr := TClipboardMgr.Create;
  try
    fClipH := ClipMgr.GetDataHandle(Fmt);
  finally
    ClipMgr.Free;
  end;
  if fClipH = 0 then
    raise EStreamError.CreateFmt(sCantOpenFmt, [Fmt]);
  // Get a pointer to clipboard memory block and record its size
  fPBuf := GlobalLock(fClipH);
  Size := GlobalSize(fClipH);
  // Set the inherited stream's pointer to the clipboard memory block
  SetPointer(fPBuf, Size);
end;

destructor TClipboardReadStream.Destroy;
  {Class destructor: tears down object and releases clipboard data.
  }
begin
  // Unlock the clipboard memory handle
  if fClipH <> 0 then
    GlobalUnlock(fClipH);
  inherited;
end;

function TClipboardReadStream.Write(const Buffer; Count: Integer): Longint;
  {Raise exception: this is a read only stream.
    @param Buffer [in] unused.
    @param Count [in] unused.
    @return No return value due to exception.
    @except EStreamError always raised when method is called.
  }
begin
  raise EStreamError.Create(sCantWrite);
end;


{ TClipboardWriteStream }

resourcestring
  // Error messages
  sCantAlloc = 'Can''t allocate memory block for clipboard format %0.8X';
  sCantGetPtr = 'Can''t get pointer to memory block for clipboard format %0.8X';
  sCantRead = 'Can''t read from a clipboard write stream';

constructor TClipboardWriteStream.Create(const Fmt: Cardinal);
  {Class constructor: creates instance of stream for specified clipboard format.
    @param Fmt [in] Required clipboard format.
  }
begin
  inherited Create;
  // Store clipboard format to be used
  fFmt := Fmt;
end;

destructor TClipboardWriteStream.Destroy;
  {Class destructor: updates clipboard and tears down object.
    @except Exception raised if can't allocate memory block for clipboard or
      can't access it.
  }
var
  GH: HGLOBAL;              // global memory handle for clipboard data block
  Ptr: Pointer;             // pointer to buffer used to pass data to clipboard
  ZeroChar: Char;           // stores character #0 for terminating stream
  ClipMgr: TClipboardMgr;   // object that stores data in clipboard
begin
  try
    // Write a terminating #0 character to stream
    // this terminates string data correctly and has no effect if writer has
    // written required length of data - reader will simply ignore excess byte
    // (note that we can't tell exact size of data stored in clipboard)
    ZeroChar := #0;
    Write(ZeroChar, SizeOf(ZeroChar));
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
      ClipMgr := TClipboardMgr.Create;
      try
        ClipMgr.SetDataHandle(fFmt, GH);
      finally
        ClipMgr.Free;
      end;
    finally
      // Unlock block - don't free mem since clipboard now owns it
      GlobalUnlock(GH);
    end;
  finally
    inherited;
  end;
end;

end.

