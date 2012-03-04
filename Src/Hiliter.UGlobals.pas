{
 * Hiliter.UGlobals.pas
 *
 * Declares types that describe syntax hilighters and defines interfaces to
 * various syntax highlighters and highlighter attributes.
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
 * The Original Code is Hiliter.UGlobals.pas.
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


unit Hiliter.UGlobals;


interface


uses
  // Delphi
  Classes, Graphics;


type

  {
  THiliteElement:
    Defines the different elements that can be highlighted in Pascal source
    code.
  }
  THiliteElement = (
    heWhitespace,   // white space
    heComment,      // comments: in (* .. *), { .. } or // styles
    heReserved,     // reserved word (keyword or directives)
    heIdentifier,   // an identifier that is not "reserved"
    heSymbol,       // punctuation symbol or symbol group
    heString,       // string or character literal preceeded by #
    heNumber,       // whole number
    heFloat,        // floating point number (may be in scientific format)
    heHex,          // hexadecimal integer
    hePreProcessor, // compiler directive: {$..} and (*$..*) styles supported
    heAssembler,    // assembler code between asm ... end keywords
    heError         // an unrecognised piece of code (shouldn't happen)
  );

  {
  TSyntaxHiliterKind:
    Enumeration of various kinds of highlighter.
  }
  TSyntaxHiliterKind = (
    hkHTMLFragment, // used to highlight code as HTML code fragment
    hkXHTML,        // used to highlight code as complete XHTML document
    hkXHTMLHideCSS  // as hkXHTML but embedded CSS hidden in HTML comments
  );

  {
  ISyntaxHiliter:
    Interface implemented by all highlighter classes. Provides overloaded
    methods used to highlight a document.
  }
  ISyntaxHiliter = interface(IInterface)
    ['{1E26A663-705C-4A20-A3CE-771176B35F65}']
    function Hilite(const RawCode: string): string;
      {Highlights source code and writes to a string.
        @param RawCode [in] Contains source code to be highlighted.
        @return Highlighted source code.
      }
  end;


implementation

end.

