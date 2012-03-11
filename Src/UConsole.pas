{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Implements class that writes text to console using standard error.
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
  // Delphi
  SysUtils,
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
var
  ANSIBytes: TBytes;  // text converted to ANSI byte stream
begin
  if not fSilent then
  begin
    ANSIBytes := TEncoding.Default.GetBytes(Text);
    TStdIO.Write(stdErr, Pointer(ANSIBytes)^, Length(ANSIBytes));
  end;
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

