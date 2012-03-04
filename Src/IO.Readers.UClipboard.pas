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
 * Provides a class that can read input data from the clipboard.
}


unit IO.Readers.UClipboard;

interface

uses
  SysUtils,
  IO.UTypes;

type
  TClipboardReader = class(TInterfacedObject, IInputReader)
  public
    function Read(const Encoding: TEncoding): string;
  end;

implementation

uses
  Windows, ClipBrd;

{ TClipboardReader }

function TClipboardReader.Read(const Encoding: TEncoding): string;
begin
  // encoding is ignored: always Unicode
  if not Clipboard.HasFormat(CF_UNICODETEXT) then
    Exit('');
  Result := Clipboard.AsText;
end;

end.
