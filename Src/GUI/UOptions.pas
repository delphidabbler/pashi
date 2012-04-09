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
    procedure Load;
    procedure SetDefaults;
    procedure Save;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update(const Option: string; const Value: string = '');
    procedure Delete(const Option: string);
    function GetParam(const Option: string): string;
    function IsSet(const Option: string): Boolean;
    function GetEnumerator: TEnumerator<TOption>;
    procedure RestoreDefaults;
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
begin
  Load;
  SetDefaults;
end;

function TOptions.IsSet(const Option: string): Boolean;
begin
  Result := fOptions.ContainsKey(Option);
end;

procedure TOptions.Load;
var
  ConfigReader: TConfigFileReader;
  Option: TPair<string,string>;
begin
  fOptions.Clear;
  ConfigReader := TGUIConfigFiles.ConfigFileReaderInstance;
  try
    for Option in ConfigReader do
    begin
      if Option.Key = 'embed-css' then
      begin
        Delete('link-css');
        Delete('default-css');
      end;
      if Option.Key = 'link-css' then
      begin
        Delete('embed-css');
        Delete('default-css');
      end;
      if Option.Key = 'default-css' then
      begin
        Delete('embed-css');
        Delete('link-css');
      end;
      if Option.Key = 'language-neutral' then
        Delete('language');
      if Option.Key = 'language' then
        Delete('language-neutral');
      if Option.Key = 'title' then
        Delete('title-default');
      if Option.Key = 'title-default' then
        Delete('title');
      Update(Option.Key, Option.Value);
    end;
  finally
    ConfigReader.Free;
  end;
end;

procedure TOptions.RestoreDefaults;
begin
  TGUIConfigFiles.DeleteGUICfgFile;
  Initialise;
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

procedure TOptions.SetDefaults;
begin
  // Remove all input options: these are determined by program's input source
  Delete('input-stdin');
  Delete('input-clipboard');
  // Program always reads PasHi output from stdout: don't need option
  Delete('output-file');
  Delete('output-clipboard');
  Delete('output-stdout');
  // Program always uses UTF-8 for output encoding: don't need option
  Delete('encoding');
  // Program always use normal verbosity: don't need option
  Delete('verbosity');
  Delete('quiet');
  // Help command shouldn't be present, but make sure!
  Delete('help');

  // Set defaults for user-editable values if not present in config files
  // these defaults are same as PasHi defaults per its documentation
  if not IsSet('doc-type') then
    Update('doc-type', 'xhtml');
  if not IsSet('line-numbering') then
    Update('line-numbering', 'off');
  if not IsSet('line-number-width') then
    Update('line-number-width', '3');
  if not IsSet('line-number-padding') then
    Update('line-number-padding', 'space');
  if not IsSet('striping') then
    Update('striping', 'off');
  if not IsSet('embed-css') and not IsSet('link-css')
    and not IsSet('default-css') then
    Update('default-css');
  if not IsSet('legacy-css') then
    Update('legacy-css', 'off');
  if not IsSet('hide-css') then
    Update('hide-css', 'off');
  if not IsSet('trim') then
    Update('trim', 'on');
  if not IsSet('separator-lines') then
    Update('separator-lines', '1');
  if not IsSet('language') and not IsSet('language-neutral') then
    Update('language-neutral');
  if not IsSet('title') and not IsSet('title-default') then
    Update('title-default');
  if not IsSet('branding') then
    Update('branding', 'on');
end;

procedure TOptions.Update(const Option, Value: string);
begin
  if fOptions.ContainsKey(Option) then
    fOptions[Option] := Value
  else
    fOptions.Add(Option, Value);
end;

end.
