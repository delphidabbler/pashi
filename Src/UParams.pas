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

  NOTE: switches are case sensitive.
}

uses
  // Delphi
  Generics.Collections,
  // Project
  UConfig;

type

  {
    TSwitchId:
    Ids representing each valid command line switch.
    }
  TSwitchId = (siInputClipboard, // read input from clipboard
    siOutputClipboard, // write output to clipboard
    siOutputFile, // write output to a file
    siOuputEncoding, // use specified encoding for output
    siDocTypeXHTMLFrag, // write output as XHTML document fragment
    siDocTypeHideCSS, // hide embedded CSS in comments
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
    Class that parses command line and stores settings according to switches
    provided.
    }
  TParams = class(TObject)
  strict private
  var
    fParamQueue: TQueue<string>; // Queue of parameters to be processed
    fSwitchLookup: TDictionary<string, TSwitchId>;
    fEncodingLookup: TDictionary<string, TOutputEncodingId>;
    fConfig: TConfig; // Reference to program's configuration object
    procedure PopulateCommandQueue;
    procedure ParseSwitch;
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
  // lookup table for switches (switches are case sensitive)
  fSwitchLookup := TDictionary<string,
    TSwitchId>.Create(TStringEqualityComparer.Create);
  fSwitchLookup.Add('-rc', siInputClipboard);
  fSwitchLookup.Add('-wc', siOutputClipboard);
  fSwitchLookup.Add('-o', siOutputFile);
  fSwitchLookup.Add('-e', siOuputEncoding);
  fSwitchLookup.Add('-frag', siDocTypeXHTMLFrag);
  fSwitchLookup.Add('-hidecss', siDocTypeHideCSS);
  fSwitchLookup.Add('-style', siEmbedCSS);
  fSwitchLookup.Add('-linkcss', siLinkCSS);
  fSwitchLookup.Add('-lang', siLanguage);
  fSwitchLookup.Add('-title', siTitle);
  fSwitchLookup.Add('-nobrand', siNoBranding);
  fSwitchLookup.Add('-h', siHelp);
  fSwitchLookup.Add('-q', siQuiet);
  // lookup table for encoding values (values are case insensitive
  fEncodingLookup := TDictionary<string,
    TOutputEncodingId>.Create(TTextEqualityComparer.Create);
  fEncodingLookup.Add('utf-8', oeUTF8);
  fEncodingLookup.Add('utf8', oeUTF8);
  fEncodingLookup.Add('utf-16', oeUTF16);
  fEncodingLookup.Add('utf16', oeUTF16);
  fEncodingLookup.Add('unicode', oeUTF16);
  fEncodingLookup.Add('windows-1252', oeWindows1252);
  fEncodingLookup.Add('windows1252', oeWindows1252);
  fEncodingLookup.Add('latin-1', oeWindows1252);
  fEncodingLookup.Add('latin1', oeWindows1252);
  fEncodingLookup.Add('iso-8859-1', oeISO88591);
end;

destructor TParams.Destroy;
{ Class destructor. Tears down object.
  }
begin
  fEncodingLookup.Free;
  fSwitchLookup.Free;
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
      ParseSwitch
    else
      ParseFileName;
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

procedure TParams.ParseSwitch;
resourcestring
  // Error messages
  sBadSwitch = 'Invalid switch "%s"';
  sMissingFileParam = 'A file name must immediately follow %s switch';
  sMissingURLParam = 'A URL must immediately follow %s switch';
  sMissingOutputEncodingParam = 'An encoding must immediatley follow %s switch';
  sBadOutputEncodingParam = 'Unrecognised encoding "%s"';
  sMissingLanguageParam = 'A language code must immediately follow %s switch';
  sMissingTitleParam = 'Title text must immediately follow %s switch';
var
  Switch: string;
  SwitchId: TSwitchId;
begin
  // NOTE: don't try to re-factor fParamQueue.Dequeue out of case statement to
  // place after statement because that will break processing of siOutputFile

  // Parse switch at head of queue
  Switch := fParamQueue.Peek;
  if not fSwitchLookup.ContainsKey(Switch) then
    raise Exception.CreateFmt(sBadSwitch, [Switch]);
  SwitchId := fSwitchLookup[Switch];
  case SwitchId of
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
        // switch is ignored if following param is not a file name
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingFileParam, [Switch]);
        fConfig.OutputSink := osFile;
        fConfig.OutputFile := fParamQueue.Dequeue;
      end;
    siOuputEncoding:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingOutputEncodingParam, [Switch]);
        if not fEncodingLookup.ContainsKey(fParamQueue.Peek) then
          raise Exception.CreateFmt(sBadOutputEncodingParam,
            [fParamQueue.Peek]);
        fConfig.OutputEncodingId := fEncodingLookup[fParamQueue.Dequeue];
      end;
    siDocTypeXHTMLFrag:
      begin
        fConfig.DocType := dtXHTMLFragment;
        fParamQueue.Dequeue;
      end;
    siDocTypeHideCSS:
      begin
        fConfig.HideCSS := True;
        fParamQueue.Dequeue;
      end;
    siEmbedCSS:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingFileParam, [Switch]);
        fConfig.CSSSource := csFile;
        fConfig.CSSLocation := fParamQueue.Dequeue;
      end;
    siLinkCSS:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingURLParam, [Switch]);
        fConfig.CSSSource := csLink;
        fConfig.CSSLocation := fParamQueue.Dequeue;
      end;
    siLanguage:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingLanguageParam, [Switch]);
        fConfig.Language := fParamQueue.Dequeue;
      end;
    siTitle:
      begin
        fParamQueue.Dequeue;
        if (fParamQueue.Count = 0) or AnsiStartsStr('-', fParamQueue.Peek) then
          raise Exception.CreateFmt(sMissingTitleParam, [Switch]);
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

procedure TParams.PopulateCommandQueue;
var
  Idx: Integer;
begin
  fParamQueue.Clear;
  for Idx := 1 to ParamCount do
    fParamQueue.Enqueue(ParamStr(Idx));
end;

end.
