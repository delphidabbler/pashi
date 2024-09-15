:: Deploy script for PasHi.
::
:: This script creates a release of PasHi as a zip file that contains a setup
:: and read-me file.
::
:: The script has the following dependencies:
::
::   1) MSBuild & Delphi.
::   2) InfoZip's zip.exe. See https://delphidabbler.com/extras/info-zip
::   3) Inno Setup v5.6.1 or later Unicode version (not v6). See
::      https://www.innosetup.com/
::   4) DelphiDabbler Version Information Editor v2.15.1 or later. See
::      https://delphidabbler.com/software/vied
::   5) PowerShell.
::
:: To use the script:
::
::   1) Start the Embarcadero RAD Studio Command Prompt to set the required
::      environment variables for MSBuild.
::   2) Set the ZipRoot environment variable to the directory where zip.exe is
::      installed.
::   3) Set the VIEdRoot environment variable to the directory where VIEd.exe is
::      installed.
::   4) Set the InnoSetupRoot environment variable to the directoty where Inno
::      Setup is installed.
::   5) Change directory to that where this script is located.
::   6) Run the script by entering Deploy with no parameters.
::
:: The script does the following:
::
::   1) Builds the PasHi and PasHiGUI executables using MSBuild, Delphi and
::      VIEd.
::   2) Uses PowerShell to extract the release version from version information
::      embedded in the PasHi executable. This is used to set the version of
::      the setup program and to name the setup program and zip file.
::   3) Builds the setup file using Inno Setup.
::   4) Creates the release zip file using Zip.exe.


@echo off

echo ======================
echo Creating PasHi Release
echo ======================

:: Check for required environment variables

if "%ZipRoot%"=="" goto envvarerror
if "%VIEdRoot%"=="" goto envvarerror
if "%InnoSetupRoot%"=="" goto envvarerror

:: Set other variables that don't depend on version

set PasHiExeStub=PasHi
set PasHiGUIExeStub=PasHiGUI
set BuildRoot=_build
set Win32ExeDir=%BuildRoot%\Win32\Release\exe
set ReleaseDir=%BuildRoot%\release
set TempDir=%ReleaseDir%\~temp
set PasHiSrcDir=Src
set PasHiGUISrcDir=%PasHiSrcDir%\GUI
set InstallSrcDir=%PasHiSrcDir%\Install
set DocsDir=Docs
set ConfigDir=Config
set ReadMeFile=%DocsDir%\README.txt
set ISCC="%InnoSetupRoot%\ISCC.exe"

:: Make a clean directory structure

if exist %BuildRoot% rmdir /S /Q %BuildRoot%
mkdir %ReleaseDir%
mkdir %TempDir%

:: Build Pascal

echo.
echo -------
echo --- Building executable programs
echo -------
echo.

setlocal

cd %PasHiSrcDir%

msbuild %PasHiExeStub%.dproj /p:config=Release /p:platform=Win32

endlocal

setlocal

cd %PasHiGUISrcDir%

msbuild %PasHiGUIExeStub%.dproj /p:config=Release /p:platform=Win32

endlocal

:: Get product version and set variables that depend on version

echo.
echo -------
echo --- Extracting version information
echo -------
echo.

PowerShell(Get-Command %Win32ExeDir%\%PasHiExeStub%.exe).FileVersionInfo.ProductVersion > "%TempDir%\~version"
set /p Version= < "%TempDir%\~version"

set SetupFileName=PasHi-Setup-%Version%
set ZipFile=%ReleaseDir%\pashi-exe-%Version%.zip

:: Split Version into prefix and suffix with "-" delimiter: suffix may be empty

for /f "tokens=1,2 delims=-" %%a in ("%Version%") do (
  :: prefix and suffix required for Inno Setup
  set VersionPrefix=%%a
  set VersionSuffix=%%b
)
if not [%VersionSuffix%] == [] (
  :: prepend "-" to suffic when suffix not empty
  set VersionSuffix=-%VersionSuffix%
)

echo Release version number: %Version%

:: Build Setup

echo.
echo -------
echo --- Building setup program
echo -------
echo.

setlocal

cd %InstallSrcDir%

%ISCC% /DPasHiShortName=%PasHiExeStub% /DPasHiGUIShortName=%PasHiGUIExeStub% /DAppVersion=%VersionPrefix% /DAppVersionSuffix=%VersionSuffix% /DSetupOutDir=%TempDir% /DSetupFileName=%SetupFileName% /DExeInDir=%Win32ExeDir% /DDocsInDir=%DocsDir% /DConfigInDir=%ConfigDir% Install.iss

endlocal

:: Create zip files

echo.
echo -------
echo --- Creating zip files
echo -------
echo.

%ZipRoot%\zip.exe -j -9 %ZipFile% %TempDir%\%SetupFileName%.exe
%ZipRoot%\zip.exe -j -9 %ZipFile% %ReadMeFile%

:: Tidy up

echo.
echo -------
echo --- Tidying up
echo -------
echo.

echo Deleting %TempDir%

if exist %TempDir% rmdir /S /Q %TempDir%

:: Done

echo.
echo -------
echo --- Build completed
echo -------

goto end

:: Error messages

:envvarerror
echo.
echo ***ERROR: ZipRoot, VIEdRoot or InnoSetupRoot environment variable not set
echo.
goto end

:: End

:end
