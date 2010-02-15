# ------------------------------------------------------------------------------
# Makefile
#
# Makefile for the PasHiGUI project.
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
# Portions created by the Initial Developer are Copyright (C) 2010 Peter
# Johnson. All Rights Reserved.
#
# Contributors:
#   NONE
#
# ***** END LICENSE BLOCK *****
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
  # Create .cfg and .bdsproj files from templates 
  @copy /Y PasHiGUI.cfg.tplt PasHiGUI.cfg
  @copy /Y PasHiGUI.bdsproj.tplt PasHiGUI.bdsproj
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
