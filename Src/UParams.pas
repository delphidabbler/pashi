{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2007-2016, Peter Johnson (www.delphidabbler.com).
 *
 * Implements classes that used to parse command line and record details.
}


unit UParams;


interface


uses
  // Delphi
  Generics.Collections,
  // Project
  UConfig;

type
  ///  <summary>Ids representing each valid command line comamnd.</summary>
  TCommandId = (
    siInputClipboard,   // read input from clipboard
    siInputStdIn,       // read input from standard input
    siOutputClipboard,  // write output to clipboard
    siOutputFile,       // write output to a file
    siOutputStdOut,     // write output to standard output
    siOuputEncoding,    // use specified encoding for output
    siOutputDocType,    // type of document to be output
    siFragment,         // write output as XHTML document fragment (legacy)
    siHideCSS,          // hide or shows embedded CSS in comments
    siForceHideCSS,     // hide embedded CSS in comments (legacy)
    siEmbedCSS,         // embed css from a file
    siLinkCSS,          // link to external CSS file
    siDefaultCSS,       // embed default CSS
    siLegacyCSS,        // use legacy CSS class names
    siLanguage,         // specify output language
    siLanguageNeutral,  // no output language specified
    siTitle,            // document title
    siTitleDefault,     // use default document title
    siBranding,         // determines whether branding written to code fragments
    siHelp,             // display help
    siVerbosity,        // determines amount of messages output by program
    siTrim,             // determines if source code is trimmed
    siSeparatorLines,   // specifies number of lines that separate source files
    siLineNumbering,    // determines if output file is to be line numbered
    siLineNumberWidth,  // specifies width of line numbers in characters
    siLineNumberPadding,// specifies character used to pad line number lines
    siStriping,         // switches line striping on and off
    siQuiet             // don't display any output to console
  );

type
  ///  <summary>Encapsulation of a single command line command.</summary>
  TCommand = record
  strict private
    const
      TrueSwitchChars = ['+', '1'];
      FalseSwitchChars = ['-', '0'];
      SwitchChars = TrueSwitchChars + FalseSwitchChars;
  strict private
    var
      fCommand: string;
    function GetName: string;
    ///  <summary>Validates given command syntax, not semantics.</summary>
    class procedure ValidateCommand(const Cmd: string); static;
  public
    constructor Create(const Cmd: string);
    ///  <summary>Complete command, including any switches. Same as Name
    ///  property unless command is a switch.</summary>
    property Command: string read fCommand;
    ///  <summary>Name of command without any switch values. Same as Command
    ///  property unless command is a switch.</summary>
    property Name: string read GetName;
    ///  <summary>Checks if command is a short form command.</summary>
    function IsShortForm: Boolean; overload;
    ///  <summary>Checks if given command is a short form command.</summary>
    class function IsShortForm(const Cmd: string): Boolean; overload; static;
    ///  <summary>Checks if command is a switch.</summary>
    function IsSwitch: Boolean;
    ///  <summary>Value of switch. Error if command not switch.</summary>
    function SwitchValue: Boolean;
    ///  <summary>Checks if given string is a valid command.</summary>
    class function IsCommand(const S: string): Boolean; static;
    class operator Implicit(const S: string): TCommand;
    class operator Implicit(const Cmd: TCommand): string;
  end;

type
  ///  <summary>Class that parses command line and stores settings according to
  ///  commands provided.</summary>
  TParams = class(TObject)
  strict private
    var
      fParamQueue: TQueue<string>; // Queue of parameters to be processed
      fCmdLookup: TDictionary<string, TCommandId>;
      fSwitchCmdLookup: TList<string>;
      fEncodingLookup: TDictionary<string, TOutputEncodingId>;
      fDocTypeLookup: TDictionary<string, TDocType>;
      fBooleanLookup: TDictionary<string, Boolean>;
      fVerbosityLookup: TDictionary<string, TVerbosity>;
      fPaddingLookup: TDictionary<string, Char>;
      fConfig: TConfig; // Reference to program's configuration object
    procedure GetConfigParams;
    procedure GetCmdLineParams;
    procedure ParseCommand;
    procedure ParseFileName;
    function GetStringParameter(const Cmd: TCommand): string;
    function GetBooleanParameter(const Cmd: TCommand): Boolean;
    function GetEncodingParameter(const Cmd: TCommand): TOutputEncodingId;
    function GetDocTypeParameter(const Cmd: TCommand): TDocType;
    function GetVerbosityParameter(const Cmd: TCommand): TVerbosity;
    function GetNumericParameter(const Cmd: TCommand; const Lo, Hi: UInt16):
      UInt16;
    function GetPaddingParameter(const Cmd: TCommand): Char;
  public
    constructor Create(const Config: TConfig);
    destructor Destroy; override;
    procedure Parse;
  end;


