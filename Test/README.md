# PasHi Test Files

This directory contains files used to test different aspects of PasHi

The files are:

* `Test.pas` - stress tests the PasHi parser.
* `Test-Special۩-filename.pas` - tests handling of non-ANSI characters in filenames.
* `Test-Special-Chars.pas` - tests handling of non-ANSI characters in Pascal code: special characters in strings and indentifiers are tested.
* `Test-Trim-Lines+Spaces.pas` - tests the various modes of the `--trim` command.
* `Test-UCS2LE-BOM.pas` - tests handling of source files encoded in UCS2 LE format with BOM.
* `Test-UTF8-BOM.pas` - tests handling of source files encoded in UTF-8 with "BOM".
