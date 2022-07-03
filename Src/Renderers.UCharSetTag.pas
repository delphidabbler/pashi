{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2022, Peter Johnson (www.delphidabbler.com).
 *
 * Classes that render appropriate HTML meta tags for defining an HTML
 * document's character set.
}


unit Renderers.UCharSetTag;

interface

uses
  Renderers.UTypes;

type
  TCharSetTagRenderer = class abstract(TInterfacedObject)
  strict private
    var
      fCharSet: string;
  strict protected
    property CharSet: string read fCharSet;
  public
    constructor Create(const CharSet: string);
    function Render: string; virtual; abstract;
  end;

type
  TContentTypeTagRenderer = class abstract(TCharSetTagRenderer)
  strict protected
    function TagCloser: string; virtual; abstract;
  public
    function Render: string; override; final;
  end;

type
  TXHTMLCharSetTagRenderer = class sealed(TContentTypeTagRenderer, IRenderer)
  strict protected
    function TagCloser: string; override;
  end;

type
  THTML4CharSetTagRenderer = class sealed(TContentTypeTagRenderer, IRenderer)
  strict protected
    function TagCloser: string; override;
  end;

type
  THTML5CharSetTagRenderer = class sealed(TCharSetTagRenderer, IRenderer)
  public
    function Render: string; override;
  end;


implementation

uses
  SysUtils;

{ TCharSetTagRenderer }

constructor TCharSetTagRenderer.Create(const CharSet: string);
begin
  inherited Create;
  fCharSet := CharSet;
end;

{ TContentTypeTagRenderer }

function TContentTypeTagRenderer.Render: string;
begin
  Result := '<meta http-equiv="Content-Type" content="text/html';
  if CharSet <> '' then
    Result := Result + Format(';charset=%s', [CharSet]);
  Result := Result + '"' + TagCloser;
end;

{ TXHTMLCharSetTagRenderer }

function TXHTMLCharSetTagRenderer.TagCloser: string;
begin
  Result := ' />';
end;

{ THTML4CharSetTagRenderer }

function THTML4CharSetTagRenderer.TagCloser: string;
begin
  Result := '>';
end;

{ THTML5CharSetTagRenderer }

function THTML5CharSetTagRenderer.Render: string;
begin
  if CharSet = '' then
    Exit('');
  Result := Format('<meta charset="%s">', [CharSet]);
end;

end.
