{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Classes that render either HTML comments or meta generator tags to "brand"
 * output documents as being generated by PasHi.
}


unit Renderers.UBranding;

interface

uses
  Renderers.UTypes;

type
  TBrandingGenerator = class abstract(TInterfacedObject)
  strict private
    var
      fInhibited: Boolean;
  strict protected
    function RenderBranding: string; virtual; abstract;
    function GetFileVersionStr: string;
  public
    constructor Create(Inhibited: Boolean);
    function Render: string;
  end;

type
  TFragmentBrandingRenderer = class sealed(TBrandingGenerator, IRenderer)
  strict protected
    function RenderBranding: string; override;
  end;

type
  TMetaBrandingRenderer = class abstract(TBrandingGenerator)
  strict protected
    function RenderBranding: string; override; final;
    function TagCloser: string; virtual; abstract;
  end;

type
  TXHTMLMetaBrandingRenderer = class sealed(TMetaBrandingRenderer, IRenderer)
  strict protected
    function TagCloser: string; override;
  end;

type
  THTMLMetaBrandingRenderer = class sealed(TMetaBrandingRenderer, IRenderer)
  strict protected
    function TagCloser: string; override;
  end;

implementation

uses
  System.SysUtils,
  UVersionInfo;

{ TBrandingGenerator }

constructor TBrandingGenerator.Create(Inhibited: Boolean);
begin
  inherited Create;
  fInhibited := Inhibited;
end;

function TBrandingGenerator.GetFileVersionStr: string;
var
  VI: TVersionInfo;
begin
  VI := TVersionInfo.Create;
  try
    Result := VI.CmdLineVersion;
  finally
    VI.Free;
  end;
end;

function TBrandingGenerator.Render: string;
begin
  if fInhibited then
    Exit('');
  Result := RenderBranding;
end;

{ TFragmentBrandingRenderer }

function TFragmentBrandingRenderer.RenderBranding: string;
resourcestring
  sCommentTextFmt =
    'Highlighted Pascal code generated by DelphiDabbler PasHi v%s';
var
  CommentText: string;
begin
  CommentText := Format(sCommentTextFmt, [GetFileVersionStr]);
  Result := Format('<!-- %s -->', [CommentText]);
end;

{ TMetaBrandingRenderer }

function TMetaBrandingRenderer.RenderBranding: string;
const
  MetaContentFmt = 'DelphiDabbler PasHi v%s';
  MetaTagFmt = '<meta name="generator" content="%0:s"%1:s';
var
  MetaContent: string;
begin
  MetaContent := Format(MetaContentFmt, [GetFileVersionStr]);
  Result := Format(MetaTagFmt, [MetaContent, TagCloser]);
end;

{ TXHTMLMetaBrandingRenderer }

function TXHTMLMetaBrandingRenderer.TagCloser: string;
begin
  Result := ' />';
end;

{ THTMLMetaBrandingRenderer }

function THTMLMetaBrandingRenderer.TagCloser: string;
begin
  Result := '>';
end;

end.
