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
  TSwitchId = (
    siInputClipboard,     // read input from clipboard
    siOutputClipboard,    // write output to clipboard
    siOutputFile,         // write output to a file
    siDocTypeXHTMLFrag,   // write output as XHTML document fragment
    siDocTypeHideCSS,     // hide embedded CSS in comments
    siHelp,               // display help
    siQuiet               // don't display any output to console
  );

  {
  TParams:
    Class that parses command line and stores settings according to switches
    provided.
  }
  TParams = class(TObject)
  strict private
    var
      fParamQueue: TQueue<string>;  // Queue of parameters to be processed
      fSwitchLookup: TDictionary<string,TSwitchId>;
      fConfig: TConfig;           // Reference to program's configuration object
    procedure PopulateCommandQueue;
    procedure ParseSwitch;
    procedure ParseFileName;
  public
    constructor Create(const Config: TConfig);
      {Class constructor. Initialises object.
        @param Config [in] Configuration object to be updated from command line.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    procedure Parse;
      {Parses the command line.
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
  {Class constructor. Initialises object.
    @param Config [in] Configuration object to be updated from command line.
  }
begin
  Assert(Assigned(Config), 'TParams.Create: Config is nil');
  inherited Create;
  fConfig := Config;
  fParamQueue := TQueue<string>.Create;
  // create lookup table for switches (switches are case sensitive)
  fSwitchLookup := TDictionary<string,TSwitchId>.Create(
    TStringEqualityComparer.Create
  );
  fSwitchLookup.Add('-rc', siInputClipboard);
  fSwitchLookup.Add('-wc', siOutputClipboard);
  fSwitchLookup.Add('-o', siOutputFile);
  fSwitchLookup.Add('-frag', siDocTypeXHTMLFrag);
  fSwitchLookup.Add('-hidecss', siDocTypeHideCSS);
  fSwitchLookup.Add('-h', siHelp);
  fSwitchLookup.Add('-q', siQuiet);
end;

destructor TParams.Destroy;
  {Class destructor. Tears down object.
  }
begin
  fSwitchLookup.Free;
  fParamQueue.Free;
  inherited;
end;

procedure TParams.Parse;
  {Parses the command line.
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
  sBadOutputFileSwitch = 'A file name must immediately follow -o switch';
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
        raise Exception.Create(sBadOutputFileSwitch);
      fConfig.OutputSink := osFile;
      fConfig.OutputFile := fParamQueue.Dequeue;
    end;
    siDocTypeXHTMLFrag:
    begin
      fConfig.DocType := dtXHTMLFragment;
      fParamQueue.Dequeue;
    end;
    siDocTypeHideCSS:
    begin
      fConfig.DocType := dtXHTMLHideCSS;
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

