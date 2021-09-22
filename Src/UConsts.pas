{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2021, Peter Johnson (www.delphidabbler.com).
 *
 * Defines various useful constants.
}


unit UConsts;


interface


const
  LF          = #$000A;
  CR          = #$000D;
  CRLF        = CR + LF;
  EOL         = UnicodeString(sLineBreak);

  DBLQUOTE   = #$0022;
  APOSTROPHE = #$0027;
  AMPERSAND  = #$0026;
  GT         = #$003E;
  LT         = #$003C;



implementation

end.

