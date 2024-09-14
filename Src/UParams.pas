{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2007-2022, Peter Johnson (www.delphidabbler.com).
 *
 * Implements classes that used to parse command line and record details.
}


unit UParams;


interface


uses
  // Delphi
  SysUtils,
  Types,
  Generics.Collections,
  // Project
  Hiliter.UGlobals,
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
    siTrim2,             // determines if & how source code is trimmed
    siSeparatorLines,   // specifies number of lines that separate source files
    siLineNumbering,    // determines if output file is to be line numbered
    siLineNumberWidth,  // specifies width of line numbers in characters
    siLineNumberPadding,// specifies character used to pad line number lines
    siStriping,         // switches line striping on and off
    siQuiet,            // don't display any output to console
    siViewport,         // which viewport meta-data to output, if any
    siEdgeCompatibility,// whether edge compatibility info meta-data is output
    siLineNumberStart,  // specifies starting line number
    siVersion,          // display program's version
    siInhibitStyling    // inhibits styling of some highlight elements
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
    const
      SetParamOpener = '{';
      SetParamCloser = '}';
    var
      fParamQueue: TQueue<string>; // Queue of parameters to be processed
      fCmdLookup: TDictionary<string, TCommandId>;
      fV1CommandLookup: TList<string>;
      fSwitchCmdLookup: TList<string>;
      fConfigBlacklist: TList<TCommandId>;
      fEncodingLookup: TDictionary<string, TOutputEncodingId>;
      fDocTypeLookup: TDictionary<string, TDocType>;
      fBooleanLookup: TDictionary<string, Boolean>;
      fVerbosityLookup: TDictionary<string, TVerbosity>;
      fPaddingLookup: TDictionary<string, Char>;
      fViewportLookup: TDictionary<string, TViewport>;
      fHiliteSpanClsLookup: TDictionary<string, THiliteElement>;
      fHiliteAliasLookup: TDictionary<string, THiliteElements>;
      fTrimLookup: TDictionary<string, TTrimOperation>;
      fConfig: TConfig; // Reference to program's configuration object
      fWarnings: TList<string>;
      fFirstCommandFound: Boolean;  // detects filenames after 1st command
    procedure GetConfigParams;
    procedure GetCmdLineParams;
    procedure ParseCommand(const IsConfigCmd: Boolean);
    procedure ParseFileName;
    function TryParseSetParam(const Param: string; out Elems: TStringDynArray):
      Boolean;
    function GetStringParameter(const Cmd: TCommand): string;
    function GetBooleanParameter(const Cmd: TCommand): Boolean;
    function GetEncodingParameter(const Cmd: TCommand): TOutputEncodingId;
    function GetDocTypeParameter(const Cmd: TCommand): TDocType;
    function GetVerbosityParameter(const Cmd: TCommand): TVerbosity;
    function GetNumericParameter(const Cmd: TCommand; const Lo, Hi: UInt16):
      UInt16;
    function GetPaddingParameter(const Cmd: TCommand): Char;
    function GetViewportParameter(const Cmd: TCommand): TViewport;
    function GetExcludedSpansParameter(const Cmd: TCommand): THiliteElements;
    function GetWarnings: TArray<string>;
    function AdjustCommandName(const Name: string; IsCfgCmd: Boolean): string;
    function IsV1Command(const Name: string): Boolean;
  public
    constructor Create(const Config: TConfig);
    destructor Destroy; override;
    procedure Parse;
    property Warnings: TArray<string> read GetWarnings;
    function HasWarnings: Boolean;
  end;

  ///  <summary>Type of exception raised for a command related error.</summary>
  ///  <param name="CommandName">string [in] Name of command for which exception
  ///  is being raised.</param>
  ///  <param name="FormatStr">string [in] A format string that defines the
  ///  error message. Must have a single %s placeholder in position where the
  ///  (possibly modified) command name will appear.</param>
  ///  <remarks>
  ///  <para>Do not use any of the inherited constructors. Handling code expects
  ///  expects valid CommandName and FormatStr properties to be set.</para>
  ///  <para>We send a FormatStr to exception handler rather than a preformatted
  ///  string since handler may need to modify CommandName before rendering
  ///  message string.</para>
  ///  </remarks>
  ECommandError = class(Exception)
  strict private
    var
      fFormatStr: string;
      fCommandName: string;
  public
    constructor Create(const CommandName: string; const FormatStr: string);
    property CommandName: string read fCommandName;
    property FormatStr: string read fFormatStr;
  end;


