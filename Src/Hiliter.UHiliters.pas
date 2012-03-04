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

{$WARN UNSAFE_TYPE OFF}

interface


uses
  // Project
  Hiliter.UGlobals;


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


implementation


{
  NOTES:

  The class heirachy for syntax highlighter classes in this unit is:

  TSyntaxHiliter - abstract base class
  |
  +-- TParsedHiliter - abstract base class for classes that parse source code
      |
      +-- TBaseHTMLHiliter - base class for highlighters that generate HTML
          |
          +-- THTMLCSSHiliter - base class for HTML highlighters that use CSS
              |                 to format source code
              |
              +-- * THTMLFragmentHiliter - creates HTML fragment using CSS and
              |                            enclosed in <pre>..</pre> tags
              |
              +-- TXHTMLHiliterBase - base class complete XHTML document
                  |                   highlighters that use CSS
                  |
                  +-- * TXHTMLHiliter - creates XHTML document that doesn't hide
                  |                     CSS in comments
                  |
                  +-- * TXHTMLHiliterHideCSS - create XHTML document that hides
                                               CSS in comments

  * indicates a class constructed by factory class

}


uses
  // Delphi
  SysUtils, StrUtils, Classes, Windows, Graphics,
  // Project
  IntfCommon, Hiliter.UPasParser, UHTMLUtils, UStrStreamWriter;


