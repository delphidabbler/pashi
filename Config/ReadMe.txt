All files in this directory, except this one, are optionally installed into the
%ProgramData%\DelphiDabbler\PasHi directory by the installer. PasHi then copies
the files into each user's %AppData%\DelphiDabbler\PasHi directory, and updates
them after each update is installed.

The file "version" contains just a single number that indicates the version of
the files in this directory. The number should be bumped by one each time one or
more files in this directory are changed in a release.

If the number in %ProgramData%\DelphiDabbler\PasHi\version is greater than that
in %AppData%\DelphiDabbler\PasHi\version then the files in
%ProgramData%\DelphiDabbler\PasHi are copied to %AppData%\DelphiDabbler\PasHi,
overwriting any existing files. The files are also copied if either of the
"version" files are not present.