implementation


uses
  // Delphi
  StrUtils, Classes, Character,
  // Project
  Hiliter.UHiliters,
  UComparers, UConfigFiles;


{ TParams }

function TParams.AdjustCommandName(const Name: string;
  IsCfgCmd: Boolean): string;
begin
  if IsCfgCmd then
  begin
    if StartsStr('--', Name) then
      Result := RightStr(Name, Length(Name) - 2)
    else
      Result := Name;
  end
  else
    Result := Name;
end;

constructor TParams.Create(const Config: TConfig);
var
  HiliteElem: THiliteElement;
  CSSNames: TCSSNames;
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
    Add('-v', siVersion);
    Add('-w', siOutputClipboard);
    Add('-z', siLineNumberStart);
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
    Add('--line-number-start', siLineNumberStart);
    Add('--striping', siStriping);
    Add('--viewport', siViewport);
    Add('--edge-compatibility', siEdgeCompatibility);
    Add('--version', siVersion);
    Add('--inhibit-styling', siInhibitStyling);
    // commands kept for backwards compatibility with v1.x
    Add('-frag', siFragment);
    Add('-hidecss', siForceHideCSS);
    Add('-rc', siInputClipboard);
    Add('-wc', siOutputClipboard);
  end;
  fV1CommandLookup := TList<string>.Create(
    TTextComparer.Create
  );
  with fV1CommandLookup do
  begin
    Add('-wc');
    Add('-rc');
    Add('-hidecss');
    Add('-frag');
  end;
  // list of short form commands that are switches
  fSwitchCmdLookup := TList<string>.Create;
  with fSwitchCmdLookup do
  begin
    Add('-b');
    Add('-c');
    Add('-m');
    Add('-n');
  end;
  // list of commands blacklisted from config file
  fConfigBlacklist := TList<TCommandId>.Create;
  with fConfigBlacklist do
  begin
    Add(siHelp);
    Add(siVersion);
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
    Add('frag', dtFragment);
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
    Add('no-warn', vbNoWarnings);
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
  fViewportLookup := TDictionary<string,TViewport>.Create(
    TTextEqualityComparer.Create
  );
  with fViewportLookup do
  begin
    Add('none', vpNone);
    Add('mobile', vpPhone);
    Add('phone', vpPhone);
    Add('tablet', vpPhone);
  end;
  fWarnings := TList<string>.Create(TTextComparer.Create);

  fTrimLookup := TDictionary<string, TTrimOperation>.Create(
    TTextEqualityComparer.Create
  );
  fTrimLookup.Add('-', tsNone);
  fTrimLookup.Add('none', tsNone);
  fTrimLookup.Add('nothing', tsNone);
  fTrimLookup.Add('lines', tsLines);
  fTrimLookup.Add('spaces', tsSpaces);
  fTrimLookup.Add('all', tsBoth);
  fTrimLookup.Add('everything', tsBoth);
  // Additionally old Boolean params are supported, but deprecated.
  //   False => 'none' and True => 'lines'

  fHiliteSpanClsLookup := TDictionary<string,THiliteElement>.Create(
    TTextEqualityComparer.Create
  );
  fHiliteAliasLookup := TDictionary<string, THiliteElements>.Create(
    TTextEqualityComparer.Create
  );
  CSSNames := TCSSNames.Create;
  try
    for HiliteElem := Low(THiliteElement) to High(THiliteElement) do
    begin
      fHiliteSpanClsLookup.Add(CSSNames.ElementClass(HiliteElem), HiliteElem);
      // add element name as alias for {element-name}
      fHiliteAliasLookup.Add(CSSNames.ElementClass(HiliteElem), [HiliteElem]);
    end;
  finally
    CSSNames.Free;
  end;
  fHiliteAliasLookup.Add('-', []);  // alias for empty set {}
end;

