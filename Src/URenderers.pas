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
 * Provides various objects that render customised output documents.
}


unit URenderers;

interface

uses
  UConfig;

type
  IRenderer = interface(IInterface)
    ['{899344D1-36EA-4F2A-BC10-66C5F7187552}']
    function Render: string;
  end;

type
  TRendererFactory = record
  public
    class function CreateRenderer(const SourceCode: string;
      const Config: TConfig): IRenderer; static;
  end;

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
  TXHTMLDocumentParams = record
  public
    XMLDeclaration: IRenderer;
    ContentTypeMetaTag: IRenderer;
    HTMLTag: IRenderer;
    TitleTag: IRenderer;
    StyleSheet: IRenderer;
    SourceCode: IRenderer;  // maybe not needed if not parameterised
  end;

type
  TXHTMLDocumentRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fRenderers: TXHTMLDocumentParams;
  public
    constructor Create(Renderers: TXHTMLDocumentParams);
    function Render: string;
  end;

type
  TXMLDeclarationRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fCharSet: string;
  public
    constructor Create(const CharSet: string);
    function Render: string;
  end;

type
  TContentTypeMetaTagRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fCharSet: string;
  public
    constructor Create(const CharSet: string);
    function Render: string;
  end;

type
  THTMLTagRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fLanguage: string;
  public
    constructor Create(const Language: string);
    function Render: string;
  end;

type
  TTitleTagRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fTitle: string;
  public
    constructor Create(const Title: string);
    function Render: string;
  end;

type
  TLinkedStyleSheetRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fURL: string;
  public
    constructor Create(const URL: string);
    function Render: string;
  end;

type
  // could parameterise this renderer for -hidecss flag to avoid extra
  // complexity of several more classes
  TEmbeddedStyleSheetRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fCSSReader: IRenderer;
    fHideCSS: Boolean;
  public
    constructor Create(CSSReader: IRenderer; HideCSS: Boolean);
    function Render: string;
  end;

type
  TCSSRenderer = class abstract(TInterfacedObject)
  strict private
    function FindComment(const Text: string; var BeginIdx: Integer;
      out Size: Integer): Boolean;
    function TrimCSS(CSS: string): string;
  strict protected
    function GetCSS: string; virtual; abstract;
  public
    function Render: string;
  end;

type
  TCSSFileRenderer = class sealed(TCSSRenderer, IRenderer)
  strict private
    fCSSFile: string;
  strict protected
    function GetCSS: string; override;
  public
    constructor Create(const CSSFile: string);
  end;

type
  TCSSResourceRenderer = class sealed(TCSSRenderer, IRenderer)
  strict protected
    function GetCSS: string; override;
  end;

type
  TGeneratorCommentRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fWantComment: Boolean;
  public
    constructor Create(WantComment: Boolean);
    function Render: string;
  end;

type
  TSourceCodeRenderer = class(TInterfacedObject, IRenderer)
  strict private
    fSourceCode: string;
  public
    constructor Create(const SourceCode: string);
    function Render: string;
  end;


implementation

uses
  SysUtils, StrUtils, Classes, Windows,
  UHTMLUtils, IO.UHelper, Hiliter.UGlobals, Hiliter.UHiliters;

{ TRendererFactory }

class function TRendererFactory.CreateRenderer(const SourceCode: string;
  const Config: TConfig): IRenderer;
var
  DocParams: TXHTMLDocumentParams;
  FragParams: TXHTMLFragmentParams;
