{
 * UStdIOStreams.pas
 *
 * Defines objects that can read from standard input and write to standard
 * output via a TStream interface.
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
 * The Original Code is UStdIOStreams.pas.
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


unit UStdIOStreams;

{$WARN UNSAFE_TYPE OFF}

interface


uses
  // Delphi
  Classes;


type

  {
  TStdInStream:
    Enables reading from standard input using a TStream interface. Since
    standard input is read only and serial, the Write and Seek methods raise
    exceptions.
  }
  TStdInStream = class(TStream)
  public
    function Read(var Buffer; Count: Longint): Longint; override;
      {Reads data from standard input into a buffer.
        @param Buffer [in] Buffer into which data is to be read.
        @param Count [in] Number of bytes to read.
        @return Number of bytes actually read.
      }
    function Write(const Buffer; Count: Longint): Longint; override;
      {Raises exception since standard input is read only.
        @param Buffer [in] Unused.
        @param Count [in] Unused.
        @return No return value due to exception.
        @except EStreamError always raised when method is called.
      }
    function Seek(Offset: Longint; Origin: Word): Longint; override;
      {Raises exception since standard input is serial.
        @param Offset [in] Unused.
        @param Origin [in] Unused.
        @return No return value due to exception.
        @except EStreamError always raised when method called.
      }
  end;

  {
  TStdOutStream:
    Enables writing to standard output using a TStream interface. Since standard
    output is write only and serial, the Read and Seek methods raise
    exceptions.
  }
  TStdOutStream = class(TStream)
  public
    function Read(var Buffer; Count: Longint): Longint; override;
      {Raises exception since standard output is write only.
        @param Buffer [in] Unused.
        @param Count [in] Unused.
        @return No return value due to exception.
        @except EStreamError Always raised when method is called.
      }
    function Write(const Buffer; Count: Longint): Longint; override;
      {Writes data from a buffer to standard output.
        @param Buffer [in] Buffer from which data is to be written.
        @param Count [in] Number of bytes to write.
        @return Number of bytes actually written.
      }
    function Seek(Offset: Longint; Origin: Word): Longint; override;
      {Raises exception since standard output is serial.
        @param Offset [in] Unused.
        @param Origin [in] Unused.
        @return No return value due to exception.
        @except EStreamError always raised when method called.
      }
  end;


implementation


uses
  // Project
  UStdIO;


{ TStdInStream }

function TStdInStream.Read(var Buffer; Count: Integer): Longint;
  {Reads data from standard input into a buffer.
    @param Buffer [in] Buffer into which data is to be read.
    @param Count [in] Number of bytes to read.
    @return Number of bytes actually read.
  }
begin
  Result := TStdIO.ReadBuf(Buffer, Count);
end;

function TStdInStream.Seek(Offset: Integer; Origin: Word): Longint;
  {Raises exception since standard input is serial.
    @param Offset [in] Unused.
    @param Origin [in] Unused.
    @return No return value due to exception.
    @except EStreamError always raised when method called.
  }
begin
  raise EStreamError.Create('Can''t seek on serial standard input');
end;

function TStdInStream.Write(const Buffer; Count: Integer): Longint;
  {Raises exception since standard input is read only.
    @param Offset [in] Unused.
    @param Origin [in] Unused.
    @return No return value due to exception.
    @except EStreamError always raised when method is called.
  }
begin
  raise EStreamError.Create('Can''t write to standard output');
end;


{ TStdOutStream }

function TStdOutStream.Read(var Buffer; Count: Integer): Longint;
  {Raises exception since standard output is write only.
    @param Offset [in] Unused.
    @param Origin [in] Unused.
    @return No return value due to exception.
    @except EStreamError always raised when method is called.
  }
begin
  raise EStreamError.Create('Can''t read from standard output');
end;

function TStdOutStream.Seek(Offset: Integer; Origin: Word): Longint;
  {Raises exception since standard output is serial.
    @param Offset [in] Unused.
    @param Origin [in] Unused.
    @return No return value due to exception.
    @except EStreamError always raised when method called.
  }
begin
  raise EStreamError.Create('Can''t seek on serial standard output');
end;

function TStdOutStream.Write(const Buffer; Count: Integer): Longint;
  {Writes data from a buffer to standard output.
    @param Buffer [in] Buffer from which data is to be written.
    @param Count [in] Number of bytes to write.
    @return Number of bytes actually written.
  }
begin
  // Write the buffer to standard output
  TStdIO.Write(stdOut, Buffer, Count);
  // Assume all written (sometimes there's any error if we don't do this)
  Result := Count;
end;

end.

