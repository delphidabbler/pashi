{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Modifies input source code per program configuration to prepare for
 * highlighting.
}


unit USourceProcessor;

interface

uses
  SysUtils,
  IO.UTypes, UConfig;

type
  TSourceProcessor = class(TObject)
  strict private
    var
      fConfig: TConfig;
    class function TrimSourceLines(const SourceCode: string): string;
    class function TrimSourceTrailingSpaces(const SourceCode: string): string;
    function Separator: string;
  public
    constructor Create(const Config: TConfig);
    function Process(const Sources: TArray<string>): string;
  end;

implementation

uses
  StrUtils,
  Classes,
  IO.Readers.UFactory, UConsts;


{ TSourceProcessor }

constructor TSourceProcessor.Create(const Config: TConfig);
begin
  inherited Create;
  fConfig := Config;
end;

function TSourceProcessor.Process(const Sources: TArray<string>): string;
var
  SourceCode: string;
  ProcessedSource: string;
  SB: TStringBuilder;

  procedure AddToOutput(const S: string);
  begin
    if SB.Length > 0 then
      SB.Append(Separator);  // adds source code separator
    SB.AppendLine(S);
  end;

begin
  SB := TStringBuilder.Create;
  try
    for SourceCode in Sources do
    begin
      ProcessedSource := SourceCode;
      if fConfig.TrimSource in [tsLines, tsBoth] then
        ProcessedSource := TrimSourceLines(ProcessedSource);
      if fConfig.TrimSource in [tsSpaces, tsBoth] then
        ProcessedSource := TrimSourceTrailingSpaces(ProcessedSource);
      AddToOutput(ProcessedSource);
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TSourceProcessor.Separator: string;
var
  LineIdx: TSeparatorLines;
begin
  Result := '';
  for LineIdx := 1 to fConfig.SeparatorLines do
    Result := Result + CRLF;
end;

class function TSourceProcessor.TrimSourceLines(const SourceCode: string):
  string;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := SourceCode;
    while (Lines.Count > 0) and (Trim(Lines[0]) = '') do
      Lines.Delete(0);
    Result := TrimRight(Lines.Text);
  finally
    Lines.Free;
  end;
end;

class function TSourceProcessor.TrimSourceTrailingSpaces(
  const SourceCode: string): string;
var
  Lines: TStringList;
  Idx: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := SourceCode;
    Result := '';
    if Lines.Count = 0 then
      Exit;
    Result := TrimRight(Lines[0]);
    for Idx := 1 to Pred(Lines.Count) do
      Result := Result + EOL + TrimRight(Lines[Idx]);
  finally
    Lines.Free;
  end;
end;

end.

