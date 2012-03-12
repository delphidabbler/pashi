{
 * UPasHi.pas
 *
 * Class that executes and communicates with PasHi.exe.
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
 * The Original Code is UPasHi.pas
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


unit UPasHi;


interface


uses
  // Delphi
  Classes,
  // Project
  UPipe;


type

  {
  TPasHi:
    Interacts with PasHi.exe to do syntax highlighting.
  }
  TPasHi = class(TObject)
  private
    fInPipe: TPipe;
      {Pipe to PasHi's standard input}
    fOutPipe: TPipe;
      {Pipe to PasHi's standard output}
    fOutStream: TStream;
      {Stream that receives PasHi's standard output}
    fErrPipe: TPipe;
      {Pipe to PasHi's standard error output}
    fConsoleOutputStream: TStringStream;
      {Stream that receives PasHi's standard error output}
    procedure HandleAppOutput(Sender: TObject);
      {Handles TConsoleApp's OnWork event and copies contents of output pipes to
      respective data streams.
        @param Sender [in] Not used.
      }
    function BuildCommandLine(const CreateFragment: Boolean): string;
      {Creates command line needed to execute PasHi.exe with required switches.
        @param CreateFragment [in] Flag indicating if code fragment (true) or
          complete HTML document to be generated.
        @return Required command line.
      }
    procedure RunPasHi(const CmdLine: string);
      {Executes PasHi with a given command line.
        @param CmdLine [in] PasHi command line.
        @except Exception raised if can't execute PasHi.exe.
      }
  public
    function Hilite(const SourceStream, HilitedStream: TStream;
      const CreateFragment: Boolean): Boolean;
      {Highlights source code by executing PasHi.exe with appropriate
      parameters.
        @param SourceStream [in] Stream containing raw source code (input to
          PasHi).
        @param HilitedStream [in] Stream that receives highlighted source code
          (output from PasHi).
        @param CreateFragment [in] Flag indicating if code fragment (true) or
          complete HTML document to be generated.
        @return True if program completed normally, false on error.
      }
    function ConsoleOutput: string;
      {Returns any text written by PasHi to console stderr}
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  UConsoleApp;


{ TPasHi }

function TPasHi.BuildCommandLine(const CreateFragment: Boolean): string;
  {Creates command line needed to execute PasHi.exe with required switches.
    @param CreateFragment [in] Flag indicating if code fragment (true) or
      complete HTML document to be generated.
    @return Required command line.
  }
begin
  // ** do not localise anything in this method
  Result := 'PasHi --encoding utf-8 ';
  if CreateFragment then
    Result := Result + '--doc-type xhtml-fragment'
  else
    Result := Result + '--doc-type xhtml';
end;

function TPasHi.ConsoleOutput: string;
begin
  Result := fConsoleOutputStream.DataString;
end;

procedure TPasHi.HandleAppOutput(Sender: TObject);
  {Handles TConsoleApp's OnWork event and copies contents of output pipes to
  respective data streams.
    @param Sender [in] Not used.
  }
begin
  fOutPipe.CopyToStream(fOutStream);
  fErrPipe.CopyToStream(fConsoleOutputStream);
end;

function TPasHi.Hilite(const SourceStream, HilitedStream: TStream;
  const CreateFragment: Boolean): Boolean;
  {Highlights source code by executing PasHi.exe with appropriate parameters.
    @param SourceStream [in] Stream containing raw source code (input to PasHi).
    @param HilitedStream [in] Stream that receives highlighted source code
      (output from PasHi).
    @param CreateFragment [in] Flag indicating if code fragment (true) or
      complete HTML document to be generated.
    @return True if program completed normally, false on error.
  }
begin
  fErrPipe := nil;
  fConsoleOutputStream := nil;
  fOutPipe := nil;
  // Create input pipe and copy data into it
  fInPipe := TPipe.Create(SourceStream.Size);
  try
    fInPipe.CopyFromStream(SourceStream);
    fInPipe.CloseWriteHandle;
    // Create output pipes
    fOutPipe := TPipe.Create;
    fErrPipe := TPipe.Create;
    // Create / record output streams
    // default encoding used for console output on stderr
    fConsoleOutputStream := TStringStream.Create('', TEncoding.Default);
    fOutStream := HilitedStream;
    // Run program and check for success
    RunPasHi(BuildCommandLine(CreateFragment));
    Result := AnsiPos('Error:', ConsoleOutput) = 0;
  finally
    FreeAndNil(fConsoleOutputStream);
    FreeAndNil(fOutPipe);
    FreeAndNil(fErrPipe);
    FreeAndNil(fInPipe);
  end;
end;

procedure TPasHi.RunPasHi(const CmdLine: string);
  {Executes PasHi with a given command line.
    @param CmdLine [in] PasHi command line.
    @except Exception raised if can't execute PasHi.exe.
  }
var
  ConsoleApp: TConsoleApp;
begin
  ConsoleApp := TConsoleApp.Create;
  try
    // Set up and execute PasHi command line program
    ConsoleApp.OnWork := HandleAppOutput;
    ConsoleApp.StdOut := fOutPipe.WriteHandle;
    ConsoleApp.StdErr := fErrPipe.WriteHandle;
    ConsoleApp.StdIn := fInPipe.ReadHandle;
    if not ConsoleApp.Execute(CmdLine, '') then
      raise Exception.Create(
        'Error executing PasHi:'#13#10 + ConsoleApp.ErrorMessage
      );
  finally
    FreeAndNil(ConsoleApp);
  end;
end;

end.

