{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2007-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Implements class that stores program's configuration information.
}


unit UConfig;


interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Hiliter.UGlobals;

type

  ///  <summary>Enumerates different sources of input used by program.</summary>
  TInputSource = (
    isStdIn,        // standard input
    isFiles,        // files from command line
    isClipboard     // clipboard
  );

  ///  <summary>Enumerates different output sinks used by program.</summary>
  TOutputSink = (
    osStdOut,       // standard output
    osFile,         // file from output file switch
    osClipboard     // clipboard
  );

  ///  <summary>Enumerates ids of supported output encodings.</summary>
  TOutputEncodingId = (
    oeUTF8,         // UTF-8 encoding with BOM
    oeUTF16,        // Unicode little endian encoding with BOM
    oeWindows1252,  // Windows-1252 aka CP-1252 encoding
    oeISO88591      // ISO-8859-1 aka Latin-1 encoding
  );

  ///  <summary>Enumerates possible sources of style sheets.</summary>
  TCSSSource = (
    csDefault,      // use default style sheet
    csFile,         // get CSS from file
    csLink          // link to external style sheet
  );

  ///  <summary>Enumerates various kinds of documents that can be generated by
  ///  program.</summary>
  TDocType = (
    dtXHTML,        // complete XHTML document
    dtHTML4,        // complete HTML 4 document
    dtHTML5,        // complete HTML 5 document
    dtFragment      // a fragment of HTML code, compatible with all HTML types
  );

  ///  <summary>Enumerate different kinds of verbosity state.</summary>
  TVerbosityState = (
    vsInfo,
    vsWarnings,
    vsErrors
  );

  ///  <summary>Set of the vebosity states supported by the program.</summary>
  TVerbosityStates = set of TVerbosityState;

  ///  <summary>Enumerates different viewport options applied to complete
  ///  (X)HTML documents.</summary>
  TViewport = (
    vpNone,
    vpPhone
  );

  ///  <summary>Enumerates different trim operations applied to source code.
  ///  prior to processing.</summary>
  TTrimOperation = (
    tsNone,         // don't trim anything
    tsLines,        // trim blank lines from beginning and end of a source file
    tsSpaces,       // trim trailing spaces from source code lines
    tsBoth          // trim blank lines and spaces
  );

  ///  <summary>Valid range of separator lines between files.</summary>
  TSeparatorLines = 0..16;

  ///  <summary>Valid range of line number widths.</summary>
  TLineNumberWidth = 1..6;

  //   <summary>Valid range of line number starting values.</summary>
  TLineNumberStart = 1..9999;

  ///  <summary>Class that records details of program's configuration. Used to
  ///  determine how program behaves.</summary>
  TConfig = class(TObject)
  private
    fDocType: TDocType;
    fInputSource: TInputSource;
    fOutputSink: TOutputSink;
    fShowHelp: Boolean;
    fShowVersion: Boolean;
    fShowConfigCommands: Boolean;
    fVerbosityStates: TVerbosityStates;
    fHideCSS: Boolean;
    fOutputFile: string;
    fLanguage: string;
    fTitle: string;
    fBrandingPermitted: Boolean;
    fCSSSource: TCSSSource;
    fCSSLocation: string;
    fOutputEncodingId: TOutputEncodingId;
    fTrimSource: TTrimOperation;
    fInFiles: TStringList;
    fSeparatorLines: TSeparatorLines;
    fLegacyCSSNames: Boolean;
    fUseLineNumbering: Boolean;
    fLineNumberWidth: TLineNumberWidth;
    fLineNumberPadding: Char;
    fLineNumberStart: TLineNumberStart;
    fStriping: Boolean;
    fViewport: TViewport;
    fEdgeCompatibility: Boolean;
    fExcludedSpans: THiliteElements;
    fConfigFileEntries: TList<TPair<string,string>>;
    function GetInputFiles: TArray<string>;
  public
    const
      QuietVerbosity = [vsErrors];
      NoWarnVerbosity = [vsInfo, vsErrors];
      NormalVerbosity = [vsInfo, vsWarnings, vsErrors];
      SilentVerbosity = [];
      DefaultVerbosity = NormalVerbosity;
    constructor Create;
    destructor Destroy; override;
    property InputSource: TInputSource
      read fInputSource write fInputSource default isStdIn;
    property OutputSink: TOutputSink
      read fOutputSink write fOutputSink default osStdOut;
    property DocType: TDocType
      read fDocType write fDocType default dtXHTML;
    property Verbosity: TVerbosityStates
      read fVerbosityStates write fVerbosityStates default NormalVerbosity;
    property ShowHelp: Boolean
      read fShowHelp write fShowHelp default False;
    property ShowVersion: Boolean
      read fShowVersion write fShowVersion default False;
    property ShowConfigCommands: Boolean
      read fShowConfigCommands write fShowConfigCommands;
    property HideCSS: Boolean read fHideCSS write fHideCSS;
    property CSSSource: TCSSSource read fCSSSource write fCSSSource;
    property CSSLocation: string read fCSSLocation write fCSSLocation;
    property OutputFile: string
      read fOutputFile write fOutputFile;
    property OutputEncodingId: TOutputEncodingId
      read fOutputEncodingId write fOutputEncodingId default oeUTF8;
    property Language: string read fLanguage write fLanguage;
    property Title: string read fTitle write fTitle;
    property InputFiles: TArray<string> read GetInputFiles;
    property BrandingPermitted: Boolean
      read fBrandingPermitted write fBrandingPermitted default True;
    property TrimSource: TTrimOperation
      read fTrimSource write fTrimSource default tsLines;
    property SeparatorLines: TSeparatorLines
      read fSeparatorLines write fSeparatorLines default 1;
    property LegacyCSSNames: Boolean
      read fLegacyCSSNames write fLegacyCSSNames default False;
    property UseLineNumbering: Boolean
      read fUseLineNumbering write fUseLineNumbering default False;
    property LineNumberWidth: TLineNumberWidth
      read fLineNumberWidth write fLineNumberWidth default 3;
    property LineNumberPadding: Char
      read fLineNumberPadding write fLineNumberPadding default ' ';
    property LineNumberStart: TLineNumberStart
      read fLineNumberStart write fLineNumberStart default 1;
    property Striping: Boolean read fStriping write fStriping default False;
    property Viewport: TViewport read fViewport write fViewport default vpNone;
    property EdgeCompatibility: Boolean
      read fEdgeCompatibility write fEdgeCompatibility default False;
    property ExcludedSpans: THiliteElements
      read fExcludedSpans write fExcludedSpans default [];
    procedure AddInputFile(const FN: string);
    function OutputEncoding: TEncoding;
    function OutputEncodingName: string;
    procedure AddConfigFileEntry(const AEntry: TPair<string,string>);
    function ConfigFileEntries: TArray<TPair<string,string>>;
  end;


