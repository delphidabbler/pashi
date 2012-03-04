{
 * UMain.pas
 *
 * Implements class that executes program.
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
 * The Original Code is UMain.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2007-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UMain;


interface


uses
  // Delphi
  Classes,
  // Project
  Hiliter.UGlobals, UConfig, UConsole;


type

  {
  TMain:
    Class that executes program.
  }
  TMain = class(TObject)
  private
    fConfig: TConfig;     // Program configurations object
    fConsole: TConsole;   // Object used to write to console
    fSignedOn: Boolean;   // Flag shows if sign on message has been displayed
    procedure Configure;
      {Configure program from command line.
      }
    procedure SignOn;
      {Writes sign on message to console.
      }
    procedure ShowHelp;
      {Writes help text to console.
      }
    function GetInputSourceCode: string;
      {Reads program input as a string.
        @return Required input string.
      }
    function CreateOutputStream: TStream;
      {Creates stream that receives program output.
        @return Required output stream.
      }
    function CreateHiliter: ISyntaxHiliter;
      {Creates required syntax highlighter, depending on document type.
        @return Required highlighter object.
      }
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    procedure Execute;
      {Executes program.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Windows,
  // Project
  IO.UTypes, IO.Readers.UFactory,
  UClipboardStreams, UParams, UStdIOStreams, Hiliter.UHiliters;


{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
function GetProductVersionStr: string;
  {Gets the program's product version number from version information.
    @return Version number as a dot delimited string.
  }
var
  Dummy: DWORD;           // unused variable required in API calls
  VerInfoSize: Integer;   // size of version information data
  VerInfoBuf: Pointer;    // buffer holding version information
  ValPtr: Pointer;        // pointer to a version information value
  FFI: TVSFixedFileInfo;  // fixed file information from version info
begin
  Result := '';
  // Get fixed file info from program's version info
  // get size of version info
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize > 0 then
  begin
    // create buffer and read version info into it
    GetMem(VerInfoBuf, VerInfoSize);
    try
      if GetFileVersionInfo(
        PChar(ParamStr(0)), Dummy, VerInfoSize, VerInfoBuf
      ) then
      begin
        // get fixed file info from version info (ValPtr points to it)
        if VerQueryValue(VerInfoBuf, '\', ValPtr, Dummy) then
        begin
          FFI := PVSFixedFileInfo(ValPtr)^;
          // Build version info string from product version field of FFI
          Result := Format(
            '%d.%d.%d',
            [
              HiWord(FFI.dwProductVersionMS),
              LoWord(FFI.dwProductVersionMS),
              HiWord(FFI.dwProductVersionLS)
            ]
          );
        end
      end;
    finally
      FreeMem(VerInfoBuf);
    end;
  end;
end;
{$WARN UNSAFE_CODE ON}
{$WARN UNSAFE_TYPE OFF}


resourcestring
  // Messages written to console
  sCompleted = 'Completed';
  sError = 'Error: %s';
  sUsage = 'Usage: PasHi ([-rc] [-wc] [-frag | -hidecss] [-q] ) | -h';
  sHelp =
      '  -rc      | Takes input from clipboard instead of standard input.'#13#10
    + '  -wc      | Writes HTML output to clipboard (CF_TEXT format) instead '
    + 'of '#13#10
    + '           | standard output.'#13#10
    + '  -frag    | Writes HTML fragment rather than complete XHTML '
    + 'document'#13#10
    + '           | contains only <pre> tag containing source - user must '
    + 'provide a'#13#10
    + '           | style sheet with required names. Do not use with '
    + '-hidecss'#13#10
    + '  -hidecss | Protects embedded CSS style in HTML comments (required '
    + 'for some'#13#10
    + '           | old browsers). Do not use with -frag.'#13#10
    + '  -q       | Quiet mode - does not write to console.'#13#10
    + '  -h       | Displays help screen (quiet mode ignored).'#13#10
    + #13#10
    + 'Input is read from standard input and highlighted HTML code is written '
    + 'to'#13#10
    + 'standard output unless -rc or -wc switches are used.'#13#10
    + 'If -frag and -hidecss are used together, last one used takes '
    + 'precedence.';

{ TMain }

procedure TMain.Configure;
  {Configure program from command line.
  }
var
  Params: TParams;  // object that gets configuration from command line
begin
  Params := TParams.Create(fConfig);
  try
    Params.Parse; // parse command line, updating configuration object
  finally
    FreeAndNil(Params);
  end;
end;

constructor TMain.Create;
  {Class constructor. Sets up object.
  }
begin
  fConfig := TConfig.Create;
  fConsole := TConsole.Create;
  inherited;
end;

function TMain.CreateHiliter: ISyntaxHiliter;
  {Creates required syntax highlighter, depending on document type.
    @return Required highlighter object.
  }
begin
  Result := nil;
  case fConfig.DocType of
    dtXHTML:
      Result := TSyntaxHiliterFactory.CreateHiliter(hkXHTML);
    dtXHTMLHideCSS:
      Result := TSyntaxHiliterFactory.CreateHiliter(hkXHTMLHideCSS);
    dtXHTMLFragment:
      Result := TSyntaxHiliterFactory.CreateHiliter(hkHTMLFragment)
  end;
  Assert(Assigned(Result), 'TMain.CreateHiliter: Invalid document format');
end;

function TMain.CreateOutputStream: TStream;
  {Creates stream that receives program output.
    @return Required output stream.
  }
begin
  Result := nil;
  case fConfig.OutputSink of
    osStdOut: Result := TStdOutStream.Create;
    osClipboard: Result := TClipboardWriteStream.Create(CF_TEXT);
  end;
  Assert(Assigned(Result), 'TMain.CreateOutputStream: Unknown output format');
end;

destructor TMain.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fConsole);
  FreeAndNil(fConfig);
  inherited;
end;

procedure TMain.Execute;
  {Executes program.
  }
var
  InSrc: string;            // string containing input Pascal source
  OutStm: TStream;          // stream onto output highlighted source
  OutCode: string;          // highlighted output as string
  Hiliter: ISyntaxHiliter;  // highlighter object
  Bytes: TBytes;
begin
  ExitCode := 0;
  try
    // Configure program
    Configure;
    // Decide if program is to write to console
    fConsole.Silent := fConfig.Quiet and not fConfig.ShowHelp;
    if fConfig.ShowHelp then
      // Want help so show it
      ShowHelp
    else
    begin
      // Sign on and initialise program
      SignOn;
      OutStm := nil;
      try
        InSrc := GetInputSourceCode;
        OutStm := CreateOutputStream;
        Hiliter := CreateHiliter;
        // Analyse Pascal code on input stream, highlight it, then write output
        OutCode := Hiliter.Hilite(InSrc);
        Bytes := TEncoding.Default.GetBytes(OutCode);
        OutStm.WriteBuffer(Pointer(Bytes)^, Length(Bytes));

      finally
        // Close input and output streams
        FreeAndNil(OutStm);
      end;
      // Sign off
      fConsole.WriteLn(sCompleted);
    end;
  except
    // Report any errors
    on E: Exception do
    begin
      if not fSignedOn then
        SignOn;
      fConsole.WriteLn(Format(sError, [E.Message]));
      ExitCode := 1;
    end;
  end;
end;

function TMain.GetInputSourceCode: string;
var
  Reader: IInputReader;
begin
  // TODO: permit user to specify encoding for stdin
  Reader := TInputReaderFactory.Instance(
    fConfig.InputSource, TEncoding.Default
  );
  Result := Reader.Read;
end;

procedure TMain.ShowHelp;
  {Writes help text to console.
  }
begin
  SignOn;
  fConsole.WriteLn;
  fConsole.WriteLn(sUsage);
  fConsole.WriteLn;
  fConsole.WriteLn(sHelp);
end;

procedure TMain.SignOn;
  {Writes sign on message to console.
  }
resourcestring
  // Sign on message format string
  sSignOn = 'PasHi %s by DelphiDabbler (www.delphidabbler.com)';
var
  Msg: string;  // sign on message text
begin
  // Create and write sign on message
  Msg := Format(sSignOn, [GetProductVersionStr]);
  fConsole.WriteLn(Msg);
  // underline sign-on message with dashes
  fConsole.WriteLn(StringOfChar('-', Length(Msg)));
  // record that we've signed on
  fSignedOn := True;
end;

end.

