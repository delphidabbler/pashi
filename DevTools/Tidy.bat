@rem ---------------------------------------------------------------------------
@rem Script used to delete temp and backup source files in PasH source
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 10 Mar 2007 - Original version.
@rem ---------------------------------------------------------------------------

@echo off
set SrcDir=..\Src
set DocsDir=..\Docs

echo Deleting *.~*
del %SrcDir%\*.~*
del %SrcDir%\Img\*.~*
del %DocsDir%\*.~*

echo Deleting *.ddp
del %SrcDir%\*.ddp

echo Done.
