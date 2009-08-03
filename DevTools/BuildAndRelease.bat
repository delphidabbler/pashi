@rem ---------------------------------------------------------------------------
@rem Script used to build all of PasH and create release zip files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 10 Mar 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

call Tidy.bat
call BuildAll.bat
call ReleaseExe.bat
call ReleaseSrc.bat
