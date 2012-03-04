{
 * UComparers.pas
 *
 * Defines a case insensitive string equality comparer.
 *
 * $Rev$
 * $Date$
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
 * The Original Code is UComparers.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2012 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s)
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UComparers;


interface


uses
  // Delphi
  Generics.Defaults;


type
  ///  <summary>
  ///  Case insenstive string equality comparer.
  ///  </summary>
  TTextEqualityComparer = class(TEqualityComparer<string>,
    IEqualityComparer<string>
  )
  public
    ///  <summary>Checks if two strings are equal, ignoring case.</summary>
    function Equals(const Left, Right: string): Boolean; override;
    ///  <summary>Gets hash of lower case version of given string.</summary>
    function GetHashCode(const Value: string): Integer; override;
  end;


implementation


uses
  // Delphi
  SysUtils;


///  <summary>String has function.</summary>
///  <remarks>Sourced from http://www.scalabium.com/faq/dct0136.htm.</summary>
function ElfHash(const Value: string): Integer;
var
  I: Integer; // loops thru string
  X: Integer; // stores interim results
begin
  Result := 0;
  for I := 1 to Length(Value) do
  begin
    Result := (Result shl 4) + Ord(Value[I]);
    X := Result and $F0000000;
    if (X <> 0) then
      Result := Result xor (X shr 24);
    Result := Result and (not X);
  end;
end;

{ TTextEqualityComparer }

function TTextEqualityComparer.Equals(const Left, Right: string): Boolean;
begin
  Result := AnsiSameText(Left, Right);
end;

function TTextEqualityComparer.GetHashCode(const Value: string): Integer;
begin
  // Comparison takes place (i.e. Equals gets called) only if hashes are same.
  // So we must ignore case in hash if two strings that differ only in case are
  // to be considered same.
  Result := ElfHash(AnsiLowerCase(Value));
end;

end.

