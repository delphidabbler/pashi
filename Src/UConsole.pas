{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2016, Peter Johnson (www.delphidabbler.com).
 *
 * Implements class that writes text to console using standard error.
}


unit UConsole;


interface


type

  ///  <summary>Class that writes text to console using standard error unless
  ///  told to be silent when all output is swallowed.</summary>
  TConsole = class(TObject)
  private
    fSilent: Boolean;
  public
    constructor Create;
    procedure Write(const Text: string);
    procedure WriteLn(const Text: string); overload;
    procedure WriteLn; overload;
    property Silent: Boolean read fSilent write fSilent default False;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  // Project
  UStdIO;


{ TConsole }

constructor TConsole.Create;
begin
  inherited Create;
  fSilent := False;
end;

procedure TConsole.Write(const Text: string);
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
begin
  Write(Text + #13#10);
end;

procedure TConsole.WriteLn;
begin
  WriteLn('');
end;

end.

