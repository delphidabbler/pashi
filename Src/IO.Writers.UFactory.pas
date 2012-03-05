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
  IO.UTypes, UConfig;

type
  TOutputWriterFactory = record
  public
    class function Instance(const OutputSink: TOutputSink): IOutputWriter;
      static;
  end;


implementation

uses
  IO.Writers.UClipboard, IO.Writers.UStdOut;

{ TOutputWriterFactory }

class function TOutputWriterFactory.Instance(const OutputSink: TOutputSink):
  IOutputWriter;
begin
  case OutputSink of
    osStdOut: Result := TStdOutWriter.Create;
    osClipboard: Result := TClipboardWriter.Create;
  else
    Result := nil;
  end;
  Assert(Assigned(Result), 'TOutputWriterFactory.Instance: Result is nil');
end;

end.
