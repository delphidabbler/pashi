# ------------------------------------------------------------------------------
# Common.mak
#
# Common code for inclusion in all make files. Defines common macros and rules.
# Files that require Common.mak must include it using the !include directive.
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
# The Original Code is Common.mak
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


# The preferred compiler is Delphi 2010. If the DELPHI2010 evironment variable
# is set, it will be used and expected to reference the Delphi 2010 install
# directory.
# If DELPHI2010 is not set then the DELPHIROOT environment variable is examined.
# This can be set to any Delphi compiler. If neither DELPHI2010 nor DELPHIROOT
# is set then an error is reported
!ifdef DELPHI2010
DELPHIROOT = $(DELPHI2010)
!endif

# Requires the following macros:
#   BIN - set to the directory that is to receive .res and .dcu output.
#   DELPHIROOT - install directory of Delphi compiler to be used

# Check for required macros
!ifndef DELPHIROOT
!error DELPHIROOT environment variable required.
!endif
!ifndef BIN
!error BIN macro must be defined in calling script.
!endif

# Define common macros that access required build tools

MAKE = "$(MAKEDIR)\Make.exe" -$(MAKEFLAGS)
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"
!ifdef VIEDROOT
VIED = "$(VIEDROOT)\VIEd.exe" -makerc
!else
VIED = VIEd.exe -makerc
!endif
!ifdef ZIPROOT
ZIP = "$(ZIPROOT)\Zip.exe"
!else
ZIP = Zip.exe
!endif


# Implicit rules
# Delphi projects are assumed to contain required output and search path
# locations in the project options .cfg file.
.dpr.exe:
  @echo +++ Compiling Delphi Project $< +++
  @$(DCC32) $< -B

# Resource files are compiled to the directory specified by BIN macro, which
# must have been set by the caller.
.rc.res:
  @echo +++ Compiling Resource file $< +++
  @$(BRCC32) $< -fo$(BIN)\$(@F)

# Version info files are compiled by VIEd. A temporary .rc file is left behind
.vi.rc:
  @echo +++ Compiling Version Info file $< +++
  @$(VIED) .\$<
