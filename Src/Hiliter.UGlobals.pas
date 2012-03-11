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
 * Declares types required when using syntax highlighters. Defines interface
 * supported by highlighter objects and enumeration of different highlighter
 * elements.
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

