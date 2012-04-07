unit UOptions;

interface

uses
  Generics.Collections;


type
  TOptions = class(TObject)
  public
    type
      TOption = TPair<string,string>;
  strict private
    var
      fOptions: TDictionary<string,string>;
    procedure Initialise;
    procedure Save;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update(const Option: string; const Value: string = '');
    procedure Delete(const Option: string);
    function GetParam(const Option: string): string;
    function IsDefault(const Option: string): Boolean;
    function GetEnumerator: TEnumerator<TOption>;
  end;

implementation

uses
  SysUtils,
  UComparers, UConfigFiles, UGUIConfigFiles;

{ TOptions }

constructor TOptions.Create;
begin
  inherited Create;
  fOptions := TDictionary<string,string>.Create(
    TStringEqualityComparer.Create
  );
  Initialise;
end;

procedure TOptions.Delete(const Option: string);
begin
  if fOptions.ContainsKey(Option) then
    fOptions.Remove(Option);
end;

destructor TOptions.Destroy;
begin
  Save;
  fOptions.Free;
  inherited;
end;

function TOptions.GetEnumerator: TEnumerator<TOption>;
begin
  Result := fOptions.GetEnumerator;
end;

function TOptions.GetParam(const Option: string): string;
begin
  if not fOptions.ContainsKey(Option) then
    Exit('');
  Result := fOptions[Option];
end;

procedure TOptions.Initialise;
var
  ConfigReader: TConfigFileReader;
  Option: TPair<string,string>;
begin
  ConfigReader := TGUIConfigFiles.ConfigFileReaderInstance;
  try
    for Option in ConfigReader do
      Update(Option.Key, Option.Value);
  finally
    ConfigReader.Free;
  end;
end;

function TOptions.IsDefault(const Option: string): Boolean;
begin
  Result := not fOptions.ContainsKey(Option);
end;

procedure TOptions.Save;
var
  ConfigWriter: TConfigFileWriter;
  Option: TOption;
begin
  ConfigWriter := TGUIConfigFiles.ConfigFileWriterInstance;
  try
    for Option in fOptions do
      ConfigWriter.WriteLine(Option.Key, Option.Value);
  finally
    ConfigWriter.Free;
  end;
end;

procedure TOptions.Update(const Option, Value: string);
begin
  if fOptions.ContainsKey(Option) then
    fOptions[Option] := Value
  else
    fOptions.Add(Option, Value);
end;

end.
