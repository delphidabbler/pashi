;===============================================================================
; This Source Code Form is subject to the terms of the Mozilla Public License,
; v. 2.0. If a copy of the MPL was not distributed with this file, You can
; obtain one at http://mozilla.org/MPL/2.0/
;
; Copyright (C) 2012-2022, Peter Johnson (www.delphidabbler.com).
;
; PasHi install file generation script for use with Inno Setup 5 Unicode.
;===============================================================================


; Deletes "Release " from beginning of S
#define DeleteToVerStart(str S) \
  /* assumes S begins with "Release " followed by version as x.x.x */ \
  Local[0] = Copy(S, Len("Release ") + 1, 99), \
  Local[0]

; The following defines use these macros that are predefined by ISPP:
;   SourcePath - path where this script is located
;   GetStringFileInfo - gets requested version info string from an executable
;   GetFileProductVersion - gets product version info string from an executable

#define ExeFile "PasHi.exe"
#define GUIExeFile = "PasHiGUI.exe"
#define LicenseFile "License.rtf"
#define LicenseTextFile "LICENSE.md"
#define ReadmeFile "ReadMe.txt"
#define UserGuide "UserGuide.html"
#define InstUninstDir "Uninst"
#define SrcRootPath SourcePath + "..\..\"
#define BuildPath SrcRootPath + "Build\"
#define OutDir BuildPath + "Exe"
#define SrcExePath BuildPath + "Exe\"
#define SrcDocsPath SrcRootPath + "Docs\"
#define SrcConfigPath SrcRootPath + "Config\"
#define ExeProg SrcExePath + ExeFile
#define Company "DelphiDabbler.com"
#define AppPublisher "DelphiDabbler"
#define AppName "PasHi"
#define AppVersion DeleteToVerStart(GetFileProductVersion(ExeProg))
#define Copyright GetStringFileInfo(ExeProg, LEGAL_COPYRIGHT)
#define WebAddress "delphidabbler.com"
#define WebURL "https://" + WebAddress + "/"
#define AppURL WebURL + "/software/pashi"
#define AppDataDir "{commonappdata}" + "\" + AppPublisher + "\" + AppName;


[Setup]
AppID={{77FD2E34-0030-4171-BE00-7CA1CD5AF4DD}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppPublisher} {#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#WebURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AppReadmeFile={app}\{#ReadmeFile}
AppCopyright={#Copyright} ({#WebAddress})
AppComments=
AppContact=
DefaultDirName={pf}\{#AppPublisher}\{#AppName}
DefaultGroupName={#AppPublisher} {#AppName}
AllowNoIcons=false
LicenseFile={#SrcDocsPath}{#LicenseFile}
Compression=lzma/ultra
SolidCompression=true
InternalCompressLevel=ultra
OutputDir={#OutDir}
OutputBaseFilename={#AppName}-Setup-{#AppVersion}
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#Company}
VersionInfoDescription=Installer for {#AppName}
VersionInfoTextVersion={#AppVersion}
VersionInfoCopyright={#Copyright}
MinVersion=0,5.0.2195
TimeStampsInUTC=true
ShowLanguageDialog=no
UninstallFilesDir={app}\{#InstUninstDir}
UninstallDisplayIcon={app}\{#ExeFile}
PrivilegesRequired=admin
MergeDuplicateFiles=false
UserInfoPage=false
ChangesEnvironment=true

[Files]
Source: {#SrcExePath}{#ExeFile}; DestDir: {app}; Flags: uninsrestartdelete replacesameversion
Source: {#SrcExePath}{#GUIExeFile}; DestDir: {app}; Tasks: gui; Flags: uninsrestartdelete replacesameversion
Source: {#SrcRootPath}{#LicenseTextFile}; DestDir: {app}; Flags: ignoreversion
Source: {#SrcDocsPath}{#ReadmeFile}; DestDir: {app}; Flags: ignoreversion
Source: {#SrcDocsPath}{#UserGuide}; DestDir: {app}; Flags: ignoreversion
Source: {#SrcConfigPath}version; DestDir: {#AppDataDir}; Flags: ignoreversion
Source: {#SrcConfigPath}config-template; DestDir: {#AppDataDir}; Flags: ignoreversion
Source: {#SrcConfigPath}config-v1; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}v1-default.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}classic.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}delphi4.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}delphi7.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}delphi2010.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}ocean.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}twilight.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}visual-studio.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}notebook.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}null.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion
Source: {#SrcConfigPath}mono.css; DestDir: {#AppDataDir}; Tasks: samples; Flags: ignoreversion

[Icons]
Name: {group}\Read Me File; Filename: {app}\{#ReadmeFile}
Name: {group}\Run PasHiGUI; Tasks: gui; Filename: {app}\{#GUIExeFile}
Name: {group}\{cm:UninstallProgram,{#AppName}}; Filename: {uninstallexe}

[Tasks]
Name: modifypath; Description: &Add PasHi's directory to the system path for all users;
Name: samples; Description: Install &sample style sheets and config file templates;
Name: gui; Description: Install &GUI front end program, PasHiGUI;

[Run]
Filename: {app}\{#ReadMeFile}; Description: "View the README file"; Flags: nowait postinstall skipifsilent shellexec
Filename: {app}\PasHiGUI.exe; Description: "Run PasHiGUI"; Tasks: gui; Flags: nowait postinstall skipifsilent unchecked

[Dirs]
Name: {#AppDataDir};

[Messages]
; Brand installer
BeveledLabel={#Company}

[UninstallDelete]
; Deletes common app config etc. directory & files
; (per-user directory & files are left in place)
Type: filesandordirs; Name: {#AppDataDir}

[Code]

const
  // Name of "add to path" task per [Tasks] section
  ModifyPathTask = 'modifypath';

#include "UpdatePath.ps"
#include "Events.ps"
