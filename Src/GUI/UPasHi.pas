{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2012, Peter Johnson (www.delphidabbler.com).
 *
 * Class that executes and communicates with PasHi.exe.
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

