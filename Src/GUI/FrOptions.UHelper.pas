{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Helper code for use in various frames in FrOptions namespace.
}


unit FrOptions.UHelper;

interface

uses
  System.Classes,
  System.Generics.Collections;

type
  TValueMap = class(TObject)
  strict private
    fValues: TList<TPair<string,string>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Desc, Value: string);
    procedure GetDescriptions(const List: TStrings);
    function GetDescFromValue(const Value: string): string;
    function IndexOfValue(const Value: string): Integer;
    function ValueByIndex(const Idx: Integer): string;
  end;

implementation

uses
  System.SysUtils;

{ TValueMap }

procedure TValueMap.Add(const Desc, Value: string);
begin
  fValues.Add(TPair<string,string>.Create(Desc, Value));
end;

constructor TValueMap.Create;
begin
  inherited Create;
  fValues := TList<TPair<string,string>>.Create;
end;

destructor TValueMap.Destroy;
begin
  fValues.Free;
  inherited;
end;

function TValueMap.GetDescFromValue(const Value: string): string;
var
  Idx: Integer;
  Item: TPair<string,string>;
begin
  Result := '';
  for Idx := 0 to Pred(fValues.Count) do
  begin
    Item := fValues[Idx];
    if SameText(Value, Item.Value) then
      Exit(Item.Key);
  end;
end;

procedure TValueMap.GetDescriptions(const List: TStrings);
var
  Item: TPair<string,string>;
begin
  List.Clear;
  for Item in fValues do
    List.Add(Item.Key);
end;

function TValueMap.IndexOfValue(const Value: string): Integer;
var
  Idx: Integer;
begin
  Result := -1;
  for Idx := 0 to Pred(fValues.Count) do
    if SameText(Value, fValues[Idx].Value) then
      Exit(Idx);
end;

function TValueMap.ValueByIndex(const Idx: Integer): string;
begin
  Result := fValues[Idx].Value;
end;

end.