implementation


uses
  // Delphi
  StrUtils, SysUtils, Classes, Character,
  // Project
  UComparers, UConfigFiles;


{ TParams }

constructor TParams.Create(const Config: TConfig);
begin
  Assert(Assigned(Config), 'TParams.Create: Config is nil');
  inherited Create;
  fConfig := Config;
  fParamQueue := TQueue<string>.Create;
  // lookup table for commands: case sensitive
  fCmdLookup := TDictionary<string,TCommandId>.Create(
    TStringEqualityComparer.Create
  );
  with fCmdLookup do
  begin
    // short forms
    Add('-b', siBranding);
    Add('-c', siHideCSS);
    Add('-d', siOutputDocType);
    Add('-e', siOuputEncoding);
    Add('-h', siHelp);
    Add('-i', siLineNumberWidth);
    Add('-k', siLinkCSS);
    Add('-l', siLanguage);
    Add('-m', siTrim);
    Add('-n', siLineNumbering);
    Add('-o', siOutputFile);
    Add('-p', siLineNumberPadding);
    Add('-q', siQuiet);
    Add('-r', siInputClipboard);
    Add('-s', siEmbedCSS);
    Add('-t', siTitle);
    Add('-w', siOutputClipboard);
    // long forms
    Add('--doc-type', siOutputDocType);
    Add('--encoding', siOuputEncoding);
    Add('--help', siHelp);
    Add('--hide-css', siHideCSS);
    Add('--input-clipboard', siInputClipboard);
    Add('--input-stdin', siInputStdIn);
    Add('--language', siLanguage);
    Add('--language-neutral', siLanguageNeutral);
    Add('--embed-css', siEmbedCSS);
    Add('--default-css', siDefaultCSS);
    Add('--link-css', siLinkCSS);
    Add('--legacy-css', siLegacyCSS);
    Add('--branding', siBranding);
    Add('--output-clipboard', siOutputClipboard);
    Add('--output-file', siOutputFile);
    Add('--output-stdout', siOutputStdOut);
    Add('--verbosity', siVerbosity);
    Add('--quiet', siQuiet);
    Add('--title', siTitle);
    Add('--title-default', siTitleDefault);
    Add('--trim', siTrim);
    Add('--separator-lines', siSeparatorLines);
    Add('--line-numbering', siLineNumbering);
    Add('--line-number-width', siLineNumberWidth);
    Add('--line-number-padding', siLineNumberPadding);
    Add('--striping', siStriping);
    // commands kept for backwards compatibility with v1.x
    Add('-frag', siFragment);
    Add('-hidecss', siForceHideCSS);
    Add('-rc', siInputClipboard);
    Add('-wc', siOutputClipboard);
  end;
  // lookup table for short form commands that are switches
  fSwitchCmdLookup := TList<string>.Create;
  with fSwitchCmdLookup do
  begin
    Add('-b');
    Add('-c');
    Add('-m');
    Add('-n');
  end;
  // lookup table for --encoding command values: case insensitive
  fEncodingLookup := TDictionary<string,TOutputEncodingId>.Create(
    TTextEqualityComparer.Create
  );
  with fEncodingLookup do
  begin
    Add('utf-8', oeUTF8);
    Add('utf8', oeUTF8);
    Add('utf-16', oeUTF16);
    Add('utf16', oeUTF16);
    Add('unicode', oeUTF16);
    Add('windows-1252', oeWindows1252);
    Add('windows1252', oeWindows1252);
    Add('cp-1252', oeWindows1252);
    Add('cp1252', oeWindows1252);
    Add('iso-8859-1', oeISO88591);
    Add('latin-1', oeISO88591);
    Add('latin1', oeISO88591);
  end;
  // lookup table for --doc-type command values: case insensitive
  fDocTypeLookup := TDictionary<string, TDocType>.Create(
    TTextEqualityComparer.Create
  );
  with fDocTypeLookup do
  begin
    Add('xhtml', dtXHTML);
    Add('html4', dtHTML4);
    Add('html5', dtHTML5);
    Add('fragment', dtFragment);
  end;
  // lookup table for any command with boolean parameters
  fBooleanLookup := TDictionary<string, Boolean>.Create(
    TTextEqualityComparer.Create
  );
  with fBooleanLookup do
  begin
    Add('1', True);
    Add('0', False);
    Add('true', True);
    Add('false', False);
    Add('yes', True);
    Add('no', False);
    Add('Y', True);
    Add('N', False);
    Add('on', True);
    Add('off', False);
  end;
  fVerbosityLookup := TDictionary<string, TVerbosity>.Create(
    TTextEqualityComparer.Create
  );
  with fVerbosityLookup do
  begin
    Add('normal', vbNormal);
    Add('quiet', vbQuiet);
  end;
  fPaddingLookup := TDictionary<string, Char>.Create(
    TTextEqualityComparer.Create
  );
  with fPaddingLookup do
  begin
    Add('space', ' ');
    Add('zero', '0');
    Add('0', '0');
    Add('dash', '-');
    Add('dot', '.');
  end;
