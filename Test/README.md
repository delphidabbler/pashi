# PasHi Test Files

This directory contains files used to test different aspects of PasHi.

The files are:

| File | Description |
|:-----|:------------|
| `Test.pas` | Stress tests the PasHi parser. |
| `Test-Special۩-filename.pas` | Tests handling of non-ANSI characters in filenames. | 
| `Test-Special-Chars.pas` | Tests handling of non-ANSI characters in Pascal code. Special characters in strings and identifiers are tested. |
| `Test-Trim-Lines+Spaces.pas` | Tests the various modes of the `--trim` command. |
| `Test-UCS2LE-BOM.pas` | Tests handling of source files encoded in UCS2 LE format with BOM. |
| `Test-UTF8-BOM.pas` | Tests handling of source files encoded in UTF-8 with "BOM" (i.e. preamble). |
