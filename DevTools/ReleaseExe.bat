@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing binary release of PasH
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 10 Mar 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

cd ..

set OutFile=Release\dd-pash.zip
del %OutFile%

zip -j -9 %OutFile% Exe\PasH.exe
zip -j -9 %OutFile% Docs\ReadMe.html
zip -j -9 %OutFile% Docs\License.txt

cd DevTools
