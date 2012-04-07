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
 * Main project file
}


program PasHiGUI;


{$ALIGN 8}
{$APPTYPE GUI}
{$BOOLEVAL ON}
{$DESCRIPTION 'Pascal Syntax Hughlighter GUI Front End'}
{$EXTENDEDSYNTAX ON}
{$HINTS ON}
{$IOCHECKS ON}
{$LONGSTRINGS ON}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
{$TYPEDADDRESS ON}
{$WARNINGS ON}
{$WRITEABLECONST OFF}


uses
  Forms,
  FmMain in 'FmMain.pas' {MainForm},
  IntfDropDataHandler in 'IntfDropDataHandler.pas',
  IntfUIHandlers in 'IntfUIHandlers.pas',
  UClipFmt in 'UClipFmt.pas',
  UConsoleApp in 'UConsoleApp.pas',
  UDataObjectAdapter in 'UDataObjectAdapter.pas',
  UDocument in 'UDocument.pas',
  UDropTarget in 'UDropTarget.pas',
  UInputData in 'UInputData.pas',
  UNulWBContainer in 'UNulWBContainer.pas',
  UOutputData in 'UOutputData.pas',
  UPasHi in 'UPasHi.pas',
  UPipe in 'UPipe.pas',
  UUtils in 'UUtils.pas',
  UWBContainer in 'UWBContainer.pas',
  UConfigFiles in '..\UConfigFiles.pas',
  UGUIConfigFiles in 'UGUIConfigFiles.pas',
  IO.UHelper in '..\IO.UHelper.pas',
  UComparers in '..\UComparers.pas',
  USpecialFolders in '..\USpecialFolders.pas',
  UOptions in 'UOptions.pas';

{$R Resources.res}      // main program resources, including icon
{$R VersionInfo.res}    // version information resource


begin
  Application.Initialize;
  Application.Title := 'PasH GUI';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

