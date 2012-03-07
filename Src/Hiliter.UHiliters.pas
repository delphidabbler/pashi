{
 * Hiliter.UHiliters.pas
 *
 * Provides highlighter classes used to format and highlight source code in
 * HTML. Also contains a factory object used to create various highlighters.
 *
 * $Rev$
 * $Date$
 *
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is Hiliter.UHiliters.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
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
  TSyntaxHiliterFactory:
    Factory class used to create syntax highlighter objects.
  }
  TSyntaxHiliterFactory = class(TObject)
  public
    class function CreateHiliter(
      const Kind: TSyntaxHiliterKind): ISyntaxHiliter;
      {Create syntax highlighter of required kind.
        @param Kind [in] Kind of highlighter required.
        @return Created highlighter object.
      }
  end;

type

  {
  TSyntaxHiliterClass:
    Class type for syntax highlighters. Used by factory class to create syntax
    highlighter objects of different types.
  }
  TSyntaxHiliterClass = class of TParsedSyntaxHiliter;

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
    fEncodingName: string;    // Name of output encoding
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
    property EncodingName: string read fEncodingName;
      {Name of encoding to be added to document head}
  public
    constructor Create; virtual;
    function Hilite(const RawCode: string; const EncodingName: string): string;
      {Highlights source code and writes to a string.
        @param RawCode [in] Contains source code to be highlighted.
        @return Highlighted source code.
      }
  end;

  THTMLHiliter = class sealed(TParsedSyntaxHiliter, ISyntaxHiliter)
  strict private
    fIsFirstLine: Boolean; // Record whether we are about to write first line
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
    function GetMainCSSClass: string;
      {Gets name of CSS class used to format the whole of the source code.
        @return name of CSS class.
      }
    function GetElemCSSClass(const Elem: THiliteElement): string;
      {Gets name of CSS class associated with a highlight element.
        @param Elem [in] Element for which we need CSS class name.
        @return Name of CSS class.
      }
  end;

implementation


uses
  // Project
  UHTMLUtils;


{ TSyntaxHiliterFactory }

class function TSyntaxHiliterFactory.CreateHiliter(
  const Kind: TSyntaxHiliterKind): ISyntaxHiliter;
  {Create syntax highlighter of required kind.
    @param Kind [in] Kind of highlighter required.
    @return Created highlighter object.
  }
const
  // Array that maps highlighter kinds to highlighter classes
  cHiliterMap: array[TSyntaxHiliterKind] of TSyntaxHiliterClass = (
    THTMLHiliter,
    nil, // TXHTMLHiliter,
    nil  // TXHTMLHiliterHideCSS
  );
var
  Obj: TParsedSyntaxHiliter;  // created object
begin
  Obj := cHiliterMap[Kind].Create;  // create object
  Result := Obj as ISyntaxHiliter;  // return ISyntaxHiliter interface to object
end;

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

function TParsedSyntaxHiliter.Hilite(const RawCode: string;
  const EncodingName: string): string;
  {Highlights source code and writes to a string.
    @param RawCode [in] Contains source code to be highlighted.
    @return Highlighted source code.
  }
var
  Parser: THilitePasParser;   // object used to parse source
begin
  fEncodingName := EncodingName;
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

{ THTMLHiliter }

procedure THTMLHiliter.AfterElem(Elem: THiliteElement);
  {Called after a highlight element is output. Writes closing span tag where
  required.
    @param Elem [in] Kind of highlight element.
  }
begin
  // Close the element's span
  Writer.Append('</span>');
end;

procedure THTMLHiliter.BeforeElem(Elem: THiliteElement);
  {Called before a highlight element is output. Used to write <span> tag for
  required class if element is formatted.
    @param Elem [in] Kind of highlight element.
  }
begin
  inherited;
  // Open a span for required class
  Writer.AppendFormat('<span class="%s">', [GetElemCSSClass(Elem)]);
end;

procedure THTMLHiliter.BeginDoc;
begin
  fIsFirstLine := True;
  Writer.AppendFormat('<pre class="%s">', [GetMainCSSClass])
end;

procedure THTMLHiliter.BeginLine;
begin
  // Note we don't emit CRLF before first line since it must be on same line as
  // any opening <pre> tag
  if fIsFirstLine then
    fIsFirstLine := False
  else
    Writer.AppendLine;
end;

procedure THTMLHiliter.EndDoc;
begin
  Writer.AppendLine('</pre>');
end;

function THTMLHiliter.GetElemCSSClass(
  const Elem: THiliteElement): string;
  {Gets name of CSS class associated with a highlight element.
    @param Elem [in] Element for which we need CSS class name.
    @return Name of CSS class.
  }
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

function THTMLHiliter.GetMainCSSClass: string;
  {Gets name of CSS class used to format the whole of the source code.
    @return Name of CSS class.
  }
begin
  Result := 'pas-source';
end;

procedure THTMLHiliter.WriteElem(const ElemText: string);
begin
  // Write element text with illegal characters converted to entities
  Writer.Append(MakeSafeHTMLText(ElemText));
end;

end.

