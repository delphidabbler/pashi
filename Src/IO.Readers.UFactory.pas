{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Provides a factory for input reader objects.
}


unit IO.Readers.UFactory;

interface

uses
  System.SysUtils,
  IO.UTypes;

type
  TInputReaderFactory = record
  public
    class function ClipboardReaderInstance: IInputReader; static;
    class function StdInReaderInstance: IInputReader; static;
    class function FilesReaderInstance(const FileNames: TArray<string>):
      IInputReader; static;
  end;

implementation

uses
  IO.Readers.UStdIn,
  IO.Readers.UClipboard,
  IO.Readers.UFiles;

{ TInputReaderFactory }

class function TInputReaderFactory.ClipboardReaderInstance: IInputReader;
begin
  Result := TClipboardReader.Create;
end;

class function TInputReaderFactory.FilesReaderInstance(
  const FileNames: TArray<string>): IInputReader;
begin
  Result := TFilesReader.Create(FileNames);
end;

class function TInputReaderFactory.StdInReaderInstance: IInputReader;
begin
  Result := TStdInReader.Create;
end;

end.
