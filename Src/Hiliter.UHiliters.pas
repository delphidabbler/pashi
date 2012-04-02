{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
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
  {
  TParsedSyntaxHiliter:
    Abstract base class for all highlighter classes that parse source code using
    Pascal parser object. Handles parser events and calls virtual methods to
    write the various document parts. Also provides a helper object to simplify
    output of formatted code.
  }
  TParsedSyntaxHiliter = class abstract(TInterfacedObject)
  strict private
    fWriter: TStringBuilder;  // Helper object used to emit formatted source
    procedure ElementHandler(Parser: THilitePasParser; Elem: THiliteElement;
      const ElemText: string);
      {Handles parser's OnElement event: calls virtual do nothing and abstract
      methods that descendants override to write a document element in required
      format.
        @param Parser [in] Reference to parser that triggered event (unused).
        @param Elem [in] Type of element to output.
        @param ElemText [in] Text to be output.
      }
    procedure LineBeginHandler(Parser: THilitePasParser);
      {Handles parser's OnLineBegin event: calls virtual do nothing method that
      descendants override to output data needed to start a new line.
        @param Parser [in] Reference to parser that triggered event (unused).
      }
    procedure LineEndHandler(Parser: THilitePasParser);
      {Handles parser's OnLineEnd event: calls virtual do nothing method that
      descendants override to output data needed to end a new line.
        @param Parser [in] Reference to parser that triggered event (unused).
      }
  strict protected
    procedure BeginDoc; virtual;
      {Called just before document is parsed: used to initialise document.
      }
    procedure EndDoc; virtual;
      {Called after parsing complete: used to finalise document.
      }
    procedure BeginLine; virtual;
      {Called when a new line in output is started: used to initialise a line in
      output.
      }
    procedure EndLine; virtual;
      {Called when a line is ending: used to terminate a line in output.
      }
    procedure WriteElem(const ElemText: string); virtual; abstract;
      {Called for each different highlight element in document and is overridden
      to output element's text.
        @param ElemText [in] Text of the element.
      }
    procedure BeforeElem(Elem: THiliteElement); virtual;
      {Called before a highlight element is output. Used to write code used to
      display element in required format.
        @param Elem [in] Kind of highlight element.
      }
    procedure AfterElem(Elem: THiliteElement); virtual;
      {Called after a highlight element is output. Used to write code used to
      finalise element formatting.
        @param Elem [in] Kind of highlight element.
      }
    property Writer: TStringBuilder read fWriter;
      {Helper object used to write formatted code to output}
  public
    constructor Create; virtual;
    function Hilite(const RawCode: string): string;
      {Highlights source code and writes to a string.
        @param RawCode [in] Contains source code to be highlighted.
        @return Highlighted source code.
      }
  end;

type
  TLegacyCSSNames = class(TInterfacedObject, ICSSClassNames)
  public
    function MainClass: string;
    function ElementClass(const Elem: THiliteElement): string;
  end;

  TCSSNames = class(TInterfacedObject, ICSSClassNames)
    function MainClass: string;
    function ElementClass(const Elem: THiliteElement): string;
  end;

type
  TXHTMLHiliter = class sealed(TParsedSyntaxHiliter, ISyntaxHiliter)
  strict private
    fIsFirstLine: Boolean; // Record whether we are about to write first line
    fCSSClases: ICSSClassNames;  // provides name of CSS classes
  strict protected
    procedure BeginDoc; override;
      {Called just before document is parsed: writes opening <pre> tag.
      }
    procedure EndDoc; override;
      {Called after parsing complete: writes closing </pre> tag.
      }
    procedure BeginLine; override;
      {Called when a new line in output is started: writes new line where
      required.
      }
    procedure BeforeElem(Elem: THiliteElement); override;
      {Called before a highlight element is output. Used to write <span> tag for
      required class if element is formatted.
        @param Elem [in] Kind of highlight element.
      }
    procedure WriteElem(const ElemText: string); override;
      {Outputs element's text.
        @param ElemText [in] Text of the element.
      }
    procedure AfterElem(Elem: THiliteElement); override;
      {Called after a highlight element is output. Writes closing span tag where
      required.
        @param Elem [in] Kind of highlight element.
      }
  public
    constructor Create(CSSClasses: ICSSClassNames); reintroduce;
  end;

implementation


uses
  // Project
  UHTMLUtils;


{ TParsedSyntaxHiliter }

procedure TParsedSyntaxHiliter.AfterElem(Elem: THiliteElement);
  {Called after a highlight element is output. Used to write code used to
  finalise element formatting.
    @param Elem [in] Kind of highlight element.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.BeforeElem(Elem: THiliteElement);
  {Called before a highlight element is output. Used to write code used to
  display element in required format.
    @param Elem [in] Kind of highlight element.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.BeginDoc;
  {Called just before document is parsed: used to initialise document.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.BeginLine;
  {Called when a new line in output is started: used to initialise a line in
  output.
  }
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
  {Handles parser's OnElement event: calls virtual do nothing and abstract
  methods that descendants override to write a document element in required
  format.
    @param Parser [in] Reference to parser that triggered event (unused).
    @param Elem [in] Type of element to output.
    @param ElemText [in] Text to be output.
  }
begin
  BeforeElem(Elem);
  WriteElem(ElemText);
  AfterElem(Elem);
end;

procedure TParsedSyntaxHiliter.EndDoc;
  {Called after parsing complete: used to finalise document.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedSyntaxHiliter.EndLine;
  {Called when a line is ending: used to terminate a line in output.
  }
begin
  // Do nothing: descendants override
end;

function TParsedSyntaxHiliter.Hilite(const RawCode: string): string;
  {Highlights source code and writes to a string.
    @param RawCode [in] Contains source code to be highlighted.
    @return Highlighted source code.
  }
var
  Parser: THilitePasParser;   // object used to parse source
begin
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
  {Handles parser's OnLineBegin event: calls virtual do nothing method that
  descendants override to output data needed to start a new line.
    @param Parser [in] Reference to parser that triggered event (unused).
  }
begin
  BeginLine;
end;

procedure TParsedSyntaxHiliter.LineEndHandler(Parser: THilitePasParser);
  {Handles parser's OnLineEnd event: calls virtual do nothing method that
  descendants override to output data needed to end a new line.
    @param Parser [in] Reference to parser that triggered event (unused).
  }
begin
  EndLine;
end;

{ TXHTMLHiliter }

procedure TXHTMLHiliter.AfterElem(Elem: THiliteElement);
  {Called after a highlight element is output. Writes closing span tag where
  required.
    @param Elem [in] Kind of highlight element.
  }
begin
  // Close the element's span
  Writer.Append('</span>');
end;

procedure TXHTMLHiliter.BeforeElem(Elem: THiliteElement);
  {Called before a highlight element is output. Used to write <span> tag for
  required class if element is formatted.
    @param Elem [in] Kind of highlight element.
  }
begin
  inherited;
  // Open a span for required class
  Writer.AppendFormat('<span class="%s">', [fCSSClases.ElementClass(Elem)]);
end;

procedure TXHTMLHiliter.BeginDoc;
begin
  fIsFirstLine := True;
  Writer.AppendFormat('<pre class="%s">', [fCSSClases.MainClass])
end;

procedure TXHTMLHiliter.BeginLine;
begin
  // Note we don't emit CRLF before first line since it must be on same line as
  // any opening <pre> tag
  if fIsFirstLine then
    fIsFirstLine := False
  else
    Writer.AppendLine;
end;

constructor TXHTMLHiliter.Create(CSSClasses: ICSSClassNames);
begin
  inherited Create;
  fCSSClases := CSSClasses;
end;

procedure TXHTMLHiliter.EndDoc;
begin
  Writer.AppendLine('</pre>');
end;

procedure TXHTMLHiliter.WriteElem(const ElemText: string);
begin
  // Write element text with illegal characters converted to entities
  Writer.Append(MakeSafeHTMLText(ElemText));
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

