;===============================================================================
; This Source Code Form is subject to the terms of the Mozilla Public License,
; v. 2.0. If a copy of the MPL was not distributed with this file, You can
; obtain one at http://mozilla.org/MPL/2.0/
;
; Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
;
; $Rev$
; $Date$
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
#define LicenseFile "License.txt"
#define ReadmeFile "ReadMe.html"
#define InstUninstDir "Uninst"
#define OutDir SourcePath + "..\..\Exe"
#define SrcExePath SourcePath + "..\..\Exe\"
#define SrcDocsPath SourcePath + "..\..\Docs\"
#define SrcConfigPath SourcePath + "..\..\Config\"
#define ExeProg SrcExePath + ExeFile
#define Company "DelphiDabbler.com"
#define AppPublisher "DelphiDabbler"
#define AppName "PasHi"
#define AppVersion DeleteToVerStart(GetFileProductVersion(ExeProg))
#define Copyright GetStringFileInfo(ExeProg, LEGAL_COPYRIGHT)
#define WebAddress "www.delphidabbler.com"
#define WebURL "http://" + WebAddress + "/"
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
DefaultGroupName={#AppName}
AllowNoIcons=false
LicenseFile={#SrcDocsPath}{#LicenseFile}
Compression=lzma/ultra
SolidCompression=true
InternalCompressLevel=ultra
OutputDir={#OutDir}
OutputBaseFilename={#AppName}-Setup-{#AppVersion}
; Special VersionInfoVersion defined for pre-release versions only
; revert to commened out line in release version
;VersionInfoVersion={#AppVersion}
VersionInfoVersion=1.98.1
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

[Files]
Source: {#SrcExePath}{#ExeFile}; DestDir: {app}; Flags: uninsrestartdelete replacesameversion
Source: {#SrcExePath}PasHiGUI.exe; DestDir: {app}; Flags: uninsrestartdelete replacesameversion
Source: {#SrcDocsPath}{#LicenseFile}; DestDir: {app}; Flags: ignoreversion
Source: {#SrcDocsPath}{#ReadmeFile}; DestDir: {app}; Flags: ignoreversion
Source: {#SrcConfigPath}version; DestDir: {#AppDataDir}; Flags: ignoreversion
Source: {#SrcConfigPath}config-template; DestDir: {#AppDataDir}; Flags: ignoreversion

[Icons]
Name: {group}\{#AppName}; Filename: {app}\{#ExeFile}
Name: {group}\{cm:UninstallProgram,{#AppName}}; Filename: {uninstallexe}

[Run]
Filename: {app}\{#ReadMeFile}; Description: "View the README file"; Flags: nowait postinstall skipifsilent shellexec

[Dirs]
Name: {#AppDataDir};

[Messages]
; Brand installer
BeveledLabel={#Company}

[UninstallDelete]
; Deletes common app config etc. directory & files
; (per-user directory & files are left in place)
Type: filesandordirs; Name: {#AppDataDir}
