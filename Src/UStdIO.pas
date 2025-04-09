{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Static class that outputs to standard output and standard error and inputs
 * from standard input.
}


unit UStdIO;


interface


type

  ///  <summary>Enumeration of available output 'channels' - standard output or
  ///  standard error.</summary>
  TStdIOOutput = (stdOut, stdErr);

  ///  <summary>Static class that outputs to standard output and standard error
  ///  and inputs from standard input.</summary>
  TStdIO = class(TObject)
  private
    class function GetHandle(Channel: TStdIOOutput): THandle;
  public
    class procedure Write(Channel: TStdIOOutput; const Buffer;
      const Size: Integer); overload;
    class function ReadBuf(var Buffer; const Count: Integer): Integer;
  end;


implementation


uses
  // Delphi
  Winapi.Windows;


{ TStdIO }

class function TStdIO.GetHandle(Channel: TStdIOOutput): THandle;
const
  cHandles: array[TStdIOOutput] of DWORD = (
    STD_OUTPUT_HANDLE, STD_ERROR_HANDLE
  );  // maps output channels onto windows handle identifier
begin
  Result := Winapi.Windows.GetStdHandle(cHandles[Channel]);
end;

class function TStdIO.ReadBuf(var Buffer; const Count: Integer): Integer;
var
  BytesRead: Cardinal;  // Number of bytes actually read
begin
  if Count = 0 then
  begin
    // No bytes required - nothing to do
    Result := 0;
    Exit;
  end;
  // Read from std input into buffer
  Winapi.Windows.ReadFile(
    GetStdHandle(STD_INPUT_HANDLE), Buffer, Count, BytesRead, nil
  );
  Result := BytesRead;
end;

class procedure TStdIO.Write(Channel: TStdIOOutput; const Buffer;
  const Size: Integer);
var
  Dummy: Cardinal;  // Unused param for Windows.WriteFile
begin
  // Write the data
  Winapi.Windows.WriteFile(GetHandle(Channel), Buffer, Size, Dummy, nil);
end;

end.