end;

destructor TParams.Destroy;
begin
  fPaddingLookup.Free;
  fVerbosityLookup.Free;
  fBooleanLookup.Free;
  fDocTypeLookup.Free;
  fEncodingLookup.Free;
  fSwitchCmdLookup.Free;
  fCmdLookup.Free;
  fParamQueue.Free;
  inherited;
end;

function TParams.GetBooleanParameter(const Cmd: TCommand): Boolean;
var
  Param: string;
resourcestring
  sBadValue = 'Unrecognised Boolean value "%s"';
begin
  Param := GetStringParameter(Cmd);
  if not fBooleanLookup.ContainsKey(Param) then
    raise Exception.CreateFmt(sBadValue, [Param]);
  Result := fBooleanLookup[Param];
end;

procedure TParams.GetCmdLineParams;
var
  Idx: Integer;
begin
  fParamQueue.Clear;
  for Idx := 1 to ParamCount do
    fParamQueue.Enqueue(ParamStr(Idx));
end;

procedure TParams.GetConfigParams;
var
  CfgFileReader: TConfigFileReader;
  CfgEntry: TPair<string,string>;
begin
  fParamQueue.Clear;
  CfgFileReader := TConfigFiles.ConfigFileReaderInstance;
  try
    for CfgEntry in CfgFileReader do
    begin
      fParamQueue.Enqueue('--' + CfgEntry.Key);
      if CfgEntry.Value <> '' then
        fParamQueue.Enqueue(CfgEntry.Value);
    end;
  finally
    CfgFileReader.Free;
  end;
end;

function TParams.GetDocTypeParameter(const Cmd: TCommand): TDocType;
var
  Param: string;
resourcestring
  sBadValue = 'Unrecognised document type "%s"';
begin
  Param := GetStringParameter(Cmd);
  if not fDocTypeLookup.ContainsKey(Param) then
    raise Exception.CreateFmt(sBadValue, [Param]);
  Result := fDocTypeLookup[Param];
end;

function TParams.GetEncodingParameter(const Cmd: TCommand): TOutputEncodingId;
var
  Param: string;
resourcestring
  sBadValue = 'Unrecognised encoding "%s"';
begin
  Param := GetStringParameter(Cmd);
  if not fEncodingLookup.ContainsKey(Param) then
    raise Exception.CreateFmt(sBadValue, [Param]);
  Result := fEncodingLookup[Param];
end;

function TParams.GetNumericParameter(const Cmd: TCommand; const Lo,
  Hi: UInt16): UInt16;
var
  Param: string;
  Value: Integer;
resourcestring
  sNotNumber = 'Numeric parameter expected for %s';
  sOutOfRange = 'Parameter for %0:s must be in range %1:d..%2:d';
begin
  Param := GetStringParameter(Cmd);
  if not TryStrToInt(Param, Value) then
    raise Exception.CreateFmt(sNotNumber, [Cmd.Name]);
  if (Value < Lo) or (Value > Hi) then
    raise Exception.CreateFmt(sOutOfRange, [Cmd.Name, Lo, Hi]);
  Result := UInt16(Value);
end;

function TParams.GetPaddingParameter(const Cmd: TCommand): Char;
var
  Param: string;
resourcestring
  sBadValue = 'Unrecognised padding value "%s"';
begin
  Param := GetStringParameter(Cmd);
  if not fPaddingLookup.ContainsKey(Param) then
    raise Exception.CreateFmt(sBadValue, [Param]);
  Result := fPaddingLookup[Param];
end;

function TParams.GetStringParameter(const Cmd: TCommand): string;
resourcestring
  sNoParam = 'Parameter for %s missing.';
begin
  if fParamQueue.Count = 0 then
    Result := ''
  else
    Result := fParamQueue.Peek;
  if (Result = '') or AnsiStartsStr('-', Result) then
    raise Exception.CreateFmt(sNoParam, [Cmd.Name]);
end;