destructor TParams.Destroy;
begin
  fHiliteAliasLookup.Free;
  fHiliteSpanClsLookup.Free;
  fWarnings.Free;
  fViewportLookup.Free;
  fPaddingLookup.Free;
  fVerbosityLookup.Free;
  fBooleanLookup.Free;
  fDocTypeLookup.Free;
  fEncodingLookup.Free;
  fSwitchCmdLookup.Free;
  fV1CommandLookup.Free;
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

function TParams.GetExcludedSpansParameter(const Cmd: TCommand):
  THiliteElements;
var
  Param: string;
  Spans: TStringDynArray;
  Span: string;
resourcestring
  sBadSpanCls = 'Invalid span class name for "%s": ';
  sBadParam = 'Invalid parameter for "%s": ';
begin
  // Parameter is EITHER a set or an alias for a set
  // Set is enclosed in {}, alias is not.
  Param := GetStringParameter(Cmd);
  if TryParseSetParam(Param, Spans) then
  begin
    // Parameter is a valid set of zero or more elements
    Result := [];
    for Span in Spans do
    begin
      if not fHiliteSpanClsLookup.ContainsKey(Span) then
        raise ECommandError.Create(
          Cmd.Name, sBadSpanCls + Format('"%s', [Span])
        );
      Include(Result, fHiliteSpanClsLookup[Span]);
    end;
  end
  else
  begin
    // Not a set parameter - test for a valid alias
    if not fHiliteAliasLookup.ContainsKey(Param) then
      raise ECommandError.Create(
        Cmd.Name, sBadParam + Format('"%s"', [Param])
      );
    Result := fHiliteAliasLookup[Param];
  end;
end;

function TParams.GetNumericParameter(const Cmd: TCommand; const Lo,
  Hi: UInt16): UInt16;
var
  Param: string;
  Value: Integer;
resourcestring
  sNotNumber = 'Numeric parameter expected for %s';
  sOutOfRange = 'Parameter for %s must be in range ';
begin
  Param := GetStringParameter(Cmd);
  if not TryStrToInt(Param, Value) then
    raise ECommandError.Create(Cmd.Name, sNotNumber);
  if (Value < Lo) or (Value > Hi) then
    raise ECommandError.Create(
      Cmd.Name, sOutOfRange + Format('%0:d..%1:d', [Lo, Hi])
    );
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
  if (Result = '')
    or (AnsiStartsStr('-', Result) and (Result <> '-')) then
    raise ECommandError.Create(Cmd.Name, sNoParam);
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

function TParams.GetViewportParameter(const Cmd: TCommand): TViewport;
var
  Param: string;
resourcestring
  sBadValue = 'Unrecognised viewport value "%s"';
begin
  Param := GetStringParameter(Cmd);
  if not fViewportLookup.ContainsKey(Param) then
    raise Exception.CreateFmt(sBadValue, [Param]);
  Result := fViewportLookup[Param];
end;

function TParams.GetWarnings: TArray<string>;
var
  Idx: Integer;
begin
  SetLength(Result, fWarnings.Count);
  for Idx := 0 to Pred(fWarnings.Count) do
    Result[Idx] := fWarnings[Idx];
end;

function TParams.HasWarnings: Boolean;
begin
  Result := fWarnings.Count > 0;
end;

function TParams.IsV1Command(const Name: string): Boolean;
begin
  Result := fV1CommandLookup.Contains(Name);
end;

procedure TParams.Parse;

  procedure ParseQueue(const IsConfigCmd: Boolean; const ErrorFmtStr: string);
  var
    CmdName: string;
  begin
    try
      while fParamQueue.Count > 0 do
      begin
        if AnsiStartsStr('-', fParamQueue.Peek) then
        begin
          CmdName := fParamQueue.Peek;
          ParseCommand(IsConfigCmd);
          if not IsConfigCmd and not fFirstCommandFound then
            fFirstCommandFound := True;
        end
        else
          ParseFileName;
      end;
    except
      on E: ECommandError do
        raise Exception.CreateFmt(
          ErrorFmtStr,
          [Format(E.FormatStr, [AdjustCommandName(E.CommandName, IsConfigCmd)])]
        );
      on E: Exception do
        raise Exception.CreateFmt(ErrorFmtStr, [E.Message]);
    end;
  end;

resourcestring
  sConfigFileErrorFmt = '(in config file) %s';
  sCommandLineErrorFmt = '%s';
