{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2025, Peter Johnson (www.delphidabbler.com).
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
  Vcl.Forms,
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
  UOptions in 'UOptions.pas',
  FrOptions.UBase in 'FrOptions.UBase.pas' {BaseOptionsFrame: TFrame},
  FrOptions.UDocType in 'FrOptions.UDocType.pas' {DocTypeOptionsFrame: TFrame},
  FrOptions.UHelper in 'FrOptions.UHelper.pas',
  FrOptions.ULineStyle in 'FrOptions.ULineStyle.pas' {LineStyleOptionsFrame: TFrame},
  FrOptions.UCSS in 'FrOptions.UCSS.pas' {CSSOptionsFrame: TFrame},
  FrOptions.UMisc in 'FrOptions.UMisc.pas' {MiscOptionsFrame: TFrame},
  UVersionInfo in '..\UVersionInfo.pas',
  PJWdwState in 'Imported\PJWdwState.pas',
  UUserGuide in 'UUserGuide.pas';

{$R Resources.res}      // main program resources, including icon
{$R VersionInfo.res}    // version information resource


begin
  Application.Initialize;
  Application.MainFormOnTaskBar := True;
  Application.Title := 'PasHi GUI';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

