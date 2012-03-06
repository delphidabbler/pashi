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
 * Provides a factory for output writer objects.
}


unit IO.Writers.UFactory;

interface

uses
  IO.UTypes;

type
  TOutputWriterFactory = record
  public
    class function ClipboardWriterInstance: IOutputWriter; static;
    class function StdOutWriterInstance: IOutputWriter; static;
      static;
  end;


implementation

uses
  IO.Writers.UClipboard, IO.Writers.UStdOut;

{ TOutputWriterFactory }

class function TOutputWriterFactory.ClipboardWriterInstance: IOutputWriter;
begin
  Result := TClipboardWriter.Create;
end;

class function TOutputWriterFactory.StdOutWriterInstance: IOutputWriter;
begin
  Result := TStdOutWriter.Create;
end;

end.
