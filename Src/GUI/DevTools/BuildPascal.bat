@rem ---------------------------------------------------------------------------
@rem Script used to build PasHGUI's Pascal files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006-2010
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off
echo BUILDING PASCAL PROJECT
cd ..\Src
call Build.bat pas
cd ..\DevTools
