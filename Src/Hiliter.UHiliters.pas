{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2021, Peter Johnson (www.delphidabbler.com).
 *
 * Provides highlighter classes used to format and highlight source code in
 * HTML.
 }


unit Hiliter.UHiliters;


interface


uses
  // Delphi
  SysUtils,
  // Project
  Hiliter.UGlobals, Hiliter.UPasParser;


type
  ///  <summary>Abstract base class for all highlighter classes that parse
  ///  and highlight source code using Pascal parser object.</summary>
  ///  <remarks>Handles parser events and calls virtual methods to write the
  ///  various document parts. Also provides a helper object to simplify
  ///  output of formatted code.</remarks>
  TParsedSyntaxHiliter = class abstract(TInterfacedObject)
  strict private
    fWriter: TStringBuilder;  // Helper object used to emit formatted source
    fLineNumber: Integer;
    fOptions: THiliteOptions;
    procedure ElementHandler(Parser: THilitePasParser; Elem: THiliteElement;
      const ElemText: string);
    procedure LineBeginHandler(Parser: THilitePasParser);
    procedure LineEndHandler(Parser: THilitePasParser);
  strict protected
    procedure BeginDoc; virtual;
    procedure EndDoc; virtual;
    procedure BeginLine; virtual;
    procedure EndLine; virtual;
    procedure WriteElem(const ElemText: string); virtual; abstract;
    procedure BeforeElem(Elem: THiliteElement); virtual;
    procedure AfterElem(Elem: THiliteElement); virtual;
    property Writer: TStringBuilder read fWriter;
    property LineNumber: Integer read fLineNumber write fLineNumber;
    function LineNumberStr: string;
    property Options: THiliteOptions read fOptions;
  public
    constructor Create; virtual;
    function Hilite(const RawCode: string; const Options: THiliteOptions):
      string;
  end;

type
  ///  <summary>Supplies names of CSS classes used in highlighting by PasHi v1.
  ///  </summary>
  TLegacyCSSNames = class(TInterfacedObject, ICSSClassNames)
  public
    function MainClass: string;
    function ElementClass(const Elem: THiliteElement): string;
  end;

  ///  <summary>Supplies names of CSS classes used in highlighting.</summary>
  TCSSNames = class(TInterfacedObject, ICSSClassNames)
    function MainClass: string;
    function ElementClass(const Elem: THiliteElement): string;
  end;

type
  ///  <summary>Highlights source code in HTML format.</summary>
  THTMLHiliter = class sealed(TParsedSyntaxHiliter, ISyntaxHiliter)
  strict private
    fCSSClases: ICSSClassNames;  // provides name of CSS classes
    fIsEmptyLine: Boolean;       // flags if a line has no content
  strict protected
    procedure BeginDoc; override;
    procedure EndDoc; override;
    procedure BeginLine; override;
    procedure EndLine; override;
    procedure BeforeElem(Elem: THiliteElement); override;
    procedure WriteElem(const ElemText: string); override;
    procedure AfterElem(Elem: THiliteElement); override;
  public
    constructor Create(CSSClasses: ICSSClassNames); reintroduce;
  end;

implementation


uses
  // Project
  UHTMLUtils;


{ TParsedSyntaxHiliter }

procedure TParsedSyntaxHiliter.AfterElem(Elem: THiliteElement);
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.BeforeElem(Elem: THiliteElement);
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.BeginDoc;
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.BeginLine;
begin
  // Do nothing: descendants override
end;

constructor TParsedSyntaxHiliter.Create;
begin
  inherited;
  // Do nothing ** Do not remove this constructor **
end;

procedure TParsedSyntaxHiliter.ElementHandler(Parser: THilitePasParser;
  Elem: THiliteElement; const ElemText: string);
begin
  BeforeElem(Elem);
  WriteElem(ElemText);
  AfterElem(Elem);
end;

procedure TParsedSyntaxHiliter.EndDoc;
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.EndLine;
begin
  // Do nothing: descendants override
end;

function TParsedSyntaxHiliter.Hilite(const RawCode: string;
  const Options: THiliteOptions): string;
var
  Parser: THilitePasParser;   // object used to parse source
