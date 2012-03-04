{
 * UTextStreamReader.pas
 *
 * Defines class that performs character based access to a stream.
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
 * The Original Code is UTextStreamReader.pas.
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


unit UTextStreamReader;


interface


uses
  // Delphi
  Classes,
  // Project
  UCharStack;


const
  // Special character codes
  cEOL = #10;   // end of line
  cEOF = #0;    // end of file


type

  {
  TTextStreamReader:
    Class that performs character based access to a stream. Characters can be
    put back on the stream. CRLF pairs are converted on the fly to single EOL
    character. The class is written to work correctly with serial streams, i.e.
    those that do not support Seek or Size.
  }
  TTextStreamReader = class(TObject)
  private
    fPutBackStack: TCharStack;  // Stack for pushed back and retrieved chars
    fCh: AnsiChar;              // Character last read from stream
    fStm: TStream;              // Reference to stream being read
    function GetNextChar: AnsiChar;
      {Gets next character from stream or push back stack if it contains
      characters.
        @return Required character or cEOF if end of file.
      }
    procedure UngetChar(ACh: AnsiChar);
      {Logically puts back a character onto the stream.
        @param ACh [in] Character to be put back.
      }
  public
    constructor Create(const Stm: TStream);
      {Class constructor: create reader for a stream and read first character.
        @param Stm [in] Stream to be read.
      }
    destructor Destroy; override;
      {Class destructor: tears down object.
      }
    function NextChar: AnsiChar;
      {Fetches next character from buffer, translating CRLF into single EOL
      character.
        @return Character read (cEOF at end of buffer).
      }
    procedure PutBackChar;
      {Puts the last read character back on the stream.
      }
    property Ch: AnsiChar read fCh;
      {Last character read from stream or cEOF if at end of stream}
  end;


implementation


const
  // Private character constants for detecting end of line
  cCR = #13;    // CR
  cLF = cEOL;   // LF = #10


{ TTextStreamReader }

constructor TTextStreamReader.Create(const Stm: TStream);
  {Class constructor: create reader for a stream and read first character.
    @param Stm [in] Stream to be read.
  }
begin
  inherited Create;
  // Create put back stack and record stream we're reading
  fPutBackStack := TCharStack.Create;
  fStm := Stm;
  // Fetch first character from stream
  NextChar;
end;

destructor TTextStreamReader.Destroy;
  {Class destructor: tears down object.
  }
begin
  fPutBackStack.Free;
  inherited;
end;

function TTextStreamReader.GetNextChar: AnsiChar;
  {Gets next character from stream or push back stack if it contains characters.
    @return Required character or cEOF if end of file.
  }
begin
  if fPutBackStack.Count = 0 then
  begin
    // Get next character from stream, checking for EOF
    if fStm.Read(Result, SizeOf(Result)) = 0 then
      Result := cEOF;
  end
  else
    // Get next character from put back stack
    Result := fPutBackStack.Pop;
  // Record character in Ch property
  fCh := Result;
end;

function TTextStreamReader.NextChar: AnsiChar;
  {Fetches next character from buffer, translating CRLF into single EOL
  character.
    @return Character read (cEOF at end of buffer).
  }
var
  TempCh: AnsiChar; // stores look ahead character
begin
  // Get character from stream or put back stack
  Result := GetNextChar;
  if Result = cCR then
  begin
    // We have CR - check if followed by LF and swallow if so
    TempCh := GetNextChar;
    if TempCh <> cLF then
      UngetChar(TempCh);
  end;
  if Result in [cCR, cLF] then
    // We have CR or LF - return special EOL char
    Result := cEOL;
end;

procedure TTextStreamReader.PutBackChar;
  {Puts the last read character back on the stream.
  }
begin
  UngetChar(fCh);
end;

procedure TTextStreamReader.UngetChar(ACh: AnsiChar);
  {Logically puts back a character onto the stream.
    @param ACh [in] Character to be put back.
  }
begin
  fPutBackStack.Push(ACh);
end;

end.