begin
  case Config.DocType of
    dtXHTML:
    begin
      DocParams.XMLDeclaration := TXMLDeclarationRenderer.Create(
        Config.OutputEncodingName)
      ;
      DocParams.ContentTypeMetaTag := TContentTypeMetaTagRenderer.Create(
        Config.OutputEncodingName
      );
      DocParams.HTMLTag := THTMLTagRenderer.Create(Config.Language);
      DocParams.TitleTag := TTitleTagRenderer.Create(Config.Title);
      case Config.CSSSource of
        csDefault:
          DocParams.StyleSheet := TEmbeddedStyleSheetRenderer.Create(
            TCSSResourceRenderer.Create, Config.HideCSS
          );
        csFile:
          DocParams.StyleSheet := TEmbeddedStyleSheetRenderer.Create(
            TCSSFileRenderer.Create(Config.CSSLocation), Config.HideCSS
          );
        csLink:
          DocParams.StyleSheet := TLinkedStyleSheetRenderer.Create(
            Config.CSSLocation
          );
      end;
      DocParams.SourceCode := TSourceCodeRenderer.Create(SourceCode);
      Result := TXHTMLDocumentRenderer.Create(DocParams);
    end;
    dtXHTMLFragment:
    begin
      FragParams.GeneratorComment := TGeneratorCommentRenderer.Create(
        Config.BrandingPermitted
      );
      FragParams.SourceCode := TSourceCodeRenderer.Create(SourceCode);
      Result := TXHTMLFragmentRenderer.Create(FragParams);
    end;
  end;
end;

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

{ TXHTMLDocumentRenderer }

constructor TXHTMLDocumentRenderer.Create(Renderers: TXHTMLDocumentParams);
begin
  inherited Create;
  fRenderers := Renderers;
end;

function TXHTMLDocumentRenderer.Render: string;
var
  Writer: TStringBuilder;
