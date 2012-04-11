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
  // Name of clipboard format that stores file names as ANSI text
  CF_FILENAMEA: TClipFormat;
  CF_FILENAMEW: TClipFormat;


implementation


uses
  // Delphi
  Windows, ShlObj;


initialization

// Register file name clipboard formats
CF_FILENAMEA := RegisterClipboardFormat(CFSTR_FILENAMEA);
CF_FILENAMEW := RegisterClipboardFormat(CFSTR_FILENAMEW);


end.

