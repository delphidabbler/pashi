unit UGUIConfigFiles;

interface

uses
  UConfigFiles;

type
  TGUIConfigFiles = class(TConfigFiles)
  strict private
    class function GUIConfigFileName: string;
  public
    class function ConfigFileReaderInstance: TConfigFileReader; override;
  end;

implementation

{ TGUIConfigFiles }

class function TGUIConfigFiles.ConfigFileReaderInstance: TConfigFileReader;
begin
  Result := TConfigFileReader.Create;
  Result.LoadData(GUIConfigFileName);
end;

class function TGUIConfigFiles.GUIConfigFileName: string;
begin
  FindConfigFile('gui-config', Result);   // Result = '' if file doesn't exist
end;

end.
