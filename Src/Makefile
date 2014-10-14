# ------------------------------------------------------------------------------
# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/
#
# Copyright (C) 2005-2012, Peter Johnson (www.delphidabbler.com).
#
# Makefile for the PasHi project.
# ------------------------------------------------------------------------------


# Set bin output path
BIN = ..\Bin

# Include common macros and rules
!include Common.mak

# Default target is to configure and build the PasHi executable program
default: pashi

# Configure and build PasHi
pashi: config resources pascal

# Configure and build PasHiGUI
pashigui:
  @cd GUI
  @$(MAKE)
  @cd ..

# Build all exes, including setup and create release file
all: pashi pashigui setup release

# Configure source folders
config:
  @echo Configuring PasHi
  # Create .cfg file from templates
  @copy /Y PasHi.cfg.tplt PasHi.cfg
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

# Builds setup program
setup:
  @del ..\Exe\PasHi-Setup-*
  @$(ISCC) Install\Install.iss

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
  @$(ZIP) -j -9 $(OUTFILE) Exe\PasHi-Setup-*.exe
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
  -@del /S *.tvsconfig 2>nul
  # remove any __history folders
  -@for /F "usebackq" %i in (`dir /S /B /A:D ..\__history`) do @rmdir /S /Q %i
  @cd Src

deepclean: clean
  @cd ..
  # remove files created by make config
  -@del /S *.cfg 2>nul
  # remove folders created by make config
  -@if exist Bin rmdir /S /Q Bin
  -@if exist Exe rmdir /S /Q Exe
  -@if exist Release rmdir /S /Q Release
  @cd Src
