@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code of PasH
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 10 Mar 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

cd ..

set OutFile=Release\dd-pash-src.zip
set SrcDir=Src
set BinDir=Bin
set DocsDir=Docs

del %OutFile%

zip -r -9 %OutFile% %SrcDir%
zip %OutFile% -d %SrcDir%\PasH.dsk
zip -r -9 %OutFile% %BinDir%\*.res
zip -j -9 %OutFile% %DocsDir%\ReadMe-Src.txt
zip -j -9 %OutFile% %DocsDir%\SourceCodeLicenses.txt
zip -j -9 %OutFile% %DocsDir%\MPL.txt

cd DevTools
