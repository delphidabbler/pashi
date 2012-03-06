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
  SWITCHES:
    -rc
      Takes input from clipboard rather than standard input.
    -wc
      Writes XHTML output to clipboard (CF_TEXT format) rather than standard
      output.
    -frag
      Writes XHTML fragment rather than complete XHTML document - code contains
      only <pre> tag enclosing highlighted containing source code. User must
      provide style sheet with required style names.
    -hidecss
      Wraps embedded CSS in HTML comments.
    -q
      Quiet mode. Inhibits writing to console. This setting is ignored when
      help screen is displayed or if error occurs while parsing command line.
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
      fCmdQueue: TQueue<string>;  // Queue of commands to be processed
      fConfig: TConfig;           // Reference to program's configuration object
    procedure PopulateCommandQueue;
    function SwitchToId(const Switch: string; out Id: TSwitchId): Boolean;
      {Finds id of a switch.
        @param Switch [in] Text defining switch.
        @param Id [out] Id of switch. Undefined if switch is invalid.
        @return True if switch is valid, False otherwise.
      }
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
  StrUtils, SysUtils;


const
  // Map of switches onto switch id.
  cSwitches: array[1..7] of record
    Switch: string;   // switch
    Id: TSwitchId;    // switch id
  end = (
    // Input switches ----------------------------------------------------------
    // -rc causes input to be taken from clipboard
    (Switch: '-rc';       Id: siInputClipboard;),

    // Output switches ---------------------------------------------------------
    // -wc writes output to clipboard
    (Switch: '-wc';       Id: siOutputClipboard;),
    // -o writes output to following file: does nothing if no file
    (Switch: '-o';        Id: siOutputFile;),

    // Document type switches --------------------------------------------------
    // -frag causes XHTML code fragment to be generated
    (Switch: '-frag';     Id: siDocTypeXHTMLFrag;),
    // -hidecss causes styles embedded in XHTML head section to be protected by
    //    comments
    (Switch: '-hidecss';  Id: siDocTypeHideCSS;),

    // Help switch -------------------------------------------------------------
    // -h causes help text to be displayed on standard error
    (Switch: '-h';        Id: siHelp;),

    // Screen output control switch --------------------------------------------
    // -q inhibits output - ignored if help displayed or if errors parsing
    //    program parameters.
    (Switch: '-q';        Id: siQuiet;)
  );


{ TParams }

constructor TParams.Create(const Config: TConfig);
  {Class constructor. Initialises object.
    @param Config [in] Configuration object to be updated from command line.
  }
begin
  Assert(Assigned(Config), 'TParams.Create: Config is nil');
  inherited Create;
  fConfig := Config;
  fCmdQueue := TQueue<string>.Create;
end;

destructor TParams.Destroy;
  {Class destructor. Tears down object.
  }
begin
  fCmdQueue.Free;
  inherited;
end;

procedure TParams.Parse;
  {Parses the command line.
    @except Exception raised if error in command line.
  }
begin
  PopulateCommandQueue;
  // Loop through all commands on command line
  while fCmdQueue.Count > 0 do
  begin
    // Check command line item
    if AnsiStartsStr('-', fCmdQueue.Peek) then
      ParseSwitch
    else
      ParseFileName;
  end;
end;

procedure TParams.ParseFileName;
begin
  // Parse file name at head of queue
  fConfig.AddInputFile(fCmdQueue.Peek);
  fConfig.InputSource := isFiles;
  // Next parameter
  fCmdQueue.Dequeue;
end;

procedure TParams.ParseSwitch;
resourcestring
  // Error messages
  sBadSwitch = 'Invalid switch "%s"';
  sBadOutputFileSwitch = 'A file name must immediately follow -o switch';
var
  SwitchId: TSwitchId;
begin
  // NOTE: don't try to re-factor fCmdQueue.Dequeue out of case statement to
  // place after statement because that will break processing of siOutputFile

  // Parse switch at head of queue
  if not SwitchToId(fCmdQueue.Peek, SwitchId) then
    raise Exception.CreateFmt(sBadSwitch, [fCmdQueue.Peek]);
  case SwitchId of
    siInputClipboard:
    begin
      fConfig.InputSource := isClipboard;
      fCmdQueue.Dequeue;
    end;
    siOutputClipboard:
    begin
      fConfig.OutputSink := osClipboard;
      fCmdQueue.Dequeue;
    end;
    siOutputFile:
    begin
      // switch is ignored if following param is not a file name
      fCmdQueue.Dequeue;
      if (fCmdQueue.Count = 0) or AnsiStartsStr('-', fCmdQueue.Peek) then
        raise Exception.Create(sBadOutputFileSwitch);
      fConfig.OutputSink := osFile;
      fConfig.OutputFile := fCmdQueue.Dequeue;
    end;
    siDocTypeXHTMLFrag:
    begin
      fConfig.DocType := dtXHTMLFragment;
      fCmdQueue.Dequeue;
    end;
    siDocTypeHideCSS:
    begin
      fConfig.DocType := dtXHTMLHideCSS;
      fCmdQueue.Dequeue;
    end;
    siHelp:
    begin
      fConfig.ShowHelp := True;
      fCmdQueue.Dequeue;
    end;
    siQuiet:
    begin
      fConfig.Quiet := True;
      fCmdQueue.Dequeue;
    end;
  end;
end;

procedure TParams.PopulateCommandQueue;
var
  Idx: Integer;
begin
  fCmdQueue.Clear;
  for Idx := 1 to ParamCount do
    fCmdQueue.Enqueue(ParamStr(Idx));
end;

function TParams.SwitchToId(const Switch: string; out Id: TSwitchId): Boolean;
  {Finds id of a switch.
    @param Switch [in] Text defining switch.
    @param Id [out] Id of switch. Undefined if switch is invalid.
    @return True if switch is valid, False otherwise.
  }
var
  Idx: Integer; // loops through list of valid switches
begin
  Result := False;
  for Idx := Low(cSwitches) to High(cSwitches) do
  begin
    if Switch = cSwitches[Idx].Switch then
    begin
      Id := cSwitches[Idx].Id;
      Result := True;
      Break;
    end;
  end;
end;

end.

