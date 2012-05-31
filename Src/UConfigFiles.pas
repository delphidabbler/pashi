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
 * Provides access to PasHi config and .css template files and ensures they
 * exist.
}


unit UConfigFiles;


interface


uses
  // Delphi
  Generics.Collections;


type
  ///  <summary>Class that parses one or more config files and enumerates the
  ///  commands contained in the files.</summary>
  TConfigFileReader = class(TObject)
  strict private
    var
      ///  <summary>Map of commands from file onto their values.</summary>
      fMap: TList<TPair<string,string>>;
  public
    ///  <summary>Constructs reader object.</summary>
    constructor Create;
    ///  <summary>Destroys reader object.</summary>
    destructor Destroy; override;
    ///  <summary>Parses and loads contents of given config file.</summary>
    ///  <remarks>Subsequent calls to this method for different files add the
    ///  data from the files to the same data structure.</remarks>
    procedure LoadData(const FileName: string);
    ///  <summary>Creates and returned enumerator for all commands loaded from
    ///  config file(s).</summary>
    function GetEnumerator: TEnumerator<TPair<string,string>>;
  end;

type
  ///  <summary>Static class that manages current user's PasHi configuration
  ///  data.</summary>
  TConfigFiles = class(TObject)
  strict private
    ///  <summary>Returns directory where common config files are installed.
    ///  </summary>
    class function CommonConfigDir: string;
    ///  <summary>Checks if updated versions of config files has been installed
    ///  in common config files directory.</summary>
    class function IsNewConfigFiles: Boolean;
    ///  <summary>Gets the fully qualified name of a config file if it exists in
    ///  this user's config file directory.</summary>
    ///  <param name="BaseName">string [in] Base name of required file.</param>
    ///  <param name="FullPath">string [out] Set to fully specified name of
    ///  required file, if it exists or '' if not.</param>
    ///  <returns>Boolean. True if file exists, False if not.</returns>
    class function FindConfigFile(const BaseName: string; out FullPath: string):
      Boolean;
  strict protected
    ///  <summary>Creates and returns a config file reader object instance
    ///  containing content of each config file named in Files array.</summary>
    ///  <remarks>Caller is responsible for freeing the TConfigFileReader
    ///  instance.</remarks>
    class function ConfigFileReaderInstance(const Files: array of string):
      TConfigFileReader; overload;
  public
    ///  <summary>Class constructor. Ensures current user's config files are
    ///  available.</summary>
    class constructor Create;
    ///  <summary>Creates and returns a config file reader object instance
    ///  containing content of current user's PasHi config file.</summary>
    ///  <remarks>Caller is responsible for freeing the object.</remarks>
    class function ConfigFileReaderInstance: TConfigFileReader; overload;
      virtual;
    ///  <summary>Ensures config file directory for current user exists and
    ///  contains latest copy of config and sample files installed in common
    ///  data directory.</summary>
    class procedure Initialise;
    ///  <summary>Returns directory where current user's config files are
    ///  kept.</summary>
    class function UserConfigDir: string;
  end;


implementation


uses
  // Delphi
  SysUtils, StrUtils, Classes,
  // Project
  IO.UHelper, UComparers, USpecialFolders;


///  <summary>Copies file Source to new file named by Dest.</summary>
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

///  <summary>Checks if specified directory exists.</summary>
function IsDirectory(const DirName: string): Boolean;
var
  Attr: Integer;  // directory's file attributes
begin
  Attr := FileGetAttr(DirName);
  Result := (Attr <> -1)
    and (Attr and faDirectory = faDirectory);
end;

///  <summary>Gets list of all files in given directory Dir that match WildCard
///  and appends to string list List. Returns True if Dir is a directory and
///  False if not.</summary>
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

constructor TConfigFileReader.Create;
begin
  inherited Create;
  fMap := TList<TPair<string,string>>.Create;
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

class function TConfigFiles.ConfigFileReaderInstance(
  const Files: array of string): TConfigFileReader;
var
  CfgFilePath: string;
  CfgFileName: string;
begin
  Result := TConfigFileReader.Create;
  for CfgFileName in Files do
    if FindConfigFile(CfgFileName, CfgFilePath) then
      Result.LoadData(CfgFilePath);
end;

class function TConfigFiles.ConfigFileReaderInstance: TConfigFileReader;
begin
  Result := ConfigFileReaderInstance(['config']);
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
  if not IsNewConfigFiles then
    Exit;
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
      CopyFile(CommonCfgFile, UserCfgFile);
    end;
  finally
    CommonCfgFiles.Free;
  end;
end;

class function TConfigFiles.IsNewConfigFiles: Boolean;
var
  CommonVersionFile: string;
  UserVersionFile: string;
  CommonConfigVersion: Integer;
  UserConfigVersion: Integer;
begin
  UserVersionFile := IncludeTrailingPathDelimiter(UserConfigDir)
    + 'version';
  if not FileExists(UserVersionFile) then
    Exit(True);
  CommonVersionFile := IncludeTrailingPathDelimiter(CommonConfigDir)
    + 'version';
  if not FileExists(CommonVersionFile) then
    Exit(True);
  CommonConfigVersion := StrToIntDef(
    TIOHelper.FileToString(CommonVersionFile), 0
  );
  if CommonConfigVersion = 0 then
    Exit(True);
  UserConfigVersion := StrToIntDef(
    TIOHelper.FileToString(UserVersionFile), 0
  );
  Result := CommonConfigVersion > UserConfigVersion;
end;

class function TConfigFiles.UserConfigDir: string;
begin
  Result := IncludeTrailingPathDelimiter(TSpecialFolders.UserAppData)
    + 'DelphiDabbler\PasHi';
end;

end.

