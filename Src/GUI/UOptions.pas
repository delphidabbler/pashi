{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2022, Peter Johnson (www.delphidabbler.com).
 *
 * Object that provides access to, loads, updates and saves options that are
 * passed to PasHi from PasHiGUI. Used to permit PasHiGUI users to customise
 * options in PasHi's config file without changing that file.
}


unit UOptions;

interface

uses
  Classes, Generics.Collections;


type
  TOptions = class(TObject)
  public
    type
      TOption = TPair<string,string>;
  strict private
    var
      fOptions: TDictionary<string,string>;
    class var
      fFalseValues: TStringList;
      fTrueValues: TStringList;
    procedure Initialise;
    procedure Load;
    procedure SetDefaults;
    procedure Save;
    class function StrToBool(const Value: string): Boolean;
  public
    class constructor Create;
    class destructor Destroy;
    constructor Create;
    destructor Destroy; override;
    procedure Store(const Option: string; const Value: string = ''); overload;
    procedure Store(const Option: string; const Value: Integer); overload;
    procedure Store(const Option: string; const Value: Boolean); overload;
    procedure Delete(const Option: string);
    function GetParamAsStr(const Option: string): string;
    function GetParamAsInt(const Option: string): Integer;
    function GetParamAsBool(const Option: string): Boolean;
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

class constructor TOptions.Create;
begin
  fFalseValues := TStringList.Create;
  fFalseValues.CaseSensitive := False;
  fFalseValues.Add('0');
  fFalseValues.Add('off');
  fFalseValues.Add('n');
  fFalseValues.Add('no');
  fFalseValues.Add('false');
  fTrueValues := TStringList.Create;
  fTrueValues.CaseSensitive := False;
  fTrueValues.Add('1');
  fTrueValues.Add('on');
  fTrueValues.Add('y');
  fTrueValues.Add('yes');
  fTrueValues.Add('true');
end;

procedure TOptions.Delete(const Option: string);
begin
  if fOptions.ContainsKey(Option) then
    fOptions.Remove(Option);
end;

class destructor TOptions.Destroy;
begin
  fTrueValues.Free;
  fFalseValues.Free;
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

function TOptions.GetParamAsBool(const Option: string): Boolean;
begin
  Result := StrToBool(GetParamAsStr(Option));
end;

function TOptions.GetParamAsInt(const Option: string): Integer;
begin
  Result := StrToInt(GetParamAsStr(Option));
end;

function TOptions.GetParamAsStr(const Option: string): string;
begin
  if not fOptions.ContainsKey(Option) then
    raise EListError.CreateFmt('No such option as "%s"', [Option]);
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
      Store(Option.Key, Option.Value);
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
  // Program always writes PasHi output to stdout: don't need option
  Delete('output-file');
  Delete('output-clipboard');
  Delete('output-stdout');
  // Program always uses UTF-8 for output encoding: don't need option
  Delete('encoding');
  // Program always use normal verbosity: don't need option
  Delete('verbosity');
  Delete('quiet');
  // Help & version commands shouldn't be present, but make sure!
  Delete('help');
  Delete('version');

  // Set defaults for user-editable values if not present in config files
  // these defaults are same as PasHi defaults per its documentation
  if not IsSet('doc-type') then
    Store('doc-type', 'xhtml');
  if not IsSet('line-numbering') then
    Store('line-numbering', False);
  if not IsSet('line-number-width') then
    Store('line-number-width', 3);
  if not IsSet('line-number-padding') then
    Store('line-number-padding', 'space');
  if not IsSet('line-number-start') then
    Store('line-number-start', 1);
  if not IsSet('striping') then
    Store('striping', False);
  if not IsSet('embed-css') and not IsSet('link-css')
    and not IsSet('default-css') then
    Store('default-css');
  if not IsSet('legacy-css') then
    Store('legacy-css', False);
  if not IsSet('hide-css') then
    Store('hide-css', False);
  if not IsSet('trim') then
    Store('trim', True);
  if not IsSet('separator-lines') then
    Store('separator-lines', 1);
  if not IsSet('language') and not IsSet('language-neutral') then
    Store('language-neutral');
  if not IsSet('title') and not IsSet('title-default') then
    Store('title-default');
  if not IsSet('branding') then
    Store('branding', True);
  if not IsSet('viewport') then
    Store('viewport', 'none');
  if not IsSet('edge-compatibility') then
    Store('edge-compatibility', False);
end;

procedure TOptions.Store(const Option, Value: string);
begin
  if fOptions.ContainsKey(Option) then
    fOptions[Option] := Value
  else
    fOptions.Add(Option, Value);
end;

procedure TOptions.Store(const Option: string; const Value: Integer);
begin
  Store(Option, IntToStr(Value));
end;

procedure TOptions.Store(const Option: string; const Value: Boolean);
begin
  case Value of
    False: Store(Option, 'off');
    True: Store(Option, 'on');
  end;
end;

class function TOptions.StrToBool(const Value: string): Boolean;
begin
  if fFalseValues.IndexOf(Value) >= 0 then
    Exit(False);
  if fTrueValues.IndexOf(Value) >= 0 then
    Exit(True);
  raise EConvertError.CreateFmt('"%s" is not a valid Boolean value', [Value]);
end;

end.

