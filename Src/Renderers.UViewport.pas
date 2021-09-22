{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2021, Peter Johnson (www.delphidabbler.com).
 *
 * Provides classes that optionally render a viewport meta tag in HTML documents
 * of different types.
}


unit Renderers.UViewport;

interface

uses
  Renderers.UTypes,
  UConfig;

type
  TViewportTagRenderer = class abstract(TInterfacedObject)
  strict private
    var
      fViewport: TViewport;
  strict protected
    function TagCloser: string; virtual; abstract;
  public
    constructor Create(const Viewport: TViewport);
    function Render: string;
  end;

  TXMLViewportTagRenderer = class sealed(TViewportTagRenderer, IRenderer)
  strict protected
    function TagCloser: string; override;
  end;

  THTMLViewportTagRenderer = class sealed(TViewportTagRenderer, IRenderer)
  strict protected
    function TagCloser: string; override;
  end;

implementation

uses
  SysUtils;

{ TViewportTagRenderer }

constructor TViewportTagRenderer.Create(const Viewport: TViewport);
begin
  inherited Create;
  fViewport := Viewport;
end;

function TViewportTagRenderer.Render: string;
begin
  case fViewport of
    vpNone:
      Result := '';
    vpPhone:
      Result := '<meta name="viewport" content="width=device-width, '
        + 'initial-scale=1"'
        + TagCloser;
    else
      raise EArgumentException.Create('Unexpected Viewport value');
  end;
end;

{ TXMLViewportTagRenderer }

function TXMLViewportTagRenderer.TagCloser: string;
begin
  Result := ' />';
end;

{ THTMLViewportTagRenderer }

function THTMLViewportTagRenderer.TagCloser: string;
begin
  Result := '>';
end;

end.
