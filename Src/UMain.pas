{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2007-2016, Peter Johnson (www.delphidabbler.com).
 *
 * Implements top level class that executes program.
}


unit UMain;


interface


uses
  // Delphi
  Classes,
  // Project
  Hiliter.UGlobals, UConfig, UConsole;


type

  ///  <summary>Class that executes program.</summary>
  TMain = class(TObject)
  private
    fConfig: TConfig;     // Program configurations object
    fConsole: TConsole;   // Object used to write to console
    fSignedOn: Boolean;   // Flag shows if sign on message has been displayed
    fWarnings: TArray<string>;  // Command line parser warnings
    procedure Configure;
    procedure SignOn;
    procedure ShowHelp;
    procedure ShowWarnings;
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
  SysUtils, Windows,
  // Project
  IO.UTypes, IO.Readers.UFactory, IO.Writers.UFactory, IO.UHelper,
  Renderers.UTypes,
  UParams, Renderers.UFactory, USourceProcessor, UVersionInfo;


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
    // Decide if program is to write to console
    fConsole.Silent := (fConfig.Verbosity = vbQuiet) and not fConfig.ShowHelp;
    if fConfig.ShowHelp then
      // Want help so show it
      ShowHelp
    else
    begin
      // Sign on and initialise program
      SignOn;
      if Length(fWarnings) > 0 then
        ShowWarnings;
      SourceCode := GetInputSourceCode;
      Renderer := TRendererFactory.CreateRenderer(SourceCode, fConfig);
      XHTML := Renderer.Render;
      WriteOutput(XHTML);
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

procedure TMain.ShowHelp;
var
  RS: TResourceStream;
begin
  SignOn;
  fConsole.WriteLn;
  RS := TResourceStream.Create(HInstance, 'HELP', RT_RCDATA);
  try
    fConsole.WriteLn(
      TIOHelper.BytesToString(TIOHelper.StreamToBytes(RS))
    );
  finally
    RS.Free;
  end;
end;

procedure TMain.ShowWarnings;
var
  W: string;
resourcestring
  sWarning = 'WARNING: %s';
begin
  if fConfig.Verbosity = vbNoWarnings then
    Exit;
  for W in fWarnings do
    fConsole.WriteLn(Format(sWarning, [W]));
end;

procedure TMain.SignOn;
resourcestring
  // Sign on message format string
  sSignOn = 'PasHi %s by DelphiDabbler (www.delphidabbler.com)';
var
  Msg: string;  // sign on message text
begin
  // Create and write sign on message
  Msg := Format(sSignOn, [GetFileVersionStr]);
  fConsole.WriteLn(Msg);
  // underline sign-on message with dashes
  fConsole.WriteLn(StringOfChar('-', Length(Msg)));
  // record that we've signed on
  fSignedOn := True;
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

