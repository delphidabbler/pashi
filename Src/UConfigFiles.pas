{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Provides location of PasHi config file and parses contents.
}


unit UConfigFiles;

interface

uses
  Generics.Collections;

type
  TConfigFileReader = class(TObject)
  strict private
    var
      fMap: TList<TPair<string,string>>;
    procedure LoadData(const FileName: string);
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    function GetEnumerator: TEnumerator<TPair<string,string>>;
  end;

  TConfigFiles = class(TObject)
  strict private
    class function FindConfigFile(const BaseName: string; out FullPath: string):
      Boolean;
    class function ConfigFileName: string;
  public
    class function ConfigFileReaderInstance: TConfigFileReader;
    class function UserConfigDir: string;
  end;

implementation

uses
  SysUtils, StrUtils, Classes,
  UComparers, USpecialFolders;

{ TConfigFileReader }

constructor TConfigFileReader.Create(const FileName: string);
begin
  inherited Create;
  fMap := TList<TPair<string,string>>.Create;
  if (FileName <> '') and FileExists(FileName) then
    LoadData(FileName);
end;

destructor TConfigFileReader.Destroy;
begin
  fMap.Free;
  inherited;
end;

function TConfigFileReader.GetEnumerator: TEnumerator<TPair<string, string>>;
begin
  Result := fMap.GetEnumerator;
end;

procedure TConfigFileReader.LoadData(const FileName: string);
const
  ParamDelim = ' ';
  CommentToken = '#';
var
  Lines: TStringList;
  Line: string;
  TrimmedLine: string;
  DelimPos: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName, TEncoding.UTF8);
    for Line in Lines do
    begin
      TrimmedLine := Trim(Line);
      if Length(TrimmedLine) = 0 then
        Continue;
      if TrimmedLine[1] = CommentToken then
        Continue;
      DelimPos := PosEx(ParamDelim, TrimmedLine);
      if DelimPos = 0 then
        fMap.Add(TPair<string,string>.Create(TrimmedLine, ''))
      else
        fMap.Add(
          TPair<string,string>.Create(
            Trim(LeftStr(TrimmedLine, DelimPos - 1)),
            Trim(RightStr(TrimmedLine, Length(TrimmedLine) - DelimPos))
          )
        );
    end;
  finally
    Lines.Free;
  end;
end;

{ TConfigFiles }

class function TConfigFiles.ConfigFileName: string;
begin
  FindConfigFile('config', Result);   // Result = '' if file doesn't exist
end;

class function TConfigFiles.ConfigFileReaderInstance: TConfigFileReader;
begin
  Result := TConfigFileReader.Create(ConfigFileName);
end;

class function TConfigFiles.FindConfigFile(const BaseName: string;
  out FullPath: string): Boolean;
begin
  FullPath := IncludeTrailingPathDelimiter(UserConfigDir) + BaseName;
  if FileExists(FullPath) then
    Exit(True);
  FullPath := '';
  Result := False;
end;

class function TConfigFiles.UserConfigDir: string;
begin
  Result := IncludeTrailingPathDelimiter(TSpecialFolders.UserAppData)
    + 'DelphiDabbler\PasHi';
end;

end.
