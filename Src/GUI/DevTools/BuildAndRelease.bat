@rem ---------------------------------------------------------------------------
@rem Script used to build all of PasHGUI and create release zip files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006
@rem
@rem v1.0 of 17 Jun 2006 - First version.
@rem ---------------------------------------------------------------------------

@echo off

call Tidy.bat
call BuildAll.bat
call ReleaseExe.bat
call ReleaseSrc.bat
