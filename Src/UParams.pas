{
  * UParams.pas
  *
  * Implements class that parses command line and records details.
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
  * The Original Code is UParams.pas.
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

unit UParams;

interface

{
  Command Line Parameters Supported by TParams
  --------------------------------------------

  <filename1> <filename2> ...
  When one or more file names are listed input is taken from a concatenation
  of the files instead from standard input.
  -rc
  Takes input from clipboard rather than standard input.
  -wc
  Writesoutput to clipboard (CF_UNICODETEXT format) instead of standard
  output.
  -o <filename>
  Writes output to file named in following parameter instead of standard
  output.
  -e <encoding>
  Sets encoding to be used for output XHTML. For valid values for <encoding>
  see the creation of the encoding dictionary object below. Values are case
  insensitive.
  -frag
  Writes XHTML fragment rather than complete XHTML document. Code contains
  only <pre> tag enclosing highlighted containing source code. User must
  provide style sheet with required style names.
  -hidecss
  Wraps embedded CSS in HTML comments.
  -q
  Quiet mode. Inhibits writing to console. This setting is ignored when help
  screen is displayed or if error occurs while parsing command line.
  -h
  Displays help screen.

  NOTE: commands are case sensitive.
}

uses
  // Delphi
  Generics.Collections,
  // Project
  UConfig;

type

  {
    TCommandId:
    Ids representing each valid command line comamnd.
  }
  TCommandId = (
    siInputClipboard, // read input from clipboard
    siOutputClipboard, // write output to clipboard
    siOutputFile, // write output to a file
    siOuputEncoding, // use specified encoding for output
    siOutputDocType,  // type of document to be output
    siFragment, // write output as XHTML document fragment
    siHideCSS, // hide embedded CSS in comments
    siEmbedCSS, // embed css from a file
    siLinkCSS, // link to external CSS file
    siLanguage, // specify output language
    siTitle, // document title
    siNoBranding, // inhibits branding in code fragments
    siHelp, // display help
    siQuiet // don't display any output to console
    );

  {
    TParams:
    Class that parses command line and stores settings according to commands
    provided.
  }
  TParams = class(TObject)
  strict private
  var
    fParamQueue: TQueue<string>; // Queue of parameters to be processed
    fCmdLookup: TDictionary<string, TCommandId>;
    fEncodingLookup: TDictionary<string, TOutputEncodingId>;
    fDocTypeLookup: TDictionary<string, TDocType>;
    fConfig: TConfig; // Reference to program's configuration object
    procedure PopulateCommandQueue;
    procedure ParseCommand;
    procedure ParseFileName;
  public
    constructor Create(const Config: TConfig);
    { Class constructor. Initialises object.
      @param Config [in] Configuration object to be updated from command line.
      }
    destructor Destroy; override;
    { Class destructor. Tears down object.
      }
    procedure Parse;
    { Parses the command line.
      @except Exception raised if error in command line.
      }
  end;

implementation

uses
  // Delphi
  StrUtils, SysUtils,
  // Project
  UComparers;

{ TParams }

constructor TParams.Create(const Config: TConfig);
{ Class constructor. Initialises object.
  @param Config [in] Configuration object to be updated from command line.
  }
begin
  Assert(Assigned(Config), 'TParams.Create: Config is nil');
  inherited Create;
  fConfig := Config;
  fParamQueue := TQueue<string>.Create;
  // create lookup table for commands: case sensitive
  fCmdLookup := TDictionary<string,TCommandId>.Create(
    TStringEqualityComparer.Create
  );
  with fCmdLookup do
  begin
    // short forms
    Add('-b', siNoBranding);
    Add('-c', siHideCSS);
    Add('-d', siOutputDocType);
    Add('-e', siOuputEncoding);
    Add('-h', siHelp);
    Add('-k', siLinkCSS);
    Add('-l', siLanguage);
    Add('-o', siOutputFile);
    Add('-q', siQuiet);
    Add('-r', siInputClipboard);
    Add('-s', siEmbedCSS);
    Add('-t', siTitle);
    Add('-w', siOutputClipboard);
    // long forms
    Add('--doctype', siOutputDocType);
    Add('--embed-css', siEmbedCSS);
    Add('--encoding', siOuputEncoding);
    Add('--help', siHelp);
    Add('--hide-css', siHideCSS);
    Add('--input-clipboard', siInputClipboard);
    Add('--language', siLanguage);
    Add('--link-css', siLinkCSS);
    Add('--no-branding', siNoBranding);
    Add('--output-clipboard', siOutputClipboard);
    Add('--output-file', siOutputFile);
    Add('--quiet', siQuiet);
    Add('--title', siTitle);
    // aliases for backwards compatibility with v1.x
    Add('-frag', siFragment);
    Add('-hidecss', siHideCSS);
    Add('-rc', siInputClipboard);
    Add('-wc', siOutputClipboard);
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
    Add('latin-1', oeWindows1252);
    Add('latin1', oeWindows1252);
    Add('iso-8859-1', oeISO88591);
  end;
  fDocTypeLookup := TDictionary<string, TDocType>.Create(
    TTextEqualityComparer.Create
  );
  with fDocTypeLookup do
  begin
    Add('xhtml', dtXHTML);
    Add('xhtml-fragment', dtXHTMLFragment);
  end;
end;

destructor TParams.Destroy;
{ Class destructor. Tears down object.
  }
begin
  fEncodingLookup.Free;
  fCmdLookup.Free;
  fParamQueue.Free;
  inherited;
end;

procedure TParams.Parse;
{ Parses the command line.
  @except Exception raised if error in command line.
  }
begin
  PopulateCommandQueue;
  // Loop through all commands on command line
  while fParamQueue.Count > 0 do
  begin
    // Check command line item
    if AnsiStartsStr('-', fParamQueue.Peek) then
      ParseCommand
    else
      ParseFileName;
  end;
end;

procedure TParams.ParseCommand;
resourcestring
  // Error messages
  sBadCommand = 'Invalid command "%s"';
  sMissingFileParam = 'A file name must immediately follow %s command';
  sMissingURLParam = 'A URL must immediately follow %s command';
  sMissingOutputEncodingParam =
    'An encoding must immediatley follow %s command';
  sBadOutputEncodingParam = 'Unrecognised encoding "%s"';
  sMissingLanguageParam = 'A language code must immediately follow %s command';
  sMissingTitleParam = 'Title text must immediately follow %s command';
  sMissingDocTypeParam = 'A document type must immediately follow %s command';
  sBadDocTypeParam = 'Unrecognised document type "%s"';
var
  Command: string;
  CommandId: TCommandId;
begin
  // NOTE: don't try to re-factor fParamQueue.Dequeue out of case statement to
  // place after statement because that will break processing of siOutputFile

  // Parse Command at head of queue
  Command := fParamQueue.Peek;
  if not fCmdLookup.ContainsKey(Command) then
    raise Exception.CreateFmt(sBadCommand, [Command]);
  CommandId := fCmdLookup[Command];
  case CommandId of
    siInputClipboard:
      begin
        fConfig.InputSource := isClipboard;
        fParamQueue.Dequeue;
      end;
    siOutputClipboard:
      begin
        fConfig.OutputSink := osClipboard;
        fParamQueue.Dequeue;
      end;
    siOutputFile:
      begin
        // Command is ignored if following param is not a file name
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingFileParam, [Command]);
        fConfig.OutputSink := osFile;
        fConfig.OutputFile := fParamQueue.Dequeue;
      end;
    siOuputEncoding:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingOutputEncodingParam, [Command]);
        if not fEncodingLookup.ContainsKey(fParamQueue.Peek) then
          raise Exception.CreateFmt(
            sBadOutputEncodingParam, [fParamQueue.Peek]
          );
        fConfig.OutputEncodingId := fEncodingLookup[fParamQueue.Dequeue];
      end;
    siOutputDocType:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingDocTypeParam, [Command]);
        if not fDocTypeLookup.ContainsKey(fParamQueue.Peek) then
          raise Exception.CreateFmt(sBadDocTypeParam, [fParamQueue.Peek]);
        fConfig.DocType := fDocTypeLookup[fParamQueue.Dequeue];
      end;
    siFragment:
      begin
        fConfig.DocType := dtXHTMLFragment;
        fParamQueue.Dequeue;
      end;
    siHideCSS:
      begin
        fConfig.HideCSS := True;
        fParamQueue.Dequeue;
      end;
    siEmbedCSS:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingFileParam, [Command]);
        fConfig.CSSSource := csFile;
        fConfig.CSSLocation := fParamQueue.Dequeue;
      end;
    siLinkCSS:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingURLParam, [Command]);
        fConfig.CSSSource := csLink;
        fConfig.CSSLocation := fParamQueue.Dequeue;
      end;
    siLanguage:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingLanguageParam, [Command]);
        fConfig.Language := fParamQueue.Dequeue;
      end;
    siTitle:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingTitleParam, [Command]);
        fConfig.Title := fParamQueue.Dequeue;
      end;
    siNoBranding:
      begin
        fConfig.BrandingPermitted := False;
        fParamQueue.Dequeue;
      end;
    siHelp:
      begin
        fConfig.ShowHelp := True;
        fParamQueue.Dequeue;
      end;
    siQuiet:
      begin
        fConfig.Quiet := True;
        fParamQueue.Dequeue;
      end;
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

procedure TParams.PopulateCommandQueue;
var
  Idx: Integer;
begin
  fParamQueue.Clear;
  for Idx := 1 to ParamCount do
    fParamQueue.Enqueue(ParamStr(Idx));
end;

end.
