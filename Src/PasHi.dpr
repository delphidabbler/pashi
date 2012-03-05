{
 * PasHi.dpr
 *
 * Main project file.
 *
 * $Rev$
 * $Date$
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
 * The Original Code is PasHi.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


program PasHi;


{$ALIGN 8}
{$APPTYPE CONSOLE}
{$BOOLEVAL OFF}
{$DESCRIPTION 'PasHi Pascal Syntax Highlighter'}
{$EXTENDEDSYNTAX ON}
{$HINTS ON}
{$IMAGEBASE $00400000}
{$IOCHECKS ON}
{$LONGSTRINGS ON}
{$MAXSTACKSIZE $00100000}
{$MINSTACKSIZE $00004000}
{$OPENSTRINGS ON}
{$OPTIMIZATION ON}
{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
{$SAFEDIVIDE OFF}
{$TYPEDADDRESS ON}
{$TYPEINFO OFF}
{$WARNINGS ON}
{$WRITEABLECONST OFF}

{$RESOURCE Resources.res}   // contains icon and manifest
{$RESOURCE VerInfo.res}     // contains version info

uses
  IntfCommon in 'IntfCommon.pas',
  Hiliter.UGlobals in 'Hiliter.UGlobals.pas',
  UCharStack in 'UCharStack.pas',
  UClipboardMgr in 'UClipboardMgr.pas',
  UConfig in 'UConfig.pas',
  UConsole in 'UConsole.pas',
  Hiliter.UPasLexer in 'Hiliter.UPasLexer.pas',
  Hiliter.UPasParser in 'Hiliter.UPasParser.pas',
  UHTMLUtils in 'UHTMLUtils.pas',
  UMain in 'UMain.pas',
  UParams in 'UParams.pas',
  UStdIO in 'UStdIO.pas',
  Hiliter.UHiliters in 'Hiliter.UHiliters.pas',
  UStringReader in 'UStringReader.pas',
  UConsts in 'UConsts.pas',
  UComparers in 'UComparers.pas',
  IO.UTypes in 'IO.UTypes.pas',
  IO.Readers.UStdIn in 'IO.Readers.UStdIn.pas',
  IO.Readers.UClipboard in 'IO.Readers.UClipboard.pas',
  IO.Readers.UFactory in 'IO.Readers.UFactory.pas',
  IO.Writers.UStdOut in 'IO.Writers.UStdOut.pas',
  IO.Writers.UClipboard in 'IO.Writers.UClipboard.pas',
  IO.Writers.UFactory in 'IO.Writers.UFactory.pas';

{ Main program code }

begin
  with TMain.Create do
    try
      Execute;
    finally
      Free;
    end;
end.

