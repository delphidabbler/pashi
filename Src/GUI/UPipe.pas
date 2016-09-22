{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2016, Peter Johnson (www.delphidabbler.com).
 *
 * A class that encapsulates an unamed pipe that can read and write the pipe.
}


unit UPipe;


interface


uses
  // Delphi
  Classes;

type

  ///  <summary>Class that encapsulates an unamed pipe and can read and write
  ///  the pipe.</summary>
  TPipe = class(TObject)
  private
    fReadHandle: THandle;
    fWriteHandle: THandle;
  public
    constructor Create(const Size: LongWord = 0);
    destructor Destroy; override;
    function AvailableDataSize: LongWord;
    function ReadData(var Buf; const BufSize: LongWord;
      var BytesRead: LongWord): Boolean;
    procedure CopyToStream(const Stm: TStream; Count: LongWord = 0);
    procedure CopyFromStream(const Stm: TStream; Count: LongWord = 0);
    function WriteData(const Buf; const BufSize: LongWord): LongWord;
    procedure CloseWriteHandle;
    property ReadHandle: THandle read fReadHandle;
    property WriteHandle: THandle read fWriteHandle;
  end;


implementation


uses
  // Delphi
  SysUtils, Windows;


resourcestring
  // Error messages
  sBadReadHandle  = 'Can''t read pipe: handle closed';
  sCantPeekPipe   = 'Can''t read pipe: peek attempt failed';
  sPipeReadError  = 'Error reading pipe';
  sBadWriteHandle = 'Can''t write to stream: handle closed';


{ TPipe }

function TPipe.AvailableDataSize: LongWord;
begin
  if fReadHandle = 0 then
    raise EInOutError.Create(sBadReadHandle);
  if not PeekNamedPipe(fReadHandle, nil, 0, nil, @Result, nil) then
    raise EInOutError.Create(sCantPeekPipe);
end;

procedure TPipe.CloseWriteHandle;
begin
  if fWriteHandle <> 0 then
  begin
    CloseHandle(fWriteHandle);
    fWriteHandle := 0;
  end;
end;

procedure TPipe.CopyFromStream(const Stm: TStream; Count: LongWord);
var
  BytesToWrite: LongWord;       // adjusted number of bytes to write
  Buf: array[0..4095] of Byte;  // buffer used in copying from pipe to stream
begin
  // Determine how much to copy
  if Count = 0 then
    Count := Stm.Size - Stm.Position;
  // Copy data one bufferful at a time
  while Count > 0 do
  begin
    if Count > SizeOf(Buf) then
      BytesToWrite := SizeOf(Buf)
    else
      BytesToWrite := Count;
    Stm.ReadBuffer(Buf, BytesToWrite);
    WriteData(Buf, BytesToWrite);
    Dec(Count, BytesToWrite);
  end;
end;

procedure TPipe.CopyToStream(const Stm: TStream; Count: LongWord);
var
  AvailBytes: LongWord;           // number of bytes in pipe
  BytesToRead: LongWord;          // decreasing count of remaining bytes
  BytesRead: LongWord;            // bytes read in each loop
  Buf: array[0..4095] of Byte;    // buffer used to read from stream
begin
  // Determine how much should be read
  AvailBytes := AvailableDataSize;
  if (Count = 0) or (Count > AvailBytes) then
    Count := AvailBytes;
  // Copy data one bufferful at a time
  while Count > 0 do
  begin
    if Count > SizeOf(Buf) then
      BytesToRead := SizeOf(Buf)
    else
      BytesToRead := Count;
    ReadData(Buf, BytesToRead, BytesRead);
    if BytesRead <> BytesToRead then
      raise EInOutError.Create(sPipeReadError);
    Stm.WriteBuffer(Buf, BytesRead);
    Dec(Count, BytesRead);
  end;
end;

constructor TPipe.Create(const Size: LongWord = 0);
var
  Security: TSecurityAttributes;  // file's security attributes
begin
  inherited Create;
  // Set up security structure so file handle is inheritable (for Windows NT)
  Security.nLength := SizeOf(Security);
  Security.lpSecurityDescriptor := nil;
  Security.bInheritHandle := True;
  // Create the pipe
  CreatePipe(fReadHandle, fWriteHandle, @Security, Size);
end;

destructor TPipe.Destroy;
begin
  CloseHandle(fReadHandle);
  CloseWriteHandle;
  inherited;
end;

function TPipe.ReadData(var Buf; const BufSize: LongWord;
  var BytesRead: LongWord): Boolean;
var
  BytesToRead: DWORD;   // number of bytes to actually read
begin
  BytesToRead := AvailableDataSize;
  if BytesToRead > 0 then
  begin
    if BytesToRead > BufSize then
      BytesToRead := BufSize;
    ReadFile(fReadHandle, Buf, BytesToRead, BytesRead, nil);
    Result := BytesRead > 0;
  end
  else
    Result := False;
end;

function TPipe.WriteData(const Buf; const BufSize: LongWord): LongWord;
begin
  if fWriteHandle = 0 then
    raise EInOutError.Create(sBadWriteHandle);
  WriteFile(fWriteHandle, Buf, BufSize, Result, nil);
end;

end.

