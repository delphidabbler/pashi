# ------------------------------------------------------------------------------
# Makefile
#
# Makefile for the PasHi project.
#
# $Rev$
# $Date$
#
# ***** BEGIN LICENSE BLOCK *****
#
# Version: MPL 1.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
# the specific language governing rights and limitations under the License.
#
# The Original Code is Makefile
#
# The Initial Developer of the Original Code is Peter Johnson
# (http://www.delphidabbler.com/).
#
# Portions created by the Initial Developer are Copyright (C) 2009-2010 Peter
# Johnson. All Rights Reserved.
#
# Contributors:
#   NONE
#
# ***** END LICENSE BLOCK *****
# ------------------------------------------------------------------------------


# Set bin output path
BIN = ..\Bin

# Include common macros and rules
!include Common.mak

# Default target is to configure and build the executable program
everything: config resources pascal

# Configure source folders
config:
  @echo Configuring PasHi
  # Create .cfg and .dof files from templates 
  @copy /Y PasHi.cfg.tplt PasHi.cfg
  @copy /Y PasHi.bdsproj.tplt PasHi.bdsproj
  # Create build folders if necessary
  @cd ..
  @if not exist Bin @mkdir Bin
  @if not exist Exe @mkdir Exe
  @if not exist Release @mkdir Release
  @cd Src

# Compiles the resources and deletes intermediate file created by VIED
resources: VerInfo.res Resources.res
  -@del VerInfo.rc

# Builds PasHi pascal files and links program
pascal: PasHi.exe

# Build release files (.zip)
!ifndef RELEASEFILENAME
RELEASEFILENAME = dd-pashi
!endif
OUTFILE = Release\$(RELEASEFILENAME).zip
release:
  @echo.
  @echo Creating Release File
  @echo ---------------------
  @cd ..
  -@if exist $(OUTFILE) del $(OUTFILE)
  @$(ZIP) -j -9 $(OUTFILE) Exe\PasHi.exe Exe\PasHiGUI.exe
  @$(ZIP) -j -9 $(OUTFILE) Docs\ReadMe.html Docs\License.txt
  @cd Src

# Clean up unwanted files
clean:
  @cd ..
  # remove unwanted files: temps (~ or .~*), .dsk, .ddp, .local, .identcache
  -@del /S *.~* 2>nul
  -@del /S ~* 2>nul
  -@del /S *.dsk 2>nul
  -@del /S *.ddp 2>nul
  -@del /S *.local 2>nul
  -@del /S *.identcache 2>nul
  # remove any __history folders
  -@for /F "usebackq" %i in (`dir /S /B /A:D ..\__history`) do @rmdir /S /Q %i
  @cd Src

deepclean: clean
  @cd ..
  # remove files created by make config
  -@del /S *.cfg 2>nul
  -@del /S *.bdsproj 2>nul
  # remove folders created by make config
  -@if exist Bin rmdir /S /Q Bin
  -@if exist Exe rmdir /S /Q Exe
  -@if exist Release rmdir /S /Q Release
  @cd Src
