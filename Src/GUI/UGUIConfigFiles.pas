{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Provides access to PasHi and PasHiGUI config and .css template files.
}


unit UGUIConfigFiles;


interface


uses
  // Delphi
  System.Classes,
  // Project
  UConfigFiles;


type
  ///  <summary>Writes data to a named config file.</summary>
  ///  <remarks>Format is a UTF-8 text file with no BOM.</remarks>
  TConfigFileWriter = class(TObject)
  strict private
    var
      ///  <summary>Stream onto config file.</summary>
      fFileStream: TFileStream;
  public
    ///  <summary>Constructs writer object for given config file.</summary>
    constructor Create(const FileName: string);
    ///  <summary>Destroys writer object and closes file.</summary>
    destructor Destroy; override;
    ///  <summary>Writes given key / value pair to config file.</summary>
    procedure WriteLine(const Key, Value: string);
  end;

type
  ///  <summary>Static class that manages current user's PasHi and PasHiGUI
  ///  configuration data.</summary>
  TGUIConfigFiles = class(TConfigFiles)
  strict protected
    const
      ///  <summary>PasHiGUI config file name.</summary>
      GUICfgFileName = 'gui-config';
  public
    ///  <summary>Creates and returns a config file reader object instance
    ///  containing content of current user's PasHi and PasHiGUI config files.
    ///  </summary>
    ///  <remarks>Caller is responsible for freeing the object.</remarks>
    class function ConfigFileReaderInstance: TConfigFileReader; override;
    ///  <summary>Creates and returns a config file writer object instance for
    ///  writing data to PasHiGUI config file.</summary>
    ///  <remarks>Caller is responsible for freeing the object.</remarks>
    class function ConfigFileWriterInstance: TConfigFileWriter;
    ///  <summary>Deletes the current user's PasHiGUI config gile.</summary>
    class procedure DeleteGUICfgFile;
    ///  <summary>Returns an array of CSS template file names.</summary>
    class function CSSFiles: TArray<string>;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Winapi.Windows {for inlining},
  // Project
  UUtils;

{ TGUIConfigFiles }

class function TGUIConfigFiles.ConfigFileReaderInstance: TConfigFileReader;
begin
  Result := inherited ConfigFileReaderInstance(
    [CmdCfgFileName, GUICfgFileName]
  );
end;

class function TGUIConfigFiles.ConfigFileWriterInstance: TConfigFileWriter;
var
  CfgFilePath: string;
begin
  CfgFilePath := IncludeTrailingPathDelimiter(UserConfigDir) + GUICfgFileName;
  Result := TConfigFileWriter.Create(CfgFilePath);
end;

class function TGUIConfigFiles.CSSFiles: TArray<string>;
var
  Files: TStringList;
  Count: Integer;
  Idx: Integer;
begin
  Files := TStringList.Create;
  try
    if ListFiles(UserConfigDir, '*.css', Files) then
      Count := Files.Count
    else
      Count := 0;
    SetLength(Result, Count);
    for Idx := 0 to Pred(Count) do
      Result[Idx] := Files[Idx];
  finally
    Files.Free;
  end;
end;

class procedure TGUIConfigFiles.DeleteGUICfgFile;
var
  CfgFileName: string;
begin
  CfgFileName := IncludeTrailingPathDelimiter(UserConfigDir) + GUICfgFileName;
  if FileExists(CfgFileName) then
    System.SysUtils.DeleteFile(CfgFileName);
end;

{ TConfigFileWriter }

constructor TConfigFileWriter.Create(const FileName: string);
begin
  inherited Create;
  fFileStream := TFileStream.Create(FileName, fmCreate);
end;

destructor TConfigFileWriter.Destroy;
begin
  fFileStream.Free;
  inherited;
end;

procedure TConfigFileWriter.WriteLine(const Key, Value: string);
var
  Bytes: TBytes;
  Line: string;
begin
  Line := Trim(Key) + ' ' + Trim(Value) + #13#10;
  Bytes := TEncoding.UTF8.GetBytes(Line);
  fFileStream.Write(Pointer(Bytes)^, Length(Bytes));
end;

end.

