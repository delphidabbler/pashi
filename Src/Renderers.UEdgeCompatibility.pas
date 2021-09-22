{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2021, Peter Johnson (www.delphidabbler.com).
 *
 * Provides classes that optionally render a Microsoft Edge compatibility meta
 * tag in HTML documents of different types.
}


unit Renderers.UEdgeCompatibility;

interface

uses
  Renderers.UTypes,
  UConfig;

type
  TEdgeCompatibilityTagRenderer = class abstract(TInterfacedObject)
  strict private
    var
      fInhibited: Boolean;
  strict protected
    function TagCloser: string; virtual; abstract;
  public
    constructor Create(const Inhibited: Boolean);
    function Render: string;
  end;

  TXMLEdgeCompatibilityTagRenderer = class sealed(
    TEdgeCompatibilityTagRenderer, IRenderer
  )
  strict protected
    function TagCloser: string; override;
  end;

  THTMLEdgeCompatibilityTagRenderer = class sealed(
    TEdgeCompatibilityTagRenderer, IRenderer
  )
  strict protected
    function TagCloser: string; override;
  end;

implementation

{ TEdgeCompatibilityTagRenderer }

constructor TEdgeCompatibilityTagRenderer.Create(const Inhibited: Boolean);
begin
  inherited Create;
  fInhibited := Inhibited;
end;

function TEdgeCompatibilityTagRenderer.Render: string;
begin
  if fInhibited then
    Exit('');
  Result := '<meta http-equiv=X-UA-Compatible content="IE=edge"' + TagCloser;
end;

{ TXMLEdgeCompatibilityTagRenderer }

function TXMLEdgeCompatibilityTagRenderer.TagCloser: string;
begin
  Result := ' />';
end;

{ THTMLEdgeCompatibilityTagRenderer }

function THTMLEdgeCompatibilityTagRenderer.TagCloser: string;
begin
  Result := '>';
end;

end.
