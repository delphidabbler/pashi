@rem ---------------------------------------------------------------------------
@rem Script used to build PasH resources
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2005-2007
@rem
@rem v1.0 of 28 May 2005 - Original version.
@rem v2.0 of 10 Mar 2007 - Rewrote to call build.bat
@rem ---------------------------------------------------------------------------

@echo off
echo BUILDING RESOURCES
cd ..\Src
call Build.bat res
cd ..\DevTools
