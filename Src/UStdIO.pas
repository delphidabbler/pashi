{
 * UStdIO.pas
 *
 * Static class that outputs to standard output and standard error and inputs
 * from standard input.
 *
 * v1.0 of 09 Dec 2005  - Original version.
 * v1.1 of 29 May 2009  - Removed all except $WARN compiler directives.
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
 * The Original Code is UStdIO.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


unit UStdIO;

{$WARN UNSAFE_TYPE OFF}

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
    class procedure Write(Channel: TStdIOOutput; const Text: string); overload;
      {Write text to a channel.
        @param Channel [in] Required output channel.
        @param Text [in] Text to be written.
      }
    class procedure WriteLn(Channel: TStdIOOutput; const Text: string);
      overload;
      {Write text to a channel followed by a new line.
        @param Channel [in] Required output channel.
        @param Text [in] Text to be written.
      }
    class procedure WriteLn(Channel: TStdIOOutput); overload;
      {Write a new line to a channel.
        @param Channel [in] Required output channel.
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

class procedure TStdIO.Write(Channel: TStdIOOutput; const Text: string);
  {Write text to a channel.
    @param Channel [in] Required output channel.
    @param Text [in] Text to be written.
  }
begin
  Write(Channel, Text[1], Length(Text));
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

class procedure TStdIO.WriteLn(Channel: TStdIOOutput; const Text: string);
  {Write text to a channel followed by a new line.
    @param Channel [in] Required output channel.
    @param Text [in] Text to be written.
  }
begin
  Write(Channel, Text + #13#10);
end;

class procedure TStdIO.WriteLn(Channel: TStdIOOutput);
  {Write a new line to a channel.
    @param Channel [in] Required output channel.
  }
begin
  WriteLn(Channel, '');
end;

end.

