@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing the binary release of PasHGUI
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006
@rem
@rem v1.0 of 17 Jun 2006 - First version.
@rem ---------------------------------------------------------------------------

@echo off
del ..\release\dd-pashgui.zip
zip -j -9 ..\release\dd-pashgui.zip ..\Exe\PasHGUI.exe ..\Docs\ReadMe.txt ..\Docs\License.txt
