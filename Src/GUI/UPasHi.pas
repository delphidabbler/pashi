{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2016, Peter Johnson (www.delphidabbler.com).
 *
 * Class that executes and communicates with PasHi.exe.
}


unit UPasHi;


interface


uses
  // Delphi
  Classes,
  // Project
  UOptions, UPipe;


type

  ///  <summary>Interacts with PasHi.exe to do syntax highlighting.</summary>
  TPasHi = class(TObject)
  private
    fInPipe: TPipe;
    fOutPipe: TPipe;
    fOutStream: TStream;
    fErrPipe: TPipe;
    fConsoleOutputStream: TStringStream;
    procedure HandleAppOutput(Sender: TObject);
    function BuildCommandLine(const Files: TArray<string>;
      const Options: TOptions): string;
    procedure RunPasHi(const CmdLine: string);
    function InternalHilite(const HilitedStream: TStream;
      const CmdLine: string): Boolean;
  public
    function Hilite(const SourceStream, HilitedStream: TStream;
      const Options: TOptions): Boolean; overload;
    function Hilite(const Files: TArray<string>; const HilitedStream: TStream;
      const Options: TOptions): Boolean; overload;
    function ConsoleOutput: string;
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  UConsoleApp;


{ TPasHi }

function TPasHi.BuildCommandLine(const Files: TArray<string>;
  const Options: TOptions): string;

  function NormaliseParam(const Param: string): string;
  begin
    if FindDelimiter(' '#9, Param) = 0 then
      Exit(Param);
    Result := '"' + Param + '"';
  end;

var
  Param: string;
  Command: TOptions.TOption;
begin
  // ** do not localise anything in this method
  Result := 'PasHi '
    + '--output-stdout '
    + '--encoding utf-8 '
    + '--verbosity quiet '
  ;
  if Assigned(Files) then
  begin
    for Param in Files do
      Result := Result + NormaliseParam(Param) + ' ';
  end
  else
    Result := Result + '--input-stdin ';
  for Command in Options do
  begin
    Result := Result + ' --' + Command.Key;
    if Command.Value <> '' then
      Result := Result + ' ' + NormaliseParam(Command.Value);
  end;
end;

function TPasHi.ConsoleOutput: string;
begin
  Result := fConsoleOutputStream.DataString;
end;

procedure TPasHi.HandleAppOutput(Sender: TObject);
begin
  fOutPipe.CopyToStream(fOutStream);
  fErrPipe.CopyToStream(fConsoleOutputStream);
end;

function TPasHi.Hilite(const Files: TArray<string>;
  const HilitedStream: TStream; const Options: TOptions): Boolean;
begin
  Assert(Assigned(Files));
  Assert(Length(Files) > 0);
  Result := InternalHilite(HilitedStream, BuildCommandLine(Files, Options));
end;

function TPasHi.Hilite(const SourceStream, HilitedStream: TStream;
  const Options: TOptions): Boolean;
begin
  // Create input pipe and copy data into it
  fInPipe := TPipe.Create(SourceStream.Size);
  try
    fInPipe.CopyFromStream(SourceStream);
    fInPipe.CloseWriteHandle;
    Result := InternalHilite(HilitedStream, BuildCommandLine(nil, Options));
  finally
    FreeAndNil(fInPipe);  // must leave fPipe = nil
  end;
end;

function TPasHi.InternalHilite(const HilitedStream: TStream;
  const CmdLine: string): Boolean;
begin
  fErrPipe := nil;
  fConsoleOutputStream := nil;
  fOutPipe := nil;
  try
    // Create output pipes
    fOutPipe := TPipe.Create;
    fErrPipe := TPipe.Create;
    // Create / record output streams
    // default encoding used for console output on stderr
    fConsoleOutputStream := TStringStream.Create('', TEncoding.Default);
    fOutStream := HilitedStream;
    // Run program and check for success
    RunPasHi(CmdLine);
    Result := AnsiPos('Error:', ConsoleOutput) = 0;
  finally
    FreeAndNil(fConsoleOutputStream);
    FreeAndNil(fOutPipe);
    FreeAndNil(fErrPipe);
  end;
end;

procedure TPasHi.RunPasHi(const CmdLine: string);
var
  ConsoleApp: TConsoleApp;
begin
  ConsoleApp := TConsoleApp.Create;
  try
    // Set up and execute PasHi command line program
    ConsoleApp.OnWork := HandleAppOutput;
    ConsoleApp.StdOut := fOutPipe.WriteHandle;
    ConsoleApp.StdErr := fErrPipe.WriteHandle;
    if Assigned(fInPipe) then
      ConsoleApp.StdIn := fInPipe.ReadHandle;
    if not ConsoleApp.Execute(CmdLine, '') then
      raise Exception.Create(
        'Error executing PasHi:'#13#10#13#10 + ConsoleApp.ErrorMessage
      );
    if ConsoleApp.ExitCode > 0 then
      raise Exception.Create(
        'PasHi returned an error. Output was:'#13#10#13#10 + ConsoleOutput
      );
  finally
    FreeAndNil(ConsoleApp);
  end;
end;

end.

