{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2021, Peter Johnson (www.delphidabbler.com).
 *
 * Provides factory for creating objects that render the supported types of
 * out document.
}


unit Renderers.UFactory;

interface

uses
  Renderers.UTypes,
  UConfig;

type
  TRendererFactory = record
  public
    class function CreateRenderer(const SourceCode: string;
      const Config: TConfig): IRenderer; static;
  end;


implementation

uses
  Hiliter.UGlobals, Renderers.UBranding, Renderers.UCharSetTag,
  Renderers.UDocType, Renderers.UDocument, Renderers.UEdgeCompatibility,
  Renderers.UProcInst, Renderers.URootTag, Renderers.USourceCode,
  Renderers.UStyles, Renderers.UTitleTag, Renderers.UViewport;

{ TRendererFactory }

class function TRendererFactory.CreateRenderer(const SourceCode: string;
  const Config: TConfig): IRenderer;
var
  DocParams: THTMLDocumentParams;
  FragParams: TXHTMLFragmentParams;
  SourceCodeRenderer: IRenderer;
begin
  SourceCodeRenderer := TSourceCodeRenderer.Create(
    SourceCode,
    Config.LegacyCSSNames,
    THiliteOptions.Create(
      Config.UseLineNumbering,
      Config.LineNumberWidth,
      Config.LineNumberPadding,
      Config.Striping
    )
  );
  case Config.DocType of
    dtXHTML:
    begin
      DocParams.ProcessInst := TXMLProcInstRenderer.Create(
        Config.OutputEncodingName)
      ;
      DocParams.DocType := TXHTMLDocTypeRenderer.Create;
      DocParams.CharSetTag := TXHTMLCharSetTagRenderer.Create(
        Config.OutputEncodingName
      );
      DocParams.HTMLTag := TXHTMLRootTagRenderer.Create(Config.Language);
      DocParams.TitleTag := TTitleTagRenderer.Create(Config.Title);
      DocParams.ViewportTag := TXMLViewportTagRenderer.Create(Config.Viewport);
      DocParams.EdgeCompatibilityTag :=
        TXMLEdgeCompatibilityTagRenderer.Create(not Config.EdgeCompatibility);
      DocParams.GeneratorTag := TNewMetaBrandingRenderer.Create(
        not Config.BrandingPermitted
      );
      DocParams.StyleSheet := TStyleRendererFactory.CreateRenderer(Config);
      DocParams.SourceCode := SourceCodeRenderer;
      Result := TDocumentRenderer.Create(DocParams);
    end;
    dtHTML4:
    begin
      DocParams.ProcessInst := TNullProcInstRenderer.Create;
      DocParams.DocType := THTML4DocTypeRenderer.Create;
      DocParams.CharSetTag := THTML4CharSetTagRenderer.Create(
        Config.OutputEncodingName
      );
      DocParams.HTMLTag := THTMLRootTagRenderer.Create(Config.Language);
      DocParams.TitleTag := TTitleTagRenderer.Create(Config.Title);
      DocParams.ViewportTag := THTMLViewportTagRenderer.Create(Config.Viewport);
      DocParams.EdgeCompatibilityTag :=
        THTMLEdgeCompatibilityTagRenderer.Create(not Config.EdgeCompatibility);
      DocParams.GeneratorTag := TOldMetaBrandingRenderer.Create(
        not Config.BrandingPermitted
      );
      DocParams.StyleSheet := TStyleRendererFactory.CreateRenderer(Config);
      DocParams.SourceCode := SourceCodeRenderer;
      Result := TDocumentRenderer.Create(DocParams);
    end;
    dtHTML5:
    begin
      DocParams.ProcessInst := TNullProcInstRenderer.Create;
      DocParams.DocType := THTML5DocTypeRenderer.Create;
      DocParams.CharSetTag := THTML5CharSetTagRenderer.Create(
        Config.OutputEncodingName
      );
      DocParams.HTMLTag := THTMLRootTagRenderer.Create(Config.Language);
      DocParams.TitleTag := TTitleTagRenderer.Create(Config.Title);
      DocParams.ViewportTag := THTMLViewportTagRenderer.Create(Config.Viewport);
      DocParams.EdgeCompatibilityTag :=
        THTMLEdgeCompatibilityTagRenderer.Create(not Config.EdgeCompatibility);
      DocParams.GeneratorTag := TNewMetaBrandingRenderer.Create(
        not Config.BrandingPermitted
      );
      DocParams.StyleSheet := TStyleRendererFactory.CreateRenderer(Config);
      DocParams.SourceCode := SourceCodeRenderer;
      Result := TDocumentRenderer.Create(DocParams);
    end;
    dtFragment:
    begin
      FragParams.GeneratorComment := TFragmentBrandingRenderer.Create(
        not Config.BrandingPermitted
      );
      FragParams.SourceCode := SourceCodeRenderer;
      Result := TXHTMLFragmentRenderer.Create(FragParams);
    end;
  end;
end;

end.

