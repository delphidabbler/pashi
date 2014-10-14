{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Provides classes that render the DOCTYPE statement for the head of complete
 * HTML documents of different types.
}


unit Renderers.UDocType;

interface

uses
  Renderers.UTypes;

type
  TXHTMLDocTypeRenderer = class sealed(TInterfacedObject, IRenderer)
  public
    function Render: string;
  end;

type
  THTML4DocTypeRenderer = class sealed(TInterfacedObject, IRenderer)
  public
    function Render: string;
  end;

type
  THTML5DocTypeRenderer = class sealed(TInterfacedObject, IRenderer)
  public
    function Render: string;
  end;

implementation

{ TXHTMLDocTypeRenderer }

function TXHTMLDocTypeRenderer.Render: string;
begin
  Result := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" '
    + '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
end;

{ THTML4DocTypeRenderer }

function THTML4DocTypeRenderer.Render: string;
begin
  Result := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" '
    + '"http://www.w3.org/TR/html4/strict.dtd">'
end;

{ THTML5DocTypeRenderer }

function THTML5DocTypeRenderer.Render: string;
begin
  Result := '<!DOCTYPE html>';
end;

end.
