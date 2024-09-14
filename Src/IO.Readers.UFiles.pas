{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
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
  public
    constructor Create(const FileNames: TArray<string>);
    function Read: TArray<string>;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
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

function TFilesReader.Read: TArray<string>;
var
  Idx: Integer;
begin
  SetLength(Result, Length(fFileNames));
  for Idx := Low(fFileNames) to High(fFileNames) do
    Result[Idx] := TIOHelper.FileToString(fFileNames[Idx])
end;

end.


