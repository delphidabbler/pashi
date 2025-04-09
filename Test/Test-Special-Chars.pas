// This file is used to test the handling of "special" characters
// It contains some non-ASCII, non-ANSI characters in both strings and
// identifiers.
// It must be saved in a format that supports the characters.
function Σ(const A: array of Double): Extended;
var
  I: Integer;
begin
  Result := 0.0;
  for I := 0 to Pred(Length(A)) do
    Result := Result + A[I];
end;

procedure WriteSpecial;
begin
  WriteLn('∫integral ۩ ßar ④② 56‰');
end;
