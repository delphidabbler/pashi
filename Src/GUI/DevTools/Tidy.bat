@rem ---------------------------------------------------------------------------
@rem Script used to delete temp and backup source files of PasHGUI
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006-2010
@rem
@rem $Rev$
@rem $Date$
@rem
@rem Switches:
@rem   no switch - delete temp source files
@rem ---------------------------------------------------------------------------

@echo off
set SrcDir=..\Src
set BinDir=..\Bin
set ExeDir=..\Exe

if "%1" == "history" goto del_history
if "%1" == "bin" goto del_binary

echo Deleting *.~*
del /Q %SrcDir%\*.~*
del /Q %SrcDir%\Resources\*.~*
echo Deleting *.ddp
del /Q %SrcDir%\*.ddp
del /Q %SrcDir%\Resources\*.ddp
goto end

:del_history
echo Deleting History files
del /Q %SrcDir%\__history\*.*
rmdir %SrcDir%\__history
del /Q %SrcDir%\Resources\__history\*.*
rmdir %SrcDir%\Resources\__history
goto end

:del_binary
echo Deleting Binary files
del /Q ..\Bin\*.*
del /Q ..\Exe\*.*
del /Q ..\Release\*.*
goto end

:end

echo Done.
