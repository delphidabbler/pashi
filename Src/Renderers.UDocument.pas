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
 * Provides classes that render complete output documents and document
 * fragments.
}


unit Renderers.UDocument;

interface

uses
  Renderers.UTypes;

type
  TXHTMLFragmentParams = record
  public
    GeneratorComment: IRenderer;
    SourceCode: IRenderer;
  end;

type
  // may or may not need passing hiliter instance to constructor or could call
  // directly if not parameterised
  TXHTMLFragmentRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fRenderers: TXHTMLFragmentParams;
  public
    constructor Create(Renderers: TXHTMLFragmentParams);
    function Render: string;
  end;

type
  THTMLDocumentParams = record
  public
    ProcessInst: IRenderer;
    DocType: IRenderer;
    CharSetTag: IRenderer;
    HTMLTag: IRenderer;
    TitleTag: IRenderer;
    GeneratorTag: IRenderer;
    StyleSheet: IRenderer;
    SourceCode: IRenderer;
  end;

type
  TDocumentRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fRenderers: THTMLDocumentParams;
  public
    constructor Create(Renderers: THTMLDocumentParams);
    function Render: string;
  end;


implementation

uses
  SysUtils;

{ TXHTMLFragmentRenderer }

constructor TXHTMLFragmentRenderer.Create(Renderers: TXHTMLFragmentParams);
begin
  inherited Create;
  fRenderers := Renderers;
end;

function TXHTMLFragmentRenderer.Render: string;
begin
  Result := '';
  if fRenderers.GeneratorComment.Render <> '' then
    Result := Result + fRenderers.GeneratorComment.Render + #13#10;
  Result := Result + fRenderers.SourceCode.Render + #13#10;
end;

{ TDocumentRenderer }

constructor TDocumentRenderer.Create(Renderers: THTMLDocumentParams);
begin
  inherited Create;
  fRenderers := Renderers;
end;

function TDocumentRenderer.Render: string;
var
  Writer: TStringBuilder;
begin
  Writer := TStringBuilder.Create;
  try
    if fRenderers.ProcessInst.Render <> '' then
      Writer.AppendLine(fRenderers.ProcessInst.Render);  // <?xml?>
    Writer.AppendLine(fRenderers.DocType.Render);
    Writer.AppendLine(fRenderers.HTMLTag.Render); // <html>
    // Write head section
    Writer.AppendLine('<head>');
    if fRenderers.CharSetTag.Render <> '' then
      Writer.AppendLine(fRenderers.CharSetTag.Render); // <meta>
    if fRenderers.GeneratorTag.Render <> '' then
      Writer.AppendLine(fRenderers.GeneratorTag.Render);
    Writer.AppendLine(fRenderers.TitleTag.Render);  // <title>
    // create style sheet
    Writer.AppendLine(fRenderers.StyleSheet.Render);
    Writer.AppendLine('</head>');
    // Begin body
    Writer.AppendLine('<body>');
    // write opening <pre> tag that for source using any required class
    Writer.AppendLine(fRenderers.SourceCode.Render);
    Writer.AppendLine('</body>');
    Writer.AppendLine('</html>');
    Result := Writer.ToString;
  finally
    Writer.Free;
  end;
end;

end.