type

  {
  TSyntaxHiliterClass:
    Class type for syntax highlighters. Used by factory class to create syntax
    highlighter objects of different types.
  }
  TSyntaxHiliterClass = class of TSyntaxHiliter;

  {
  TSyntaxHiliter:
    Abstract base class for all syntax highlighter classes. Provides virtual
    abstract methods and a virtual constructor that descendants override. This
    class is provided to give common base class that allows factory class to
    use TSyntaxHiliterClass for object creation.
  }
  TSyntaxHiliter = class(TInterfacedObject)
  public
    procedure Hilite(const Src, Dest: TStream);
      overload; virtual; abstract;
      {Highlights source code on an input stream and writes to output stream.
        @param Src [in] Stream containing source code to be highlighted.
        @param Dest [in] Stream that receives highlighted document.
      }
    function Hilite(const RawCode: string): string;
      overload; virtual; abstract;
      {Highlights source code and writes to a string.
        @param RawCode [in] Contains source code to be highlighted.
        @return Highlighted source code.
      }
    constructor Create; virtual;
      {Class constructor: instantiates object. This do-nothing virtual
      constructor is required to enable polymorphism to work for descendant
      classes.
      }
  end;

  {
  TParsedHiliter:
    Abstract base class for all highlighter classes that parse source code using
    Pascal parser object. Handles parser events and calls virtual methods to
    write the various document parts. Also provides a helper object to simplify
    output of formatted code.
  }
  TParsedHiliter = class(TSyntaxHiliter)
  strict private
    fWriter: TStrStreamWriter;  // Helper object used to emit formatted source
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
    property Writer: TStrStreamWriter read fWriter;
      {Helper object used to write formatted code to output}
  public
    procedure Hilite(const Src, Dest: TStream);
      overload; override;
      {Highlights source code on an input stream and writes to output stream.
        @param Src [in] Stream containing source code to be highlighted.
        @param Dest [in] Stream that receives highlighted document.
      }
    function Hilite(const RawCode: string): string;
      overload; override;
      {Highlights source code and writes to a string.
        @param RawCode [in] Contains source code to be highlighted.
        @return Highlighted source code.
      }
  end;

  {
  TBaseHTMLHiliter:
    Base class for all highlighters that emit HTML. Provides some common
    functionality.
  }
  TBaseHTMLHiliter = class(TParsedHiliter)
  strict private
    fIsFirstLine: Boolean; // Record whether we are about to write first line
  strict protected
    procedure BeginDoc; override;
      {Called just before document is parsed: used to initialise document.
      }
    procedure BeginLine; override;
      {Called when a new line in output is started: writes new line where
      required.
      }
    procedure WriteElem(const ElemText: string); override;
      {Outputs element's text.
        @param ElemText [in] Text of the element.
      }
    property IsFirstLine: Boolean read fIsFirstLine;
      {Flag true when line to be written is first line and false after that}
  end;

  {
  THTMLCSSHiliter:
    Base class for all HTML highlighters that use CSS for formatting. Encloses
    each highlight elemement in <span> tags and source code in <pre> that use
    CSS classes. Also gets names of classes for difference document sections.
  }
  THTMLCSSHiliter = class(TBaseHTMLHiliter)
  strict protected
    procedure BeforeElem(Elem: THiliteElement); override;
      {Called before a highlight element is output. Used to write <span> tag for
      required class if element is formatted.
        @param Elem [in] Kind of highlight element.
      }
    procedure AfterElem(Elem: THiliteElement); override;
      {Called after a highlight element is output. Writes closing span tag where
      required.
        @param Elem [in] Kind of highlight element.
      }
    procedure OpenSourceCode;
      {Called to write <pre> tag that starts the source code. Adds a class name
      to tag if font information specified by highlight attributes.
      }
    procedure CloseSourceCode;
      {Writes closing </pre> tag that ends source code.
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

  {
  THTMLFragmentHiliter:
    Highlighter that is used to create a fragment of HTML describing highlighted
    source code between <pre>..</pre> tags that uses CSS classes for formatting.
    We require that the required CSS classes are defined in the host document.
    Classes need to be provided for any elements that do not have nul
    highlighter attributes.
  }
  THTMLFragmentHiliter = class(THTMLCSSHiliter,
    ISyntaxHiliter
  )
  strict protected
    procedure BeginDoc; override;
      {Called just before document is parsed: writes opening <pre> tag.
      }
    procedure EndDoc; override;
      {Called after parsing complete: writes closing </pre> tag.
      }
  end;

  {
  TXHTMLHiliterBase:
    Abstract base class for highlighters that emits a complete XHTML document
    containing the source code. Creates an emebedded style sheet from default
    CSS style sheet stored in resources.
  }
  TXHTMLHiliterBase = class(THTMLCSSHiliter)
  strict protected
    procedure BeginDoc; override;
      {Called just before document is parsed: used to write XHTML code for
      document head section and first part of body.
      }
    procedure EndDoc; override;
      {Called after parsing complete: writes XHTML that closes document.
      }
    function IsCSSHidden: Boolean; virtual; abstract;
      {Determines if embedded CSS is to be hidden in HTML comments.
        @return True if CSS hidden, False if not.
      }
    function GetStyleSheet: string; virtual;
      {Gets the text of the default style sheet from resources. This style sheet
      is embedded in the document. Any comments or multiple newlines in style
      sheet are removed.
        @return Required style sheet.
      }
  end;

  {
  TXHTMLHiliter:
    Highlighter that emits a complete XHTML document containing the source
    code and embedded CSS. Designed for modern browsers, the CSS code is not
    hidden in HTML comments.
  }
  TXHTMLHiliter = class(TXHTMLHiliterBase,
    ISyntaxHiliter
  )
  strict protected
    function IsCSSHidden: Boolean; override;
      {Determines if embedded CSS is to be hidden in HTML comments.
        @return False - CSS is not hidden.
      }
  end;

  {
  TXHTMLHiliterHideCSS:
    Highlighter that emits a complete XHTML document containing the source
    code and embedded CSS. Designed for older browsers, the CSS code is hidden
    from the browser in HTML comments.
  }
  TXHTMLHiliterHideCSS = class(TXHTMLHiliterBase,
    ISyntaxHiliter
  )
  strict protected
    function IsCSSHidden: Boolean; override;
      {Determines if embedded CSS is to be hidden in HTML comments.
        @return True - CSS is hidden.
      }
  end;

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
    THTMLFragmentHiliter,
    TXHTMLHiliter,
    TXHTMLHiliterHideCSS
  );
var
  Obj: TSyntaxHiliter;  // created object
begin
  Obj := cHiliterMap[Kind].Create;  // create object
  Result := Obj as ISyntaxHiliter;  // return ISyntaxHiliter interface to object
end;

{ TSyntaxHiliter }

constructor TSyntaxHiliter.Create;
  {Class constructor: instantiates object. This do-nothing virtual constructor
  is required to enable polymorphism to work for descendant classes.
  }
begin
  inherited;
  // Do nothing ** Do not remove this constructor **
end;

{ TParsedHiliter }

