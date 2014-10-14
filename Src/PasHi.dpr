{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2005-2012, Peter Johnson (www.delphidabbler.com).
 *
 * Main project file.
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
  Hiliter.UGlobals in 'Hiliter.UGlobals.pas',
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
  IO.Writers.UFactory in 'IO.Writers.UFactory.pas',
  IO.Readers.UFiles in 'IO.Readers.UFiles.pas',
  IO.Writers.UFile in 'IO.Writers.UFile.pas',
  IO.UHelper in 'IO.UHelper.pas',
  Renderers.UFactory in 'Renderers.UFactory.pas',
  UConfigFiles in 'UConfigFiles.pas',
  USpecialFolders in 'USpecialFolders.pas',
  USourceProcessor in 'USourceProcessor.pas',
  Renderers.UCharSetTag in 'Renderers.UCharSetTag.pas',
  Renderers.UTypes in 'Renderers.UTypes.pas',
  Renderers.UDocType in 'Renderers.UDocType.pas',
  Renderers.UProcInst in 'Renderers.UProcInst.pas',
  Renderers.URootTag in 'Renderers.URootTag.pas',
  Renderers.UBranding in 'Renderers.UBranding.pas',
  Renderers.USourceCode in 'Renderers.USourceCode.pas',
  Renderers.UTitleTag in 'Renderers.UTitleTag.pas',
  Renderers.UStyles in 'Renderers.UStyles.pas',
  Renderers.UDocument in 'Renderers.UDocument.pas';

{ Main program code }

begin
  with TMain.Create do
    try
      Execute;
    finally
      Free;
    end;
end.