function TParams.GetVerbosityParameter(const Cmd: TCommand): TVerbosity;
var
  Param: string;
resourcestring
  sBadValue = 'Unrecognised verbosity value "%s"';
begin
  Param := GetStringParameter(Cmd);
  if not fVerbosityLookup.ContainsKey(Param) then
    raise Exception.CreateFmt(sBadValue, [Param]);
  Result := fVerbosityLookup[Param];
end;

procedure TParams.Parse;

  procedure ParseQueue(const ErrorFmtStr: string);
  begin
    try
      while fParamQueue.Count > 0 do
      begin
        if AnsiStartsStr('-', fParamQueue.Peek) then
          ParseCommand
        else
          ParseFileName;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt(ErrorFmtStr, [E.Message]);
    end;
  end;

resourcestring
  sConfigFileErrorFmt = '%s (in config file)';
  sCommandLineErrorFmt = '%s';
begin
  GetConfigParams;
  ParseQueue(sConfigFileErrorFmt);
  GetCmdLineParams;
  ParseQueue(sCommandLineErrorFmt);
end;

procedure TParams.ParseCommand;
resourcestring
  // Error messages
  sBadCommand = 'Unrecognised command "%s"';
  sCantBeSwitch = '%s cannot be a switch command';
  sMustBeSwitch = '%s must be a switch command: append "+" or "-"';
var
  Command: TCommand;
  CommandId: TCommandId;
begin
  Command := fParamQueue.Dequeue;
  if not fCmdLookup.ContainsKey(Command.Name) then
    raise Exception.CreateFmt(sBadCommand, [Command.Name]);
  CommandId := fCmdLookup[Command.Name];

  if Command.IsSwitch and not fSwitchCmdLookup.Contains(Command.Name) then
    raise Exception.CreateFmt(sCantBeSwitch, [Command.Name]);
  if not Command.IsSwitch and fSwitchCmdLookup.Contains(Command.Name) then
    raise Exception.CreateFmt(sMustBeSwitch, [Command.Name]);

  case CommandId of
    siInputClipboard:
      fConfig.InputSource := isClipboard;
    siInputStdIn:
      fConfig.InputSource := isStdIn;
    siOutputClipboard:
      fConfig.OutputSink := osClipboard;
    siOutputFile:
    begin
      fConfig.OutputFile := GetStringParameter(Command);
      fConfig.OutputSink := osFile;
      fParamQueue.Dequeue;
    end;
    siOutputStdOut:
      fConfig.OutputSink := osStdOut;
    siOuputEncoding:
    begin
      fConfig.OutputEncodingId := GetEncodingParameter(Command);
      fParamQueue.Dequeue;
    end;
    siOutputDocType:
    begin
      fConfig.DocType := GetDocTypeParameter(Command);
      fParamQueue.Dequeue;
    end;
    siFragment:
      fConfig.DocType := dtFragment;
    siForceHideCSS:
      fConfig.HideCSS := True;
    siHideCSS:
    begin
      if Command.IsSwitch then
        fConfig.HideCSS := Command.SwitchValue
      else
      begin
        fConfig.HideCSS := GetBooleanParameter(Command);
        fParamQueue.Dequeue;
      end;
    end;
    siEmbedCSS:
    begin
      fConfig.CSSLocation := GetStringParameter(Command);
      fConfig.CSSSource := csFile;
      fParamQueue.Dequeue;
    end;
    siDefaultCSS:
    begin
      fConfig.CSSLocation := '';
      fConfig.CSSSource := csDefault;
    end;
    siLinkCSS:
    begin
      fConfig.CSSLocation := GetStringParameter(Command);
      fConfig.CSSSource := csLink;
      fParamQueue.Dequeue;
    end;
    siLegacyCSS:
    begin
      fConfig.LegacyCSSNames := GetBooleanParameter(Command);
      fParamQueue.Dequeue;
    end;
    siLanguage:
    begin
      fConfig.Language := GetStringParameter(Command);
      fParamQueue.Dequeue;
    end;
    siLanguageNeutral:
      fConfig.Language := '';
    siTitle:
    begin
      fConfig.Title := GetStringParameter(Command);
      fParamQueue.Dequeue;
    end;
    siTitleDefault:
      fConfig.Title := '';
    siBranding:
    begin
      if Command.IsSwitch then
        fConfig.BrandingPermitted := Command.SwitchValue
      else
      begin
        fConfig.BrandingPermitted := GetBooleanParameter(Command);
        fParamQueue.Dequeue;
      end;
    end;
    siTrim:
    begin
      if Command.IsSwitch then
        fConfig.TrimSource := Command.SwitchValue
      else
      begin
        fConfig.TrimSource := GetBooleanParameter(Command);
        fParamQueue.Dequeue;
      end;
    end;
    siSeparatorLines:
    begin
      fConfig.SeparatorLines := GetNumericParameter(
        Command, Low(TSeparatorLines), High(TSeparatorLines)
      );
      fParamQueue.Dequeue;
    end;
    siLineNumbering:
    begin
      if Command.IsSwitch then
        fConfig.UseLineNumbering := Command.SwitchValue
      else
      begin
        fConfig.UseLineNumbering := GetBooleanParameter(Command);
        fParamQueue.Dequeue;
      end;
    end;
    siLineNumberWidth:
    begin
      fConfig.LineNumberWidth := GetNumericParameter(
        Command, Low(TLineNumberWidth), High(TLineNumberWidth)
      );
      fParamQueue.Dequeue;
    end;
    siLineNumberPadding:
    begin
      fConfig.LineNumberPadding := GetPaddingParameter(Command);
      fParamQueue.Dequeue;
    end;
    siStriping:
    begin
      fConfig.Striping := GetBooleanParameter(Command);
      fParamQueue.Dequeue;
    end;
    siHelp:
      fConfig.ShowHelp := True;
    siVerbosity:
    begin
      fConfig.Verbosity := GetVerbosityParameter(Command);
      fParamQueue.Dequeue;
    end;
    siQuiet:
      fConfig.Verbosity := vbQuiet;
  end;
