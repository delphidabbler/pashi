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
 * Defines types used in I/O operations.
}


unit IO.UTypes;

interface

uses
  SysUtils;

type
  IInputReader = interface
    ['{0E702A31-2D93-48D7-98F7-76823C209FF9}']
    function Read(const Encoding: TEncoding): string;
  end;

type
  IOutputWriter = interface
    ['{09FB5F10-AD74-41D4-AFBA-A0100819C2BF}']
    procedure Write(const S: string; const Encoding: TEncoding);
  end;

implementation

end.
