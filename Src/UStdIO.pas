{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2012, Peter Johnson (www.delphidabbler.com).
 *
 * Static class that outputs to standard output and standard error and inputs
 * from standard input.
}


unit UStdIO;


interface


type

  {
  TStdIOOutput:
    Enumeration of available output "channels" - standard output or standard
    error.
  }
  TStdIOOutput = (stdOut, stdErr);

  {
  TStdIO:
    Static class that outputs to standard output and standard error and inputs
    from standard input.
  }
  TStdIO = class(TObject)
  private
    class function GetHandle(Channel: TStdIOOutput): THandle;
      {Gets Windows handle of an output channel.
        @param Channel [in] The required channel.
        @return Required Windows handle.
      }
  public
    class procedure Write(Channel: TStdIOOutput; const Buffer;
      const Size: Integer); overload;
      {Write data from a buffer to an output channel.
        @param Channel [in] Required output channel.
        @param Buffer [in] Contains data to be written.
        @param Size [in] Size of data in buffer in bytes.
      }
    class function ReadBuf(var Buffer; const Count: Integer): Integer;
      {Read data from standard input to a buffer.
        @param Buffer [in] Buffer to receive data.
        @param Count [in] Maximum number of bytes to read into buffer.
        @return Number of bytes actually read.
      }
  end;


implementation


uses
  // Delphi
  Windows;


{ TStdIO }

class function TStdIO.GetHandle(Channel: TStdIOOutput): THandle;
  {Gets Windows handle of an output channel.
    @param Channel [in] The required channel.
    @return Required Windows handle.
  }
const
  cHandles: array[TStdIOOutput] of DWORD = (
    STD_OUTPUT_HANDLE, STD_ERROR_HANDLE
  );  // maps output channels onto windows handle identifier
begin
  Result := Windows.GetStdHandle(cHandles[Channel]);
end;

class function TStdIO.ReadBuf(var Buffer; const Count: Integer): Integer;
  {Read data from standard input to a buffer.
    @param Buffer [in] Buffer to receive data.
    @param Count [in] Maximum number of bytes to read into buffer.
    @return Number of bytes actually read.
  }
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
  Windows.ReadFile(
    GetStdHandle(STD_INPUT_HANDLE), Buffer, Count, BytesRead, nil
  );
  Result := BytesRead;
end;

class procedure TStdIO.Write(Channel: TStdIOOutput; const Buffer;
  const Size: Integer);
  {Write data from a buffer to an output channel.
    @param Channel [in] Required output channel.
    @param Buffer [in] Contains data to be written.
    @param Size [in] Size of data in buffer in bytes.
  }
var
  Dummy: Cardinal;  // Unused param for Windows.WriteFile
begin
  // Write the data
  Windows.WriteFile(GetHandle(Channel), Buffer, Size, Dummy, nil);
end;

end.

