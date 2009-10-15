{
 * UConsole.pas
 *
 * Implements class that writes text to console using standard error.
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
 * The Original Code is UConsole.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UConsole;


interface


type

  {
  TConsole:
    Class that writes text to console using standard error unless told to be
    silent when all output is swallowed.
  }
  TConsole = class(TObject)
  private
    fSilent: Boolean;
      {Value of Silent property}
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    procedure Write(const Text: string);
      {Write text to standard error unless slient.
        @param Text [in] Text to be written.
      }
    procedure WriteLn(const Text: string); overload;
      {Write text followed by new line to standard error unless silent.
        @param Text [in] Text to be written.
      }
    procedure WriteLn; overload;
      {Write a new line to standard error unless silent.
      }
    property Silent: Boolean read fSilent write fSilent default False;
      {Whether to be silent, i.e. write no output}
  end;


implementation


uses
  // Project
  UStdIO;


{ TConsole }

constructor TConsole.Create;
  {Class constructor. Sets up object.
  }
begin
  inherited Create;
  fSilent := False;
end;

procedure TConsole.Write(const Text: string);
  {Write text to standard error unless slient.
    @param Text [in] Text to be written.
  }
begin
  if not fSilent then
    TStdIO.Write(stdErr, Text);
end;

procedure TConsole.WriteLn(const Text: string);
  {Write text followed by new line to standard error unless silent.
    @param Text [in] Text to be written.
  }
begin
  Write(Text + #13#10);
end;

procedure TConsole.WriteLn;
  {Write a new line to standard error unless silent.
  }
begin
  WriteLn('');
end;

end.

