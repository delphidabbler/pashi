{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Classes that render XML processing instructions for inclusion at the top of
 * output XML documents. Includes a null class for use with document types that
 * require no processing instruction.
}


unit Renderers.UProcInst;

interface

uses
  Renderers.UTypes;

type
  TXMLProcInstRenderer = class sealed(TInterfacedObject, IRenderer)
  strict private
    fCharSet: string;
  public
    constructor Create(const CharSet: string);
    function Render: string;
  end;

type
  TNullProcInstRenderer = class sealed(TInterfacedObject, IRenderer)
  public
    function Render: string;
  end;

implementation

uses
  SysUtils;

{ TXMLProcInstRenderer }

constructor TXMLProcInstRenderer.Create(const CharSet: string);
begin
  inherited Create;
  fCharSet := CharSet;
end;

function TXMLProcInstRenderer.Render: string;
begin
  Result := '<?xml version="1.0"';
  if fCharSet <> '' then
    Result := Result + Format(' encoding="%s"', [fCharSet]);
  Result := Result + '?>';
end;

{ TNullProcInstRenderer }

function TNullProcInstRenderer.Render: string;
begin
  Result := '';
end;

end.
