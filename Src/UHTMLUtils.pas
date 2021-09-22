{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2021, Peter Johnson (www.delphidabbler.com).
 *
 * Utility functions used when generating HTML.
}


unit UHTMLUtils;


interface


uses
  // Delphi
  Graphics;


///  <summary>Encodes the given string so that any HTML-incompatible characters
///  are replaced with equivalent character entities.</summary>
///  <remarks>
///  <para>Ideally this function would change its behaviour depending on what
///  doc type is being used: &apos; is required in XHTML but not in HTML 5.
///  However, it's unlikely there will be a user agent that doesn't understand
///  the &apos; entity in HTML5.</para>
///  <para>Furthermore the HTML5 spec requires that the only white space are
///  SPACE, TAB, LF, FF and CR and that control characters are not permitted.
///  However tests have shown browsers happily accepting other whitespace and
///  control characters, so these have not been trapped.</para>
///  <para>Finally, the Unicode non-characters are not permitted, but again
///  have not been trapped.</para>
///  </remarks>
function MakeSafeHTMLText(const TheText: string): string;

///  <summary>Converts a Delphi TColor value into a string suitable for use in
///  HTML or CSS code.</summary>
///  <remarks>Any system colors (like clBtnFace) are mapped to the actual colour
///  according to the current Windows settings.</remarks>
function ColorToHTML(const Color: TColor): string;


implementation


uses
  // Delphi
  SysUtils, Character, Generics.Defaults, Generics.Collections, Windows,
  // Project
  UComparers, UConsts;

function MakeSafeHTMLText(const TheText: string): string;
var
  Ch: Char;
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    for Ch in TheText do
    begin
      case Ch of
        LT:           Builder.Append('&lt;');
        GT:           Builder.Append('&gt;');
        APOSTROPHE:   Builder.Append('&apos;');
        DBLQUOTE:     Builder.Append('&quot;');
        AMPERSAND:    Builder.Append('&amp;');
        else          Builder.Append(Ch);
      end;
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function ColorToHTML(const Color: TColor): string;
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

