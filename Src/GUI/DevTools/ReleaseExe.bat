@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing the binary release of PasHGUI
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006-2010
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

set RelDir=..\..\..\Release
set ZipFile=%RelDir%\dd-pashgui.zip
set ExeDir=..\..\..\Exe
set DocsDir=..\..\..\Docs\GUI

if not exist %RelDir% mkdir %RelDir%
if exist %ZipFile% del %ZipFile%

zip -j -9 %ZipFile% %ExeDir%\PasHGUI.exe
zip -j -9 %ZipFile% %DocsDir%\ReadMe.txt
zip -j -9 %ZipFile% %DocsDir%\License.txt
