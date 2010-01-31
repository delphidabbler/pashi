@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code release of PasHGUI
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006-2010
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off
cd ..

set OutFile=Release\dd-pashgui-src.zip
del %OutFile%

zip -9 -D %OutFile% Src\*.*
zip -9 -D %OutFile% Src\Resources\*.*
zip -9 %OutFile% Bin\*.res
zip -j -9 %OutFile% Docs\SourcecodeLicenses.txt Docs\ReadMe-Src.txt Docs\MPL.txt
zip %OutFile% -d Src\PasHGUI.dsk
zip %OutFile% -d Src\PasHGUI.bdsproj.local
zip %OutFile% -d Src\PasHGUI.identcache

cd DevTools
