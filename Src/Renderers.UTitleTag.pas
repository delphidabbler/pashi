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
 * Renders the HTML title tag containing either a given or default title.
}


unit Renderers.UTitleTag;

interface

uses
  Renderers.UTypes;

type
  TTitleTagRenderer = class sealed(TInterfacedObject, IRenderer)
  strict private
    fTitle: string;
  public
    constructor Create(const Title: string);
    function Render: string;
  end;

implementation

uses
  SysUtils,
  UHTMLUtils;

{ TTitleTagRenderer }

constructor TTitleTagRenderer.Create(const Title: string);
resourcestring
  sDefaultTitle = 'Syntax Highlighted Pascal';
begin
  inherited Create;
  if Title <> '' then
    fTitle := Title
  else
    fTitle := sDefaultTitle;
end;

function TTitleTagRenderer.Render: string;
begin
  Result := Format('<title>%s</title>', [MakeSafeHTMLText(fTitle)]);
end;

end.
