@rem ---------------------------------------------------------------------------
@rem Script used to build PasH executable from Pascal source and other
@rem binaries.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 10 Mar 2007 - Original version.
@rem ---------------------------------------------------------------------------

@echo off
echo BUILDING PASCAL PROJECT
cd ..\Src
call Build.bat pas
cd ..\DevTools

