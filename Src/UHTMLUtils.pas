{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2016, Peter Johnson (www.delphidabbler.com).
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
///  <remarks>**NOTE:** Ideally this function would change its behaviour
///  depending on what output encoding is being used.</remarks>
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

type
  ///  <summary>Private static class that returns HTML entities for supported
  ///  characters.</summary>
  THTMLEntities = class(TObject)
    strict private
      class var
        fMap: TDictionary<Char, string>;
      class procedure Initialise;
    public
      class constructor Create;
      class destructor Destroy;
      class function HasEntity(const Ch: Char): Boolean;
      class function GetEntity(const Ch: Char): string;
      class function GetNumericEntity(const Ch: Char): string;
  end;

function MakeSafeHTMLText(const TheText: string): string;
var
  Ch: Char;
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    for Ch in TheText do
    begin
      if CharInSet(Ch, [CR, LF, SPACE, TAB]) then
        // Always want these white space chars to be passed through unchanged
        // Since they're white space (and TAB is also a control char) we do it
        // first.
        Builder.Append(Ch)
      else if THTMLEntities.HasEntity(Ch) then
        // Check remaining chars for associated named entities.
        Builder.Append(THTMLEntities.GetEntity(Ch))
      else if TCharacter.IsWhiteSpace(Ch) or TCharacter.IsControl(Ch) then
        // All remaining white space & control chars get converted to
        // numeric entities.
        Builder.Append(THTMLEntities.GetNumericEntity(Ch))
      else
        // Everything else passes through unchanged.
        Builder.Append(Ch);
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

{ THTMLEntities }

class constructor THTMLEntities.Create;
begin
  fMap := TDictionary<Char,string>.Create(TCharEqualityComparer.Create);
  Initialise;
end;

class destructor THTMLEntities.Destroy;
begin
  fMap.Free;
end;

class function THTMLEntities.GetEntity(const Ch: Char): string;
var
  Entity: string;
begin
  if not fMap.TryGetValue(Ch, Entity) then
    Exit(string(Ch));
  Result := '&' + Entity + ';';
end;

class function THTMLEntities.GetNumericEntity(const Ch: Char): string;
begin
  Result := '&#' + IntToStr(Ord(Ch)) + ';';
end;

class function THTMLEntities.HasEntity(const Ch: Char): Boolean;
begin
  Result := fMap.ContainsKey(Ch);
end;

class procedure THTMLEntities.Initialise;
begin
  fMap.Clear;
  with fMap do
  begin
    Add('&', 'amp');
    Add('<', 'lt');
    Add('>', 'gt');
    Add('"', 'quot');
  end;
end;

end.

