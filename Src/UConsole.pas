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


uses
  UConfig;


type

  ///  <summary>Class that writes text to console using standard error providing
  ///  a given verbosity level is valid.</summary>
  TConsole = class(TObject)
  strict private
    var
      fValidOutputStates: TVerbosityStates;
  public
    constructor Create;
    procedure Write(const Text: string; AVerbosityLevel: TVerbosityState);
    procedure WriteLn(const Text: string; AVerbosityLevel: TVerbosityState);
      overload;
    procedure WriteLn(AVerbosityLevel: TVerbosityState); overload;
    property ValidOutputStates: TVerbosityStates read fValidOutputStates
      write fValidOutputStates;
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
  fValidOutputStates := TConfig.DefaultVerbosity;
end;


procedure TConsole.Write(const Text: string; AVerbosityLevel: TVerbosityState);
begin
  if (AVerbosityLevel in fValidOutputStates) and (Text <> '') then
  begin
    var ANSIBytes := TEncoding.Default.GetBytes(Text);
    TStdIO.Write(stdErr, Pointer(ANSIBytes)^, Length(ANSIBytes));
  end;
end;

procedure TConsole.WriteLn(const Text: string;
  AVerbosityLevel: TVerbosityState);
begin
  Write(Text, AVerbosityLevel);
  Write(sLineBreak, AVerbosityLevel);
end;

procedure TConsole.WriteLn(AVerbosityLevel: TVerbosityState);
begin
  WriteLn('', AVerbosityLevel);
end;

end.