begin
  fFirstCommandFound := False;
  GetConfigParams;
  ParseQueue(True, sConfigFileErrorFmt);
  GetCmdLineParams;
  ParseQueue(False, sCommandLineErrorFmt);
end;

procedure TParams.ParseCommand(const IsConfigCmd: Boolean);
resourcestring
  // Error messages
  sBadCommand = 'Unrecognised command "%s"';
  sBadParam = 'Unrecognised parameter "%0:s" for command "%1:s"';
  sCantBeSwitch = '%s cannot be a switch command';
  sMustBeSwitch = '%s must be a switch command: append "+" or "-"';
  sBlacklisted = 'The "%s" command is not permitted';
  // Warnings
  sDeprecatedCmd = 'The "%s" command is deprecated';
  sDeprecatedParam = 'The "%0:s" parameter of the "%1:s" command is deprecated';
  sDeprecatedSwitch = 'The "%s" switch is deprecated';
  sDepDocType = 'The "html4" parameter of the "%s" command is deprecated';
var
  Command: TCommand;
  CommandId: TCommandId;
  Param: string;
begin
  Command := fParamQueue.Dequeue;
  if not fCmdLookup.ContainsKey(Command.Name) then
    raise ECommandError.Create(Command.Name, sBadCommand);
  CommandId := fCmdLookup[Command.Name];

  if IsConfigCmd and fConfigBlacklist.Contains(CommandId) then
    raise ECommandError.Create(Command.Name, sBlacklisted);

  if Command.IsSwitch and not fSwitchCmdLookup.Contains(Command.Name) then
    raise ECommandError.Create(Command.Name, sCantBeSwitch);
  if not Command.IsSwitch and fSwitchCmdLookup.Contains(Command.Name) then
    raise ECommandError.Create(Command.Name, sMustBeSwitch);

  case CommandId of
    siInputClipboard:
    begin
      if IsV1Command(Command.Name) then
        fWarnings.Add(Format(sDeprecatedCmd, [Command.Name]));
      fConfig.InputSource := isClipboard;
    end;
    siInputStdIn:
      fConfig.InputSource := isStdIn;
    siOutputClipboard:
    begin
      if IsV1Command(Command.Name) then
        fWarnings.Add(Format(sDeprecatedCmd, [Command.Name]));
      fConfig.OutputSink := osClipboard;
    end;
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
      if fConfig.DocType = dtHTML4 then
        fWarnings.Add(
          Format(sDepDocType, [AdjustCommandName(Command.Name, IsConfigCmd)])
        );
      fParamQueue.Dequeue;
    end;
    siFragment:
    begin
      if IsV1Command(Command.Name) then
        fWarnings.Add(Format(sDeprecatedCmd, [Command.Name]));
      fConfig.DocType := dtFragment;
    end;
    siForceHideCSS:
    begin
      fWarnings.Add(
        Format(sDeprecatedCmd, [AdjustCommandName(Command.Name, IsConfigCmd)])
      );
      fConfig.HideCSS := True;
    end;
    siHideCSS:
    begin
      fWarnings.Add(
        Format(sDeprecatedCmd, [AdjustCommandName(Command.Name, IsConfigCmd)])
      );
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
      fWarnings.Add(
        Format(sDeprecatedCmd, [AdjustCommandName(Command.Name, IsConfigCmd)])
      );
      fConfig.LegacyCSSNames := GetBooleanParameter(Command);
      fParamQueue.Dequeue;
    end;
    siLanguage:
    begin
      fConfig.Language := GetStringParameter(Command);
      if (fConfig.Language = '-') or (fConfig.Language = 'neutral') then
        fConfig.Language := '';
      fParamQueue.Dequeue;
    end;
    siLanguageNeutral:
    begin
      // TODO: modify warning to say to use `--language -`
      fWarnings.Add(
        Format(sDeprecatedCmd, [AdjustCommandName(Command.Name, IsConfigCmd)])
      );
      fConfig.Language := '';
    end;
    siTitle:
    begin
      // TODO: modify warning to say to use `--title -`
      fConfig.Title := GetStringParameter(Command);
      if fConfig.Title = '-' then
        fConfig.Title := '';
      fParamQueue.Dequeue;
    end;
    siTitleDefault:
    begin
      fWarnings.Add(
        Format(sDeprecatedCmd, [AdjustCommandName(Command.Name, IsConfigCmd)])
      );
      fConfig.Title := '';
    end;
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
      begin
        if Command.SwitchValue = True then
          fConfig.TrimSource := tsLines
        else
          fConfig.TrimSource := tsNone;
        fWarnings.Add(
          Format(
            sDeprecatedSwitch, [AdjustCommandName(Command.Name, IsConfigCmd)]
          )
        );
      end
      else
      begin
        Param := GetStringParameter(Command);
        if fTrimLookup.ContainsKey(Param) then
          fConfig.TrimSource := fTrimLookup[Param]
        else if fBooleanLookup.ContainsKey(Param) then
        begin
          if fBooleanLookup[Param] = True then
            fConfig.TrimSource := tsLines
          else
            fConfig.TrimSource := tsNone;
          fWarnings.Add(
            Format(
              sDeprecatedParam,
              [Param, AdjustCommandName(Command.Name, IsConfigCmd)]
            )
          );
        end
        else
          raise Exception.CreateFmt(
            sBadParam, [Param, AdjustCommandName(Command.Name, IsConfigCmd)]
          );
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
    siLineNumberStart:
    begin
      fConfig.LineNumberStart := GetNumericParameter(
        Command, Low(TLineNumberStart), High(TLineNumberStart)
      );
      fParamQueue.Dequeue;
    end;
    siStriping:
    begin
      fConfig.Striping := GetBooleanParameter(Command);
      fParamQueue.Dequeue;
    end;
    siHelp:
      fConfig.ShowHelp := True;
    siVersion:
      fConfig.ShowVersion := True;
    siVerbosity:
    begin
      fConfig.Verbosity := GetVerbosityParameter(Command);
      fParamQueue.Dequeue;
    end;
    siQuiet:
      fConfig.Verbosity := vbQuiet;
    siViewport:
    begin
      fConfig.Viewport := GetViewportParameter(Command);
      fParamQueue.Dequeue;
    end;
    siEdgeCompatibility:
    begin
      fConfig.EdgeCompatibility := GetBooleanParameter(Command);
      fParamQueue.Dequeue;
    end;
    siInhibitStyling:
    begin
      fConfig.ExcludedSpans := GetExcludedSpansParameter(Command);
      fParamQueue.Dequeue;
    end;
  end;
