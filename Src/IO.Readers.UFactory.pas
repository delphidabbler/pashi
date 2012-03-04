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
 * Provides a factory for input reader objects.
}


unit IO.Readers.UFactory;

interface

uses
  SysUtils,
  IO.UTypes, UConfig;

type
  TInputReaderFactory = record
  public
    class function Instance(const InputSource: TInputSource): IInputReader;
      static;
  end;

implementation

uses
  IO.Readers.UStdIn, IO.Readers.UClipboard;

{ TInputReaderFactory }

class function TInputReaderFactory.Instance(const InputSource: TInputSource):
  IInputReader;
begin
  case InputSource of
    isStdIn: Result := TStdInReader.Create;
    isClipboard: Result := TClipboardReader.Create;
  else
    Result := nil;
  end;
  Assert(Assigned(Result), 'TInputReaderFactory.Instance: Result is nil');
end;

end.
