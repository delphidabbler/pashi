{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Declares and registers custom Windows clipboard format.
}


unit UClipFmt;


interface


uses
  // Delphi
  ActiveX;


var
  // Variables that store indentifiers of custom clipboard formats
  CF_FILENAMEA: TClipFormat;  // file name as ANSI text
  CF_FILENAMEW: TClipFormat;  // file name as Unicode text


implementation


uses
  // Delphi
  Windows, ShlObj;


initialization

// Register clipboard formats
CF_FILENAMEA := RegisterClipboardFormat(CFSTR_FILENAMEA);
CF_FILENAMEW := RegisterClipboardFormat(CFSTR_FILENAMEW);


end.