end;

procedure TParams.ParseFileName;
resourcestring
  sMixedFileNames = 'Accepting input file names after the first command '
    + 'is deprecated.';
begin
  // Parse file name at head of queue
  if fFirstCommandFound then
    fWarnings.Add(sMixedFileNames);
  fConfig.AddInputFile(fParamQueue.Peek);
  fConfig.InputSource := isFiles;
  // Next parameter
  fParamQueue.Dequeue;
end;

function TParams.TryParseSetParam(const Param: string;
  out Elems: TStringDynArray): Boolean;
var
  ParamContent: string;
begin
  // A set parameter has the form (in sort of BNF):
  //   "{" [ <elem> { "," <elem> } ] "}"
  // where elem is simple text
  // E.gs:
  //   {} - empty set
  //   {elem} - one item set
  //   {elem1,elem2,elem3} - three item set
  // Note - there can be no spaces anywhere in the parameter
  SetLength(Elems, 0);
  if Length(Param) < 2 then
    Exit(False);
  if Param[1] <> SetParamOpener then
    Exit(False);
  if Param[Length(Param)] <> SetParamCloser then
    Exit(False);
  ParamContent := Copy(Param, 2, Length(Param) - 2);
  Elems := SplitString(ParamContent, ',');
  Result := True;
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
  sBadSwitch = '%s is not a switch command';
begin
  if not IsSwitch then
    raise ECommandError.Create(Name, sBadSwitch);
  Result := CharInSet(fCommand[3], TrueSwitchChars);
end;

class procedure TCommand.ValidateCommand(const Cmd: string);
resourcestring
  sBadCommand = '"%s" is not a valid command';
begin
  if not IsCommand(Cmd) then
    raise ECommandError.Create(Cmd, sBadCommand);
end;

{ ECommandError }

constructor ECommandError.Create(const CommandName, FormatStr: string);
begin
  inherited Create('');
  fCommandName := CommandName;
  fFormatStr := FormatStr;
end;

end.

