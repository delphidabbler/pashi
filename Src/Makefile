# ------------------------------------------------------------------------------
# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/
#
# Copyright (C) 2005-2015, Peter Johnson (www.delphidabbler.com).
#
# Makefile for the PasHi project.
# ------------------------------------------------------------------------------


# Set required output paths for Common.mak
ROOT = ..
BINREL =

# Include common macros and rules
!include Common.mak

# Store name and path of release file
!ifndef RELEASEFILENAME
RELEASEFILENAME = dd-pashi
!endif
RELEASEFILEPATH = $(RELEASE)\$(RELEASEFILENAME).zip

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
  @if not exist $(BUILD) @mkdir $(BUILD)
  @if not exist $(BIN) @mkdir $(BIN)
  @if not exist $(EXE) @mkdir $(EXE)
  @if not exist $(RELEASE) @mkdir $(RELEASE)

# Compiles the resources
resources: VerInfo.res Resources.res

# Builds PasHi pascal files and links program
pascal: PasHi.exe

# Builds setup program
setup:
  @del $(EXE)\PasHi-Setup-*
  @$(ISCC) Install\Install.iss

# Build release files (.zip)
release:
  @echo Creating Release File $(RELEASEFILENAME)
  -@if exist $(RELEASEFILEPATH) del $(RELEASEFILEPATH)
  @$(ZIP) -j -9 $(RELEASEFILEPATH) $(EXE)\PasHi-Setup-*.exe
  @$(ZIP) -j -9 $(RELEASEFILEPATH) $(DOCS)\ReadMe.txt $(ROOT)\LICENSE

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
  # remove files created by make config
  -@del /S *.cfg 2>nul
  # remove folders created by make config
  -@if exist $(BIN)\GUI rmdir /S /Q $(BIN)\GUI
  -@if exist $(BIN) rmdir /S /Q $(BIN)
  -@if exist $(EXE) rmdir /S /Q $(EXE)
  -@if exist $(RELEASE) rmdir /S /Q $(RELEASE)
  -@if exist $(BUILD) rmdir /S /Q $(BUILD)
