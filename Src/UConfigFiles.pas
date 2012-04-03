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
    class function CommonConfigDir: string;
  public
    class constructor Create;
    class function ConfigFileReaderInstance: TConfigFileReader;
    class procedure Initialise;
    class function UserConfigDir: string;
  end;

implementation

uses
  SysUtils, StrUtils, Classes,
  UComparers, USpecialFolders;

procedure CopyFile(const Source, Dest: string);
var
  SourceStream, DestStream: TFileStream; // source and dest file streams
begin
  DestStream := nil;
  // Open source and dest file streams
  SourceStream := TFileStream.Create(Source, fmOpenRead or fmShareDenyWrite);
  try
    DestStream := TFileStream.Create(Dest, fmCreate or fmShareExclusive);
    // Copy file from source to dest
    DestStream.CopyFrom(SourceStream, SourceStream.Size);
    // Set dest file's modification date to same as source file
    FileSetDate(DestStream.Handle, FileGetDate(SourceStream.Handle));
  finally
    // Close files
    DestStream.Free;
    SourceStream.Free;
  end;
end;

function IsDirectory(const DirName: string): Boolean;
  {Checks if a directory exists.
    @param DirName [in] Name of directory to check.
    @return True if DirName is valid directory.
  }
var
  Attr: Integer;  // directory's file attributes
begin
  Attr := FileGetAttr(DirName);
  Result := (Attr <> -1)
    and (Attr and faDirectory = faDirectory);
end;

function ListFiles(const Dir, Wildcard: string; const List: TStrings): Boolean;
var
  FileSpec: string;         // search file specification
  SR: SysUtils.TSearchRec;  // file search result
  Success: Integer;         // success code for FindXXX routines
const
  faVolumeId = $00000008; // redefined from SysUtils to avoid deprecated warning
begin
  Assert(Assigned(List));
  // Check if true directory and exit if not
  Result := IsDirectory(Dir);
  if not Result then
    Exit;
  // Build file spec from directory and wildcard
  FileSpec := IncludeTrailingPathDelimiter(Dir);
  if Wildcard = '' then
    FileSpec := FileSpec + '*.*'
  else
    FileSpec := FileSpec + Wildcard;
  // Initialise search for matching files
  Success := FindFirst(FileSpec, faAnyFile, SR);
  try
    // Loop for all files in directory
    while Success = 0 do
    begin
      // only add true files or directories to list
      if (SR.Name <> '.') and (SR.Name <> '..')
        and (SR.Attr and faVolumeId = 0) then
        List.Add(SR.Name);
      // get next file
      Success := FindNext(SR);
    end;
  finally
    // Tidy up
    FindClose(SR);
  end;
end;

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

class function TConfigFiles.CommonConfigDir: string;
begin
  Result := IncludeTrailingPathDelimiter(TSpecialFolders.CommonAppData)
    + 'DelphiDabbler\PasHi';
end;

class function TConfigFiles.ConfigFileName: string;
begin
  FindConfigFile('config', Result);   // Result = '' if file doesn't exist
end;

class function TConfigFiles.ConfigFileReaderInstance: TConfigFileReader;
begin
  Result := TConfigFileReader.Create(ConfigFileName);
end;

class constructor TConfigFiles.Create;
begin
  Initialise;
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

class procedure TConfigFiles.Initialise;
var
  CommonCfgFiles: TStringList;  // list of files in common config files folder
  CfgFileName: string;          // name of each file in CommonCfgFiles
  CommonCfgDir: string;         // common config directory
  CommonCfgFile: string;        // full path of each file in CommonCfgDir
  UserCfgDir: string;           // user config directory
  UserCfgFile: string;          // full path of each file copied to UserCfgDir
begin
  CommonCfgDir := CommonConfigDir;
  UserCfgDir := UserConfigDir;
  ForceDirectories(UserCfgDir);
  CommonCfgFiles := TStringList.Create;
  try
    if not ListFiles(CommonConfigDir, '*.*', CommonCfgFiles) then
      Exit;
    for CfgFileName in CommonCfgFiles do
    begin
      UserCfgFile := IncludeTrailingPathDelimiter(UserCfgDir) +
        CfgFileName;
      CommonCfgFile := IncludeTrailingPathDelimiter(CommonCfgDir) +
        CfgFileName;
      if FileExists(UserCfgFile) then
        Continue;
      CopyFile(CommonCfgFile, UserCfgFile);
    end;
  finally
    CommonCfgFiles.Free;
  end;
end;

class function TConfigFiles.UserConfigDir: string;
begin
  Result := IncludeTrailingPathDelimiter(TSpecialFolders.UserAppData)
    + 'DelphiDabbler\PasHi';
end;

end.
