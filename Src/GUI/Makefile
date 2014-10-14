# ------------------------------------------------------------------------------
# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/
#
# Copyright (C) 2010-2012, Peter Johnson (www.delphidabbler.com).
#
# Makefile for the PasHiGUI project.
# ------------------------------------------------------------------------------


# Set bin output path
BIN = ..\..\Bin\GUI

# Include common macros and rules
!include ..\Common.mak

# Default target is to configure and build the executable program
everything: config resources pascal

# Configure source folders
config:
  @echo Configuring PasHiGUI
  # Create .cfg file from templates
  @copy /Y PasHiGUI.cfg.tplt PasHiGUI.cfg
  # Create build folders
  @cd ..\..
  @if not exist Bin @mkdir Bin
  @if not exist Bin\GUI @mkdir Bin\GUI
  @if not exist Exe @mkdir Exe
  @cd Src\GUI

# Compiles the resources and deletes intermediate file created by VIED
resources: VersionInfo.res Resources.res
  -@del VersionInfo.rc

# Builds PasHiGUI pascal files and links program
pascal: PasHiGUI.exe