begin
  fOptions := Options;
  fLineNumber := 0;
  fWriter := TStringBuilder.Create;
  try
    // Create parser
    Parser := THilitePasParser.Create;
    try
      // Set event handlers to handle elements and line start / end
      Parser.OnElement := ElementHandler;
      Parser.OnLineBegin := LineBeginHandler;
      Parser.OnLineEnd := LineEndHandler;
      // Parse the document:
      BeginDoc;   // overridden in descendants to initialise document
      Parser.Parse(RawCode);
      EndDoc;     // overridden in descendants to finalise document
    finally
      Parser.Free;
    end;
    Result := fWriter.ToString;
  finally
    fWriter.Free;
  end;
end;

procedure TParsedSyntaxHiliter.LineBeginHandler(Parser: THilitePasParser);
begin
  Inc(fLineNumber);
  BeginLine;
end;

procedure TParsedSyntaxHiliter.LineEndHandler(Parser: THilitePasParser);
begin
  EndLine;
end;

function TParsedSyntaxHiliter.LineNumberStr: string;
begin
  Result := IntToStr(fLineNumber);
  while Length(Result) < Options.Width do
    Result := Options.Padding + Result;
end;

{ THTMLHiliter }

procedure THTMLHiliter.AfterElem(Elem: THiliteElement);
begin
  // Close the element's span
  Writer.Append('</span>');
end;

procedure THTMLHiliter.BeforeElem(Elem: THiliteElement);
begin
  inherited;
  // Open a span for required class
  Writer.AppendFormat('<span class="%s">', [fCSSClases.ElementClass(Elem)]);
end;

procedure THTMLHiliter.BeginDoc;
begin
  Writer.AppendFormat('<div class="%s">', [fCSSClases.MainClass]);
  Writer.AppendLine;
end;

procedure THTMLHiliter.BeginLine;
const
  LineClasses: array[Boolean] of string = ('even-line', 'odd-line');
begin
  if Options.AlternateLines then
    Writer.Append(Format('<pre class="%s">', [LineClasses[Odd(LineNumber)]]))
  else
    Writer.Append('<pre class="line">');
  if Options.UseLineNumbering then
  begin
    Writer.Append(
      Format('<span class="linenum">%s</span>', [LineNumberStr])
    );
    fIsEmptyLine := False;
  end
  else
    fIsEmptyLine := True;
end;

constructor THTMLHiliter.Create(CSSClasses: ICSSClassNames);
begin
  inherited Create;
  fCSSClases := CSSClasses;
end;

procedure THTMLHiliter.EndDoc;
begin
  Writer.AppendLine('</div>');
end;

procedure THTMLHiliter.EndLine;
begin
  if fIsEmptyLine then
    Writer.Append('&nbsp;');  // forces display: &nbsp; better than ' ' here
  Writer.AppendLine('</pre>');
end;

procedure THTMLHiliter.WriteElem(const ElemText: string);
begin
  // Write element text with illegal characters converted to entities
  if ElemText <> '' then
  begin
    Writer.Append(MakeSafeHTMLText(ElemText));
    fIsEmptyLine := False;
  end;
end;

{ TLegacyCSSNames }

function TLegacyCSSNames.ElementClass(const Elem: THiliteElement): string;
const
  // Map of highlight element kinds onto name of CSS class used to format it
  cClassMap: array[THiliteElement] of string = (
    'pas-space',    // heWhitespace
    'pas-comment',  // heComment
    'pas-kwd',      // heReserved
    'pas-ident',    // heIdentifier
    'pas-sym',      // heSymbol
    'pas-str',      // heString
    'pas-num',      // heNumber
    'pas-float',    // heFloat
    'pas-hex',      // heHex
    'pas-preproc',  // hePreProcessor
    'pas-asm',      // heAssembler
    'pas-err'       // heError
  );
begin
  Result := cClassMap[Elem];
end;

function TLegacyCSSNames.MainClass: string;
begin
  Result := 'pas-source';
end;

{ TCSSNames }

function TCSSNames.ElementClass(const Elem: THiliteElement): string;
const
  // Map of highlight element kinds onto name of CSS class used to format it
  cClassMap: array[THiliteElement] of string = (
    'space',    // heWhitespace
    'comment',  // heComment
    'kwd',      // heReserved
    'ident',    // heIdentifier
    'sym',      // heSymbol
    'str',      // heString
    'num',      // heNumber
    'float',    // heFloat
    'hex',      // heHex
    'preproc',  // hePreProcessor
    'asm',      // heAssembler
    'err'       // heError
  );
begin
  Result := cClassMap[Elem];
end;

function TCSSNames.MainClass: string;
begin
  Result := 'code-pascal';
end;

end.

