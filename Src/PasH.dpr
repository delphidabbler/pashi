{
 * PasH.dpr
 *
 * Main project file.
 *
 * v1.0 of 28 May 2005 -  Original version.
 * v1.1 of 04 Jun 2005 -  Fixed minor typo in help display.
 * v1.2 of 02 Nov 2005 -  Exceptions now handled by program and error messages
 *                        displayed. Exceptions were previously crashing
 *                        program.
 * v1.3 of 09 Dec 2005 -  Added new UStdIO and UConsole units.
 *                     -  Changed code that writes to console to use new
 *                        TConsole class. This fixes an obscure bug that was
 *                        crashing program when redirecting standard error to a
 *                        pipe.
 * v2.0 of 10 Mar 2007 -  Added new UConfig, UMain, UParams units.
 *                     -  Removed all main program code (it is now in TMain).
 *                        Project code now only creates, executes and frees
 *                        TMain.
 *                     -  Changed to use long version of compiler directives and
 *                        changed value of some of these and added and deleted
 *                        others.
 * v2.1 of 30 May 2009 -  Changed to use Resources.res instead of Images.res.
 *                     -  Removed UHiliteAttrs unit.
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
 * The Original Code is PasH.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


program PasH;


{$ALIGN 8}
{$APPTYPE CONSOLE}
{$BOOLEVAL OFF}
{$DESCRIPTION 'PasH Pascal Syntax Highlighter'}
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
  IntfHiliter in 'IntfHiliter.pas',
  UCharStack in 'UCharStack.pas',
  UClipboardMgr in 'UClipboardMgr.pas',
  UClipboardStreams in 'UClipboardStreams.pas',
  UConfig in 'UConfig.pas',
  UConsole in 'UConsole.pas',
  UHilitePasLexer in 'UHilitePasLexer.pas',
  UHilitePasParser in 'UHilitePasParser.pas',
  UHTMLUtils in 'UHTMLUtils.pas',
  UMain in 'UMain.pas',
  UParams in 'UParams.pas',
  UStdIO in 'UStdIO.pas',
  UStdIOStreams in 'UStdIOStreams.pas',
  UStrStreamWriter in 'UStrStreamWriter.pas',
  USyntaxHiliters in 'USyntaxHiliters.pas',
  UTextStreamReader in 'UTextStreamReader.pas';

{ Main program code }

begin
  with TMain.Create do
    try
      Execute;
    finally
      Free;
    end;
end.

