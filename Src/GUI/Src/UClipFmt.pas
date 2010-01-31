{
 * UClipFmt.pas
 *
 * Declares and registers custom Windows clipboard format.
 *
 * v1.0 of 14 Jun 2006 - Original version.
 *
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
 * The Original Code is UClipFmt.pas from PasHGUI.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2006 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UClipFmt;


interface


uses
  // Delphi
  ActiveX;


var
  // Name of clipboard format that stores file names as ANSI text
  CF_FILENAME: TClipFormat;


implementation


uses
  // Delphi
  Windows, ShlObj;


initialization

// Register file name clipboard format
CF_FILENAME := RegisterClipboardFormat(CFSTR_FILENAMEA);


end.

