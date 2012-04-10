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
 * Provides access to PasHi and PasHiGUI config and .css template files.
}


unit UGUIConfigFiles;

interface

uses
  Classes,
  UConfigFiles;

type
  TConfigFileWriter = class(TObject)
  strict private
    var
      fFileStream: TFileStream;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure WriteLine(const Key, Value: string);
  end;

  TGUIConfigFiles = class(TConfigFiles)
  public
    class function ConfigFileReaderInstance: TConfigFileReader; override;
    class function ConfigFileWriterInstance: TConfigFileWriter;
    class procedure DeleteGUICfgFile;
    class function CSSFiles: TArray<string>;
  end;

implementation

uses
  SysUtils, Windows {for inlining},
  UUtils;

{ TGUIConfigFiles }

const
  CmdCfgFileName = 'config';
  GUICfgFileName = 'gui-config';

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
    SysUtils.DeleteFile(CfgFileName);
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

