{
 * PasHiGUI.dpr
 *
 * Main project file
 *
 * $Rev$
 * $Date$
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
 * The Original Code is PasHiGUI.dpr
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2006-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
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


{%ToDo 'PasHiGUI.todo'}

uses
  Forms,
  FmMain in 'FmMain.pas' {MainForm},
  IntfDropDataHandler in 'IntfDropDataHandler.pas',
  IntfUIHandlers in 'IntfUIHandlers.pas',
  UClipboardWriteStream in 'UClipboardWriteStream.pas',
  UClipFmt in 'UClipFmt.pas',
  UConsoleApp in 'UConsoleApp.pas',
  UDataObjectAdapter in 'UDataObjectAdapter.pas',
  UDocument in 'UDocument.pas',
  UDropTarget in 'UDropTarget.pas',
  UInputData in 'UInputData.pas',
  UNulWBContainer in 'UNulWBContainer.pas',
  UOutputData in 'UOutputData.pas',
  UPasH in 'UPasH.pas',
  UPipe in 'UPipe.pas',
  UUtils in 'UUtils.pas',
  UWBContainer in 'UWBContainer.pas';

{$R Resources.res}      // main program resources, including icon
{$R VersionInfo.res}    // version information resource


begin
  Application.Initialize;
  Application.Title := 'PasH GUI';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