begin
  Writer := TStringBuilder.Create;
  try
    Writer.AppendLine(fRenderers.XMLDeclaration.Render);  // <?xml?>
    Writer.AppendLine(
      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" '
      + '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    );
    Writer.AppendLine(fRenderers.HTMLTag.Render); // <html>
    // Write head section
    Writer.AppendLine('<head>');
    Writer.AppendLine(fRenderers.ContentTypeMetaTag.Render); // <meta>
    Writer.AppendLine(
      '<meta name="generator" content="DelphiDabbler PasHi" />'
    );
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

{ TXMLDeclarationRenderer }

constructor TXMLDeclarationRenderer.Create(const CharSet: string);
begin
  inherited Create;
  fCharSet := CharSet;
end;

function TXMLDeclarationRenderer.Render: string;
begin
  Result := '<?xml version="1.0"';
  if fCharSet <> '' then
    Result := Result + Format(' encoding="%s"', [fCharSet]);
  Result := Result + '?>';
end;

{ TContentTypeMetaTagRenderer }

constructor TContentTypeMetaTagRenderer.Create(const CharSet: string);
begin
  inherited Create;
  fCharSet := CharSet;
end;

function TContentTypeMetaTagRenderer.Render: string;
begin
  Result := '<meta http-equiv="Content-Type" content="text/html';
  if fCharSet <> '' then
    Result := Result + Format(';charset=%s', [fCharSet]);
  Result := Result + '" />';
end;

{ THTMLTagRenderer }

constructor THTMLTagRenderer.Create(const Language: string);
begin
  inherited Create;
  fLanguage := Language;
end;

function THTMLTagRenderer.Render: string;
begin
  Result := '<html xmlns="http://www.w3.org/1999/xhtml"';
  if fLanguage <> '' then
    Result := Result + Format(' xml:lang="%0:s" lang="%0:s"', [fLanguage]);
  Result := Result + '>';
end;

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

{ TLinkedStyleSheetRenderer }

constructor TLinkedStyleSheetRenderer.Create(const URL: string);
begin
  Assert(URL <> '', ClassName + '.Create: URL is empty');
  inherited Create;
  fURL := URL;
end;

function TLinkedStyleSheetRenderer.Render: string;
begin
  Result := Format(
    '<link type="text/css" rel="stylesheet" href="%s" />', [fURL]
  );
end;

{ TEmbeddedStyleSheetRenderer }

constructor TEmbeddedStyleSheetRenderer.Create(CSSReader: IRenderer;
  HideCSS: Boolean);
begin
  inherited Create;
  fCSSReader := CSSReader;
  fHideCSS := HideCSS;
end;

function TEmbeddedStyleSheetRenderer.Render: string;
var
  Builder: TStringBuilder;
begin
  // return style tag and contents, protected by comments if flag passed to
  // constructor requires - read CSS from file or resources
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('<style type="text/css">');
    if fHideCSS then
      Builder.AppendLine('<!--');
    Builder.AppendLine(fCSSReader.Render);
    if fHideCSS then
      Builder.AppendLine('-->');
    Builder.Append('</style>');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

{ TCSSRenderer }

function TCSSRenderer.FindComment(const Text: string; var BeginIdx: Integer;
  out Size: Integer): Boolean;
  {Finds a comment in CSS text.
    @param Text [in] Text in which to find comment.
    @param BeginIdx [in/out] Caller sets index at which to start looking for
      comemnt in text. Updated to index of start of next comment. Unchanged if
      no comment found.
    @param Size [out] Receives size of comment found. Undefined if no comment
      found.
    @return True if a comment was found, false if not.
  }
var
  EndComment: Integer;    // index of end of first comment block of CSS
begin
  Result := False;
  BeginIdx := PosEx('/*', Text, BeginIdx);          // finds start of comment
  if BeginIdx > 0 then
  begin
    EndComment := PosEx('*/', Text, BeginIdx + 1); // finds end of comment
    if EndComment > BeginIdx then
    begin
      Size := EndComment - BeginIdx + 2;
      Result := True;
    end;
  end;
end;

function TCSSRenderer.Render: string;
begin
  // read CSS using GetCSS
  // strip out comments etc
  Result := TrimCSS(GetCSS);
end;

function TCSSRenderer.TrimCSS(CSS: string): string;
var
  StartComment: Integer;
  CommentSize: Integer;
  Lines: TStringList;
  LineIdx: Integer;
begin
  Result := CSS;
  // Remove all comments
  StartComment := 1;
  while FindComment(CSS, StartComment, CommentSize) do
    Delete(CSS, StartComment, CommentSize);
  // Delete empty lines
  Lines := TStringList.Create;
  try
    Lines.Text := CSS;
    for LineIdx := Pred(Lines.Count) downto 0 do
      if Trim(Lines[LineIdx]) = '' then
        Lines.Delete(LineIdx);
    CSS := Lines.Text;
  finally
    Lines.Free;
  end;
  Result := Trim(CSS);
end;

{ TCSSFileRenderer }

constructor TCSSFileRenderer.Create(const CSSFile: string);
begin
  inherited Create;
  fCSSFile := CSSFile;
end;

function TCSSFileRenderer.GetCSS: string;
begin
  Result := TIOHelper.FileToString(fCSSFile); // copes with encodings with BOMs
end;

{ TCSSResourceRenderer }

function TCSSResourceRenderer.GetCSS: string;
var
  RS: TResourceStream;
begin
  RS := TResourceStream.Create(HInstance, 'CSS_DEFAULT', RT_RCDATA);
  try
    Result := TIOHelper.BytesToString(TIOHelper.StreamToBytes(RS));
  finally
    RS.Free;
  end;
end;

{ TGeneratorCommentRenderer }

constructor TGeneratorCommentRenderer.Create(WantComment: Boolean);
begin
  inherited Create;
  fWantComment := WantComment;
end;

function TGeneratorCommentRenderer.Render: string;
resourcestring
  sCommentText = 'Highlighted Pascal code generated by DelphiDabbler PasHi';
begin
  if not fWantComment then
    Exit('');
  Result := Format('<!-- %s -->', [sCommentText]);
end;

{ TSourceCodeRenderer }

constructor TSourceCodeRenderer.Create(const SourceCode: string);
begin
  inherited Create;
  fSourceCode := SourceCode;
end;

function TSourceCodeRenderer.Render: string;
var
  Hiliter: ISyntaxHiliter;
begin
  Hiliter := TXHTMLHiliter.Create;
  Result := Trim(Hiliter.Hilite(fSourceCode));
end;

end.

