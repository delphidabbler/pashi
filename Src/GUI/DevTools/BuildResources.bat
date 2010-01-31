@rem ---------------------------------------------------------------------------
@rem Script used to build PasHGUI's resource files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006-2010
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off
echo BUILDING RESOURCES
setlocal
cd ..
call Build.bat res
endlocal
