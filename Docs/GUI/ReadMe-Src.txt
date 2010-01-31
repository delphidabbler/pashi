
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
DELPHIDABBLER PASHGUI SOURCE CODE README
________________________________________________________________________________

Source code for the current version of DelphiDabbler PASHGUI is always
available from http://www.delphidabbler.com/software?id=pashgui.

PASHGUI's source code is provided in a zip file, dd-pashgui-src.zip. This file
includes all PASHGUI's original source code. Files should be extracted from the
zip file and the directory structure should be preserved.

The directory structure is:

.            : Root contains documentation
  Bin        : Binary resource and type library files (*1)
  Src        : Pascal and other source code + batch file controlling build  (*2)
    Resources: Contains subfolders of assets compiled into resources

  Notes:
    (*1) - See below for details of how to recompile these files
    (*2) - Build batch file described below

The Delphi 2006 VCL is required to compile PASHGUI.

The program also requires two binary resource files (provided):

1) VersionInfo.res - the program's version information.
2) Resources.res - the program's other resources, including the icon.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Build Tools
________________________________________________________________________________

A batch file - Build.bat - is provided in the Src directory. It can be used to
automate either a full build or partial builds. It must be called with a command
line switch. Switches are:

+ all   - Builds everything.
+ res   - Builds binary resource files only. Requires VIEd and BRCC32. Creates
          VersionInfo.res and Resources.res from VersionInfo.vi and Resources.rc
          respectively.
+ pas   - Builds the Delphi Pascal project. Requires DCC32.

The programs required by the build process are:

+ VIEd    - DelphiDabbler Version Information Editor, available from
            www.delphidabbler.com
+ BRCC32  - Borland Resource Compiler, supplied with Delphi 2006.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Licensing
________________________________________________________________________________

Please see SourceCodeLicenses.txt for information about source code licenses.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
