{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2007-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Implements top level class that executes program.
}


unit UMain;


interface


uses
  // Delphi
  System.Classes,
  // Project
  Hiliter.UGlobals,
  UConfig,
  UConsole;


type

  ///  <summary>Class that executes program.</summary>
  TMain = class(TObject)
  private
    fConfig: TConfig;     // Program configurations object
    fConsole: TConsole;   // Object used to write to console
    fNormalOutputShown: Boolean;  // Flag true if normal output displayed
    fWarnings: TArray<string>;  // Command line parser warnings
    procedure Configure;
    procedure SignOn;
    procedure ShowHelp;
    procedure ShowVersion;
    procedure ShowConfig;
    procedure ShowWarnings;
    procedure ShowNormalOutput;
    function GetInputSourceCode: string;
    procedure WriteOutput(const S: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Winapi.Windows,
  // Project
  IO.UTypes,
  IO.Readers.UFactory,
  IO.Writers.UFactory,
  IO.UHelper,
  Renderers.UTypes,
  Renderers.UFactory,
  UParams,
  USourceProcessor,
  UVersionInfo;


resourcestring
  // Messages written to console
  sCompleted = 'Completed';
  sError = 'Error: %s';
  sUsage = 'Usage: PasHi ([-rc] [-wc] [-frag | -hidecss] [-q] ) | -h';

{ TMain }

procedure TMain.Configure;
var
  Params: TParams;  // object that gets configuration from command line
begin
  Params := TParams.Create(fConfig);
  try
    Params.Parse; // parse command line, updating configuration object
    if Params.HasWarnings then
      fWarnings := Params.Warnings;
  finally
    FreeAndNil(Params);
  end;
end;

constructor TMain.Create;
begin
  fConfig := TConfig.Create;
  fConsole := TConsole.Create;
  inherited;
end;

destructor TMain.Destroy;
begin
  FreeAndNil(fConsole);
  FreeAndNil(fConfig);
  inherited;
end;

procedure TMain.Execute;
var
  SourceCode: string;   // input Pascal source code
  XHTML: string;        // highlighted XHTML output
  Renderer: IRenderer;  // render customised output document
begin

  ExitCode := 0;

  try
    // Configure program
    Configure;

    // Set up output verbosity options
    fConsole.ValidOutputStates := fConfig.Verbosity;

    if fConfig.ShowHelp then
      // Want help so show it
      ShowHelp

    else if fConfig.ShowVersion then
      // Want version number so show it
      ShowVersion

    else if fConfig.ShowConfigCommands then
      // Display warnings
      ShowConfig

    else
    begin
      // Sign on and initialise program
      ShowNormalOutput;
      SourceCode := GetInputSourceCode;
      Renderer := TRendererFactory.CreateRenderer(SourceCode, fConfig);
      XHTML := Renderer.Render;
      WriteOutput(XHTML);
      // Sign off
      fConsole.WriteLn(sCompleted, vsInfo);
    end;

  except

    // Report any errors
    on E: Exception do
    begin
      // Ensure output verbosity options are set: exception could be raised
      // before --verbostity command is processed
      fConsole.ValidOutputStates := fConfig.Verbosity;
      ShowNormalOutput;
      fConsole.WriteLn(Format(sError, [E.Message]), vsErrors);
      ExitCode := 1;
    end;

  end;
end;

function TMain.GetInputSourceCode: string;
var
  Reader: IInputReader;
  SourceProcessor: TSourceProcessor;
begin
  case fConfig.InputSource of
    isStdIn: Reader := TInputReaderFactory.StdInReaderInstance;
    isFiles: Reader := TInputReaderFactory.FilesReaderInstance(
      fConfig.InputFiles
    );
    isClipboard: Reader := TInputReaderFactory.ClipboardReaderInstance;
  else
    Reader := nil;
  end;
  Assert(Assigned(Reader), 'TMain.GetInputSourceCode: Reader is nil');
  SourceProcessor := TSourceProcessor.Create(fConfig);
  try
    Result := SourceProcessor.Process(Reader.Read)
  finally
    SourceProcessor.Free;
  end;
end;

procedure TMain.ShowConfig;
begin
  fConsole.ValidOutputStates := [vsInfo];
  if Length(fConfig.ConfigFileEntries) > 0 then
  begin
    for var Entry in fConfig.ConfigFileEntries do
      fConsole.WriteLn(Format('%0:s: %1:s', [Entry.Key, Entry.Value]), vsInfo);
  end;
end;

procedure TMain.ShowHelp;
var
  RS: TResourceStream;
begin
  SignOn;
  fConsole.ValidOutputStates := [vsInfo];
  fConsole.WriteLn(vsInfo);
  RS := TResourceStream.Create(HInstance, 'HELP', RT_RCDATA);
  try
    fConsole.WriteLn(
      TIOHelper.BytesToString(TIOHelper.StreamToBytes(RS)),
      vsInfo
    );
  finally
    RS.Free;
  end;
end;

procedure TMain.ShowNormalOutput;
begin
  if fNormalOutputShown then
    Exit;
  SignOn;
  ShowWarnings;
  fNormalOutputShown := True;
end;

procedure TMain.ShowVersion;
var
  VI: TVersionInfo;
begin
  fConsole.ValidOutputStates := [vsInfo];
  VI := TVersionInfo.Create;
  try
    fConsole.WriteLn(VI.CmdLineVersion, vsInfo);
  finally
    VI.Free;
  end;
end;

procedure TMain.ShowWarnings;
var
  W: string;
resourcestring
  sWarning = 'WARNING: %s';
begin
  for W in fWarnings do
    fConsole.WriteLn(Format(sWarning, [W]), vsWarnings);
end;

procedure TMain.SignOn;
resourcestring
  // Sign on message
  sSignOn = 'PasHi by DelphiDabbler (https://delphidabbler.com)';
begin
  // write sign on message, underlined with dashes
  fConsole.WriteLn(sSignOn, vsInfo);
  fConsole.WriteLn(StringOfChar('-', Length(sSignOn)), vsInfo);
end;

procedure TMain.WriteOutput(const S: string);
var
  Writer: IOutputWriter;
  Encoding: TEncoding;
begin
  case fCOnfig.OutputSink of
    osStdOut:
      Writer := TOutputWriterFactory.StdOutWriterInstance;
    osFile:
      Writer := TOutputWriterFactory.FileWriterInstance(fConfig.OutputFile);
    osClipboard:
      Writer := TOutputWriterFactory.ClipboardWriterInstance;
  else
    Writer := nil;
  end;
  Assert(Assigned(Writer), 'TMain.WriteOutput: Writer is nil');
  Encoding := fConfig.OutputEncoding;
  try
    Writer.Write(S, Encoding);
  finally
    if Assigned(Encoding) and not TEncoding.IsStandardEncoding(Encoding) then
      Encoding.Free;
  end;
end;

end.

