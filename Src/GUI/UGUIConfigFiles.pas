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
  end;

implementation

uses
  SysUtils;

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

