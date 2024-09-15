{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2022, Peter Johnson (www.delphidabbler.com).
 *
 * Defines case insensitive and case sensitive string equality comparers.
}


unit UComparers;


interface


uses
  // Delphi
  System.Generics.Defaults;


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


type
  ///  <summary>
  ///  Case senstive string equality comparer.
  ///  </summary>
  TStringEqualityComparer = class(TEqualityComparer<string>,
    IEqualityComparer<string>
  )
  public
    ///  <summary>Checks if two strings are equal, taking account of case.
    ///  </summary>
    function Equals(const Left, Right: string): Boolean; override;
    ///  <summary>Gets hash of given string.</summary>
    function GetHashCode(const Value: string): Integer; override;
  end;

type
  ///  <summary>
  ///  Case sensitive character comparer.
  ///  </summary>
  TCharEqualityComparer = class(TEqualityComparer<Char>,
    IEqualityComparer<Char>)
  public
    ///  <summary>Checks if two characters are equal, ignoring case
    ///  </summary>
    function Equals(const Left, Right: Char): Boolean; override;
    ///  <summary>Gets hash of given character.</summary>
    function GetHashCode(const Value: Char): Integer; override;
  end;

type
  // <summary>Case insensitive string comparer.</summary>
  TTextComparer = class(TComparer<string>, IComparer<string>)
  public
    function Compare(const Left, Right: string): Integer; override;
  end;


implementation


uses
  // Delphi
  System.SysUtils;


{$IFOPT R+}
  {$DEFINE RANGEON}
  {$R-}
{$ELSE}
  {$UNDEF RANGEON}
{$ENDIF}
///  <summary>String hash function.</summary>
///  <remarks>Sourced from https://www.scalabium.com/faq/dct0136.htm. Relies
///  upon the hash overflowing and reseting to 0, so causes range check error.
///  </remarks>
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
{$IFDEF RANGEON}
  {$R+}
  {$UNDEF RANGEON}
{$ENDIF}

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

{ TStringEqualityComparer }

function TStringEqualityComparer.Equals(const Left, Right: string): Boolean;
begin
  Result := AnsiSameStr(Left, Right);
end;

function TStringEqualityComparer.GetHashCode(const Value: string): Integer;
begin
  Result := ElfHash(Value);
end;

{ TCharEqualityComparer }

function TCharEqualityComparer.Equals(const Left, Right: Char): Boolean;
begin
  Result := Left = Right;
end;

function TCharEqualityComparer.GetHashCode(const Value: Char): Integer;
begin
  Result := Integer(Value);
end;

{ TTextComparer }

function TTextComparer.Compare(const Left, Right: string): Integer;
begin
  Result := AnsiCompareText(Left, Right);
end;

end.

