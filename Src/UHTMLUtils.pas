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
 * Utility functions used when generating HTML.
}


unit UHTMLUtils;


interface


uses
  // Delphi
  Graphics;


function MakeSafeHTMLText(const TheText: string): string;
  {Encodes the given string so that any HTML-incompatible characters are
  replaced with equivalent character entities.
    @param TheText [in] Text to be encoded.
    @return The encoded text.
  }

function ColorToHTML(const Color: TColor): string;
  {Converts a Delphi TColor value into a string suitable for use in HTML or CSS
  code. Any system colors (like clBtnFace) are mapped to the actual colour
  according to the current Windows settings.
    @param Color [in] Colour value to be converted.
    @return HTML/CSS code for colour.
  }


implementation


uses
  // Delphi
  SysUtils, Windows;


function MakeSafeHTMLText(const TheText: string): string;
  {Encodes the given string so that any HTML-incompatible characters are
  replaced with equivalent character entities.
    @param TheText [in] Text to be encoded.
    @return the encoded text.
  }
var
  Idx: Integer; // loops thru the given text
begin
  Result := '';
  for Idx := 1 to Length(TheText) do
    case TheText[Idx] of
      '<':  // opens tags: replace with special char reference
        Result := Result + '&lt;';
      '>':  // closes tags: replace with special char reference
        Result := Result + '&gt;';
      '&':  // begins char references: replace with special char reference
        Result := Result + '&amp;';
      '"':  // quotes (can be a problem in quoted attributes)
        Result := Result + '&quot;';
      #0..#31, #127..#255:  // control and special chars: replace with encoding
        Result := Result + '&#' + IntToStr(Ord(TheText[Idx])) + ';';
      else  // compatible text: pass thru
        Result := Result + TheText[Idx];
    end;
end;

function ColorToHTML(const Color: TColor): string;
  {Converts a Delphi TColor value into a string suitable for use in HTML or CSS
  code. Any system colors (like clBtnFace) are mapped to the actual colour
  according to the current Windows settings.
    @param Color [in] Colour value to be converted.
    @return HTML/CSS code for colour.
  }
var
  ColorRGB: Integer;  // RGB code for the colour
begin
  // Convert colour to RGB, translating system colours to actual colour
  ColorRGB := ColorToRGB(Color);
  // Return HTML/CSS representation
  Result := Format(
    '#%0.2X%0.2X%0.2X',
    [GetRValue(ColorRGB), GetGValue(ColorRGB), GetBValue(ColorRGB)]
  );
end;

end.