implementation

uses
  Winapi.Windows;


{ TConfig }

procedure TConfig.AddConfigFileEntry(const AEntry: TPair<string, string>);
begin
  fConfigFileEntries.Add(AEntry);
end;

procedure TConfig.AddInputFile(const FN: string);
begin
  fInFiles.Add(FN);
end;

function TConfig.ConfigFileEntries: TArray<TPair<string, string>>;
begin
  Result := fConfigFileEntries.ToArray;
end;

constructor TConfig.Create;
begin
  inherited;
  fInFiles := TStringList.Create;
  fInputSource := isStdIn;
  fOutputSink := osStdOut;
  fDocType := dtXHTML;
  fShowHelp := False;
  fShowVersion := False;
  fShowConfigCommands := False;
  fHideCSS := False;
  fOutputEncodingId := oeUTF8;
  fBrandingPermitted := True;
  fLanguage := '';
  fVerbosityStates := NormalVerbosity;
  fTrimSource := tsLines;
  fSeparatorLines := 1;
  fLegacyCSSNames := False;
  fUseLineNumbering := False;
  fLineNumberWidth := 3;
  fLineNumberStart := 1;
  fLineNumberPadding := ' ';
  fStriping := False;
  fViewport := vpNone;
  fEdgeCompatibility := False;
  fExcludedSpans := [];
  fConfigFileEntries := TList<TPair<string,string>>.Create;
end;

destructor TConfig.Destroy;
begin
  fConfigFileEntries.Free;
  fInFiles.Free;
  inherited;
end;

function TConfig.GetInputFiles: TArray<string>;
var
  Idx: Integer;
begin
  SetLength(Result, fInFiles.Count);
  for Idx := 0 to Pred(fInFiles.Count) do
    Result[Idx] := fInFiles[Idx];
end;

function TConfig.OutputEncoding: TEncoding;
begin
  Result := nil;
  if not (fOutputSink in [osStdOut, osFile]) then
    Exit;
  case fOutputEncodingId of
    oeUTF8: Result := TEncoding.UTF8;
    oeUTF16: Result := TEncoding.Unicode;
    oeWindows1252: Result := TMBCSEncoding.Create(1252);
    oeISO88591: Result := TMBCSEncoding.Create(28591);
  end;
  Assert(Assigned(Result), 'TConfig.OutputEncoding: Encoding not created');
end;

function TConfig.OutputEncodingName: string;
const
  Map: array[TOutputEncodingId] of string = (
    'UTF-8', 'UTF-16', 'Windows-1252', 'ISO-8859-1'
  );
begin
  if not (fOutputSink in [osStdOut, osFile]) then
    Exit('');
  Result := Map[fOutputEncodingId];
end;

end.

