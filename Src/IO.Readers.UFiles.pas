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
 * Provides a class that can read input data from one or more files.
}


unit IO.Readers.UFiles;

interface

uses
  IO.UTypes;

type
  TFilesReader = class(TInterfacedObject, IInputReader)
  strict private
    var
      fFileNames: TArray<string>;
    function ReadFile(const FileName: string): string;
    function StripBoundingBlankLines(const S: string): string;
  public
    constructor Create(const FileNames: TArray<string>);
    function Read: string;
  end;

implementation

uses
  SysUtils, Classes,
  IO.UHelper;

{ TFilesReader }

constructor TFilesReader.Create(const FileNames: TArray<string>);
var
  Idx: Integer;
begin
  inherited Create;
  SetLength(fFileNames, Length(FileNames));
  for Idx := 0 to Pred(Length(FileNames)) do
    fFileNames[Idx] := FileNames[Idx];
end;

function TFilesReader.Read: string;
var
  SB: TStringBuilder;
  FileName: string;
begin
  SB := TStringBuilder.Create;
  try
    for FileName in fFileNames do
    begin
      if SB.Length > 0 then
        SB.AppendLine;
      SB.AppendLine(ReadFile(FileName));
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TFilesReader.ReadFile(const FileName: string): string;
begin
  Result := StripBoundingBlankLines(
    TIOHelper.FileToString(FileName)
  );
end;

function TFilesReader.StripBoundingBlankLines(const S: string): string;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := S;
    while (Lines.Count > 0) and (Trim(Lines[0]) = '') do
      Lines.Delete(0);
    while (Lines.Count > 0) and (Trim(Lines[Pred(Lines.Count)]) = '') do
      Lines.Delete(Pred(Lines.Count));
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

end.

