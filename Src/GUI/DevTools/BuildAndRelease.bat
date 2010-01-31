@rem ---------------------------------------------------------------------------
@rem Script used to build all of PasHGUI and create release zip files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006-2010
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

call Tidy.bat
call BuildAll.bat
call ReleaseExe.bat
call ReleaseSrc.bat
