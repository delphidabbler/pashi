{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2016, Peter Johnson (www.delphidabbler.com).
 *
 * Static class that detects presence of user guide and displays it if possible.
}


unit UUserGuide;


interface

type

  TUserGuide = class(TObject)
  strict private
    class var
      fExists: Boolean;
      fFileName: string;
  public
    class constructor Create;
    class function CanDisplay: Boolean;
    class procedure Display;
  end;


implementation


uses
  SysUtils, Windows, ShellAPI;

{ TUserGuide }

class function TUserGuide.CanDisplay: Boolean;
begin
  Result := fExists;
end;

class constructor TUserGuide.Create;
begin
  fFileName := ExtractFilePath(ParamStr(0)) + 'UserGuide.html';
  fExists := FileExists(fFileName);
end;

class procedure TUserGuide.Display;
begin
  if not fExists then
    Exit;
  if ShellExecute(0, 'open', PWideChar(fFileName), nil, nil, SW_SHOW) <= 32 then
    raise Exception.Create(
      'Cannot display user guide: check that a default web browser is set up'
    );

end;

end.