end;

procedure TParams.ParseFileName;
begin
  // Parse file name at head of queue
  fConfig.AddInputFile(fParamQueue.Peek);
  fConfig.InputSource := isFiles;
  // Next parameter
  fParamQueue.Dequeue;
end;

{ TCommand }

constructor TCommand.Create(const Cmd: string);
begin
  ValidateCommand(Cmd);
  fCommand := Cmd;
end;

function TCommand.GetName: string;
begin
  if not IsShortForm then
    Exit(fCommand);
  Result := AnsiLeftStr(fCommand, 2);
end;

class operator TCommand.Implicit(const S: string): TCommand;
begin
  ValidateCommand(S);
  Result.fCommand := S;
end;

class operator TCommand.Implicit(const Cmd: TCommand): string;
begin
  Result := Cmd.Command;
end;

class function TCommand.IsCommand(const S: string): Boolean;
var
  Idx: Integer;
begin
  if AnsiStartsStr('--', S) then
  begin
    // long form command: '-' '-' <letter> {<letter> | '-'}
    if Length(S) < 3 then
      Exit(False);
    if not TCharacter.IsLetter(S[3]) then
      Exit(False);
    for Idx := 4 to Length(S) do
      if not TCharacter.IsLetter(S[Idx]) and (S[Idx] <> '-') then
        Exit(False);
    Result := True;
  end
  else if AnsiStartsStr('-', S) then
  begin
    // short form or legacy commands
    if Length(S) < 2 then
      Exit(False);
    // short form: '-' <letter> [<switch-char>]
    if IsShortForm(S) then
      Exit(True);
    // legacy:     '-' <letter> {<letter>}
    for Idx := 2 to Length(S) do
      if not TCharacter.IsLetter(S[Idx]) then
        Exit(False);
    Result := True;
  end
  else
    // no preceding '-'
    Result := False;
end;

function TCommand.IsShortForm: Boolean;
begin
  Result := IsShortForm(fCommand);
end;

class function TCommand.IsShortForm(const Cmd: string): Boolean;
begin
  if not (Length(Cmd) in [2..3]) then
    Exit(False);
  if Cmd[1] <> '-' then
    Exit(False);
  if not TCharacter.IsLetter(Cmd[2]) then
    Exit(False);
  if (Length(Cmd) = 3) and not CharInSet(Cmd[3], SwitchChars) then
    Exit(False);
  Result := True;
end;

function TCommand.IsSwitch: Boolean;
begin
  Result := IsShortForm and (Length(fCommand) = 3);
end;

function TCommand.SwitchValue: Boolean;
resourcestring
  sBadSwitch = '%s in not a switch command';
begin
  if not IsSwitch then
    raise Exception.CreateFmt(sBadSwitch, [Name]);
  Result := CharInSet(fCommand[3], TrueSwitchChars);
end;

class procedure TCommand.ValidateCommand(const Cmd: string);
resourcestring
  sBadCommand = '"%s" is not a valid command';
begin
  if not IsCommand(Cmd) then
    raise Exception.CreateFmt(sBadCommand, [Cmd]);
end;

end.

