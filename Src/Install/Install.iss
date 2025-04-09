;===============================================================================
; This Source Code Form is subject to the terms of the Mozilla Public License,
; v. 2.0. If a copy of the MPL was not distributed with this file, You can
; obtain one at http://mozilla.org/MPL/2.0/
;
; Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
;
; PasHi install file generation script for use with Inno Setup 5 Unicode.
;===============================================================================


; The following defines use these macros that are predefined by ISPP:
;   SourcePath - path where this script is located
;   GetStringFileInfo - gets requested version info string from an executable
; 
; The following defines, which must be defined on the command line using the
; /D option:
;   PasHiShortName - short name of PasHi project. Exe file will be named by
;     appending ".exe"
;   PasHiGUIShortName - short name of PasHiGUI project. Exe file will be named 
;     by appending ".exe"
;   AppVersion - version number of the application (must contain only digits,
;     e.g. 1.2.3.4).
;   AppVersionSuffix - any suffix to the application version number (must start)
;     with "-" , e.g. "-beta.1"
;   SetupOutDir - setup program output directory relative to project root
;   SetupFileName - name of setup file to be created (without path)
;   ExeInDir - directory containing compiled .exe file relative to project root
;   DocsInDir - directory containing documentation relative to project root
;   ConfigInDir - directory containing config files relative to project root

#define ExeFile PasHiShortName + ".exe"
#define GUIExeFile PasHiGUIShortName + ".exe"
#define LicenseFile "License.rtf"
#define LicenseTextFile "LICENSE.md"
#define ReadmeFile "ReadMe.txt"
#define UserGuide "UserGuide.html"
#define InstUninstDir "Uninst"
#define SrcRootPath SourcePath + "..\..\"
#define OutDir SrcRootPath + SetupOutDir
#define SrcExePath SrcRootPath + ExeInDir + "\"
#define SrcDocsPath SrcRootPath + DocsInDir + "\"
#define SrcConfigPath SrcRootPath + ConfigInDir + "\"
#define ExeProg SrcExePath + ExeFile
#define Company "DelphiDabbler.com"
#define AppPublisher "DelphiDabbler"
#define AppName "PasHi"
#define Copyright GetStringFileInfo(ExeProg, LEGAL_COPYRIGHT)
#define WebAddress "delphidabbler.com"
#define WebURL "https://" + WebAddress + "/"
#define AppURL WebURL + "/software/pashi"
#define FullAppVersion AppVersion + AppVersionSuffix
#define AppDataDir "{commonappdata}" + "\" + AppPublisher + "\" + AppName;


[Setup]
AppID={{77FD2E34-0030-4171-BE00-7CA1CD5AF4DD}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppPublisher} {#AppName} {#FullAppVersion}
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
OutputBaseFilename={#SetupFileName}
VersionInfoVersion={#AppVersion}
VersionInfoTextVersion={#AppVersion}
VersionInfoProductVersion={#AppVersion}
VersionInfoProductTextVersion={#FullAppVersion}
VersionInfoCompany={#Company}
VersionInfoDescription=Installer for {#AppName}
VersionInfoCopyright={#Copyright}
MinVersion=6.1sp1
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
Name: modifypath; Description: &Add PasHi directory to the system path for all users;
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