procedure TParsedHiliter.AfterElem(Elem: THiliteElement);
  {Called after a highlight element is output. Used to write code used to
  finalise element formatting.
    @param Elem [in] Kind of highlight element.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedHiliter.BeforeElem(Elem: THiliteElement);
  {Called before a highlight element is output. Used to write code used to
  display element in required format.
    @param Elem [in] Kind of highlight element.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedHiliter.BeginDoc;
  {Called just before document is parsed: used to initialise document.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedHiliter.BeginLine;
  {Called when a new line in output is started: used to initialise a line in
  output.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedHiliter.ElementHandler(Parser: THilitePasParser;
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

procedure TParsedHiliter.EndDoc;
  {Called after parsing complete: used to finalise document.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedHiliter.EndLine;
  {Called when a line is ending: used to terminate a line in output.
  }
begin
  // Do nothing: descendants override
end;

procedure TParsedHiliter.Hilite(const Src, Dest: TStream);
  {Highlights source code on an input stream and writes to output stream.
    @param Src [in] Stream containing source code to be highlighted.
    @param Dest [in] Stream that receives highlighted document.
  }
var
  Parser: THilitePasParser;   // object used to parse source
  SS: TStringStream;          // gets string from input stream
begin
  fWriter := TStrStreamWriter.Create(Dest);
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
      SS := TStringStream.Create('', TEncoding.Default);
      try
        SS.CopyFrom(Src, 0);
        Parser.Parse(SS.DataString);
      finally
        SS.Free
      end;
      EndDoc;     // overridden in descendants to finalise document
    finally
      Parser.Free;
    end;
  finally
    fWriter.Free;
  end;
end;

function TParsedHiliter.Hilite(const RawCode: string): string;
  {Highlights source code and writes to a string.
    @param RawCode [in] Contains source code to be highlighted.
    @return Highlighted source code.
  }
var
  SrcStm: TStringStream;  // stream used to store raw source code
  DestStm: TStringStream; // stream used to receive output
begin
  DestStm := nil;
  SrcStm := TStringStream.Create(RawCode);
  try
    DestStm := TStringStream.Create('');
    Hilite(SrcStm, DestStm);
    Result := DestStm.DataString;
  finally
    DestStm.Free;
    SrcStm.Free;
  end;
end;

procedure TParsedHiliter.LineBeginHandler(Parser: THilitePasParser);
  {Handles parser's OnLineBegin event: calls virtual do nothing method that
  descendants override to output data needed to start a new line.
    @param Parser [in] Reference to parser that triggered event (unused).
  }
begin
  BeginLine;
end;

procedure TParsedHiliter.LineEndHandler(Parser: THilitePasParser);
  {Handles parser's OnLineEnd event: calls virtual do nothing method that
  descendants override to output data needed to end a new line.
    @param Parser [in] Reference to parser that triggered event (unused).
  }
begin
  EndLine;
end;

{ TBaseHTMLHiliter }

procedure TBaseHTMLHiliter.BeginDoc;
  {Called just before document is parsed: used to initialise document.
  }
begin
  // Note that we are about to write first line
  fIsFirstLine := True;
end;

procedure TBaseHTMLHiliter.BeginLine;
  {Called when a new line in output is started: writes new line where required.
  }
begin
  // Note we don't emit CRLF before first line since it must be on same line as
  // any opening <pre> tag
  if fIsFirstLine then
    fIsFirstLine := False
  else
    Writer.WriteStrLn;
end;

procedure TBaseHTMLHiliter.WriteElem(const ElemText: string);
  {Outputs element's text.
    @param ElemText [in] Text of the element.
  }
begin
  // Write element text with illegal characters converted to entities
  Writer.WriteStr(MakeSafeHTMLText(ElemText));
end;

{ THTMLCSSHiliter }

procedure THTMLCSSHiliter.AfterElem(Elem: THiliteElement);
  {Called after a highlight element is output. Writes closing span tag where
  required.
    @param Elem [in] Kind of highlight element.
  }
begin
  inherited;
  // Close the element's span
  Writer.WriteStr('</span>');
end;

procedure THTMLCSSHiliter.BeforeElem(Elem: THiliteElement);
  {Called before a highlight element is output. Used to write <span> tag for
  required class if element is formatted.
    @param Elem [in] Kind of highlight element.
  }
begin
  inherited;
  // Open a span for required class
  Writer.WriteStr('<span class="%s">', [GetElemCSSClass(Elem)]);
end;

procedure THTMLCSSHiliter.CloseSourceCode;
  {Writes closing </pre> tag that ends source code.
  }
begin
  Writer.WriteStrLn('</pre>');
end;

function THTMLCSSHiliter.GetElemCSSClass(
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

function THTMLCSSHiliter.GetMainCSSClass: string;
  {Gets name of CSS class used to format the whole of the source code.
    @return Name of CSS class.
  }
begin
  Result := 'pas-source';
end;

procedure THTMLCSSHiliter.OpenSourceCode;
  {Called to write <pre> tag that starts the source code.
  }
begin
  Writer.WriteStr('<pre class="%s">', [GetMainCSSClass])
end;

{ THTMLFragmentHiliter }

procedure THTMLFragmentHiliter.BeginDoc;
  {Called just before document is parsed: writes opening <pre> tag.
  }
resourcestring
  // Output text
  sCommentText = 'Highlighted Pascal code generated by DelphiDabbler PasHi';
begin
  inherited;
  Writer.WriteStrLn('<!-- %s -->', [sCommentText]);
  OpenSourceCode;
end;

procedure THTMLFragmentHiliter.EndDoc;
  {Called after parsing complete: writes closing </pre> tag.
  }
begin
  inherited;
  CloseSourceCode;
end;

{ TXHTMLHiliterBase }

procedure TXHTMLHiliterBase.BeginDoc;
  {Called just before document is parsed: used to write XHTML code for
  document head section and first part of body.
  }
resourcestring
  // Output text
  sTitle = 'File generated by DelphiDabbler PasHi Pascal Highlighter';
begin
  inherited;
  // Write XHTML document definition
  Writer.WriteStrLn('<?xml version="1.0"?>');
  Writer.WriteStrLn(
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" '
    + '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  );
  // Open document
  Writer.WriteStrLn(
    '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'
  );
  // Write head section
  Writer.WriteStrLn('<head>');
  Writer.WriteStrLn('<title>%s</title>', [sTitle]);
  Writer.WriteStrLn(
    '<meta name="generator" content="DelphiDabbler PasHi Pascal Highlighter" />'
  );
  // create style sheet
  Writer.WriteStrLn('<style type="text/css">');
  if IsCSSHidden then
    Writer.WriteStrLn('<!--');
  Writer.WriteStrLn(GetStyleSheet);
  if IsCSSHidden then
    Writer.WriteStrLn('-->');
  Writer.WriteStrLn('</style>');
  Writer.WriteStrLn('</head>');
  // Begin body
  Writer.WriteStrLn('<body>');
  // write opening <pre> tag that for source using any required class
  OpenSourceCode;
end;

procedure TXHTMLHiliterBase.EndDoc;
  {Called after parsing complete: writes XHTML that closes document.
  }
begin
  inherited;
  // Close source code section
  CloseSourceCode;
  // Close body section
  Writer.WriteStrLn('</body>');
  // Close document
  Writer.WriteStrLn('</html>');
end;

function TXHTMLHiliterBase.GetStyleSheet: string;
  {Gets the text of the default style sheet from resources. This style sheet is
  embedded in the document. Any comments or multiple newlines in style sheet are
  removed.
    @return Required style sheet.
  }

  // ---------------------------------------------------------------------------
  function FindComment(const Text: string;
    var BeginIdx: Integer; out Size: Integer): Boolean;
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
  // ---------------------------------------------------------------------------

var
  SS: TStringStream;      // stream that receives CSS read from resources
  RS: TResourceStream;    // stream onto CSS style sheet in resources
  StartComment: Integer;  // index of start of each comment
  CommentSize: Integer;   // size of each comemnt
begin
  SS := nil;
  try
    // Read CSS code from resources into string stream
    RS := TResourceStream.Create(HInstance, 'CSS_DEFAULT', RT_RCDATA);
    SS := TStringStream.Create('');
    SS.CopyFrom(RS, 0);
    Result := SS.DataString;
    // Remove all comments
    StartComment := 1;
    while FindComment(Result, StartComment, CommentSize) do
      Delete(Result, StartComment, CommentSize);
    // Replace multiple line breaks with single ones
    while AnsiPos(#13#10#13#10, Result) > 0 do
      Result := StringReplace(Result, #13#10#13#10, #13#10, [rfReplaceAll]);
    // Remove leading and trailing spaces and line breaks
    Result := Trim(Result);
  finally
    FreeAndNil(RS);
    FreeAndNil(SS);
  end;
end;

{ TXHTMLHiliter }

function TXHTMLHiliter.IsCSSHidden: Boolean;
  {Determines if embedded CSS is to be hidden in HTML comments.
    @return False - CSS is not hidden.
  }
begin
  Result := False;
end;

{ TXHTMLHiliterHideCSS }

function TXHTMLHiliterHideCSS.IsCSSHidden: Boolean;
  {Determines if embedded CSS is to be hidden in HTML comments.
    @return True - CSS is hidden.
  }
begin
  Result := True;
end;

end.

