{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Classes that generate the correct document root (<html>) tag for each
 * supported document type.
}


unit Renderers.URootTag;

interface

uses
  Renderers.UTypes;

type
  TRootTagRenderer = class abstract(TInterfacedObject)
  strict private
    var
      fLanguage: string;
  strict protected
    property Language: string read fLanguage;
  public
    constructor Create(const Language: string);
    function Render: string; virtual; abstract;
  end;

type
  TXHTMLRootTagRenderer = class sealed(TRootTagRenderer, IRenderer)
  public
    function Render: string; override;
  end;

type
  THTMLRootTagRenderer = class sealed(TRootTagRenderer, IRenderer)
  public
    function Render: string; override;
  end;

implementation

uses
  SysUtils;

{ TRootTagRenderer }

constructor TRootTagRenderer.Create(const Language: string);
begin
  inherited Create;
  fLanguage := Language;
end;

{ TXHTMLRootTagRenderer }

function TXHTMLRootTagRenderer.Render: string;
begin
  Result := '<html xmlns="http://www.w3.org/1999/xhtml"';
  if Language <> '' then
    Result := Result + Format(' xml:lang="%0:s" lang="%0:s"', [Language]);
  Result := Result + '>';
end;

{ THTMLRootTagRenderer }

function THTMLRootTagRenderer.Render: string;
begin
  Result := '<html';
  if Language <> '' then
    Result := Result + Format(' lang="%0:s"', [Language]);
  Result := Result + '>';
end;

end.
