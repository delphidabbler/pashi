# PasHi Build Instructions

## Introduction

_PasHi_ and _PasHiGUI_ are written in Object Pascal and are targeted at Delphi 12.2.

Development, debugging and testing of the executable program can take place entirely within the IDE providing some prerequisites have been met. However releases _must_ be built using the `Deploy.bat` script.

## Prerequisites

### 3rd Party Libraries

No 3rd party libraries have to be installed. The only library that is required (by _PasHiGUI_) is included with the source code in the  `Src\GUI\Imported` directory. No special action needs to be taken to install the library code.

### Tools

The following tools are required to build the project.

Tools marked with an asterisk are required when compiling from the IDE: compiles will fail if they are not installed and configured.

| Tools | Notes |
|-------|-------|
| Delphi 12.2 | Earlier and later Delphi compilers may be suitable, but none have been tested. |
| MSBuild | This tool is installed with Delphi. Used directly by `Deploy.bat` to build _PasHi_ releases. |
| BRCC32 * | This tool is installed with Delphi. Used in pre-build events to create `.res` files from custom `.rc` files. |
| Version Information Editor * † | v2.15.1 or later is required. Used in pre-build events to create temporary version information resource source files from `.vi` files. [Download here](https://github.com/delphidabbler/vied/releases). |
| Inno Setup | v5.6.1 or later Unicode version (not v6). Used by `Deploy.bat` to create the installer. [Download here](https://www.innosetup.com/). |
| InfoZip's Zip tool | Used by `Deploy.bat` to create the release zip file. [Download here](https://delphidabbler.com/extras/info-zip). |
| PowerShell | Used by `Deploy.bat` to grab version information from the compiled `.exe` file. |

### Environment Variables

The following environment variables must be set to build the project.

Environment variables marked with an asterisk are required when compiling from the IDE: compiles will fail if they are not set correctly. Such variables can be set using Delphi's _Tools | Options_ menu, going to the _IDE | Environment Variables_ page then creating the variable in the _User System Overrides_ section.

All environment variables are required when creating releases using `Deploy.bat`.

| Environment Variables | Notes |
|-----------------------|-------|
| MSBuild specific variables | The `rsvars.bat` script in the `Bin` sub-directory of the Delphi installation directory sets these variables to the required values. |
| `ZipRoot` | Set this to the directory where the InfoZip Zip tool is installed. |
| `VIEdRoot` * | Set this to the directory where Version Information Editor is installed (the `DelphiDabbler\VIEd` subdirectory of the 32 bit program files directory, by default). |
| `InnoSetupRoot` | Set this to the directory where the Unicode version of Inno Setup 5 is installed. |

You can configure the environment using a batch file similar to the following:

```batch
:: set path to Delphi 12 installation (change directory if not using Delphi 12)
set DELPHIROOT=C:\Program Files (x86)\Embarcadero\Studio\23.0

:: set environment variables required by MSBuild
call "%DELPHIROOT%\Bin\rsvars.bat"

:: set install path of tools (change as required)
set ZipRoot=C:\Tools
set VIEdRoot=C:\Program Files (x86)\DelphiDabbler\VIEd
set InnoSetup=C:\Program Files (x86)\Inno Setup 5
```

## Source Code

Download the _PasHi_ source code from the [`delphidabbler/pashi`](https://github.com/delphidabbler/pashi) GitHub repository. You can either clone it using Git or download a zip file containing the source.

After obtaining the source code you should have the following directory structure:
</p>

```text
/-+                         - miscellaneous files including Deploy.bat
  |
  +-- .git                  - present only if using Git
  |
  +-- Config                - sample configuration files
  |
  +-- Docs                  - documentation
  |
  +-- Src                   - source code for PasHi & shared code
  |   |
  |   +-- Assets            - various files to include in PasHi's resources
  |   |
  |   +-- GUI               - source code for PasHiGUI
  |   |   |
  |   |   +-- Assets        - various files to include in PasHiGUI's resources
  |   |   |
  |   |   +-- Imported      - 3rd party code
  |   |
  |   +-- Install           - Install script and associated Pascal script files 
  |
  +-- Test                  - various .pas files for testing PasHi
```

## Compiling

### From The Delphi IDE

Simply open the `PasHi.groupproj` file in Delphi and build all the included projects using the _Projects | Build All Projects_ menu item. Providing the [prerequisites](#prerequisites) have been met, the program should compile without problems.

All compiler output is placed in a `_build` directory. This directory is ignored by Git. You can build either the Debug or Release build configurations, or both. Debug is the default. Compiling both configurations results in the following directory tree being created:

```text
/-+                         - miscellaneous files including Deploy.bat
  |
  +-- .git                  - present only if using Git
  |
  +-- _build                - top level build directory
  |   |
  |   +-- Win32             - directory for Win 32 builds (the only target OS)
  |       |
  |       +-- Debug         - directory containing debug binaries
  |       |   |
  |       |   +-- bin       - contains PasHi's binary debug files
  |       |   |   |
  |       |   |   +-- GUI   - contains PasHiGUI's binary debug files
  |       |   |
  |       |   +-- exe       - contains the debug executable files
  |       |
  |       +-- Release       - directory containing release binaries
  |           |
  |           +-- bin       - contains PasHi's binary release files
  |           |   |
  |           |   +-- GUI   - contains PasHiGUI's binary release files
  |           |
  |           +-- exe       - contains the release executable files
  |
  +-- Config                - sample configuration files
  ⁞
```

You can now hack away as you wish.

### Creating A Release

To create a release ensure that all the [tools](#tools) have been installed. Then:

1. Open a terminal.
2. Run any configuration script you have created, or set the [environment variables](#environment-variables) manually.
3. Change directory into the repository root.
4. Run `Deploy.bat` without any parameters.

`Deploy.bat` will:

1. Build the _PasHi_ and _PasHiGUI_ executables using the Release build configuration.
2. Extract the release version information from the _PasHi_ executable.
3. Compile the setup program.
4. Create a zip file containing the setup program and some documentation.

The release version information extracted in step 2 is used as the setup program's version number and is embedded in the file names of the setup program and zip file.

The release zip file is placed in the `release` sub-directory of `_build`:

```text
/-+
  ⁞
  +-- _build                - top level build directory
  |   |
  |   +-- release           - contains the release zip file
  |   |
  |   +-- Win32             - directory for Win 32 builds (the only target OS)
  |       |
  |       +-- Release       - directory containing release binaries
  |           |
  |           +-- bin       - contains PasHi's binary release files
  |           |   |
  |           |   +-- GUI   - contains PasHiGUI's binary release files
  |           |
  |           +-- exe       - contains the release executable files
  |
  +-- Config                - sample configuration files
  ⁞
```

> Notice that any pre-existing `_build\Win32\Debug` directory will have been deleted.

### Tidying Up

If you are using Git you can run

```test
git clean -fxd
```

to remove all unwanted files.

> ⚠️ Running the above command will remove the `_build` directory and all its contents, so ensure you copy any wanted files from there beforehand. The command will also remove Delphi's `__history` directory.

## License

If you are planning to re-use or modify any of the code, please see `LICENSE.md` for an overview of the various open source licenses that apply to the _PasHi_ source code.
