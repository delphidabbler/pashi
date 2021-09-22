# Change Log

This is the change log for _DelphiDabbler PasHi_ and _PasHiGUI_.

All notable changes to this project are documented in this file.

This change log begins with the first ever pre-release version of what was then known as _PasH_. Releases are listed in reverse version number order.

From release 2.0.0 the version numbering has attempted to adhere to the principles of [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Release 2.1.0 - 2021-09-22

This release includes _PasHi_ v2.1.0 and _PasHiGUI_ v1.1.0. Change are as follows:

### PasHi v2.1.0 [build 12]

* Implemented a blacklist of commands that can't be included in the `config` file and halt the program with an error when such commands are detected. Only the `help` command is so blacklisted.
* Added new `--viewport` command that can write a mobile-friendly meta tag to the `<head>` section of complete (X)HTML documents.
* Added new `--edge-compatibility` command that can write a `http-equiv=X-UA-Compatible` meta tag for Microsoft Edge to the `<head>` section of complete (X)HTML documents.
* Added new facility to emit warning message for deprecated items.
* Added new `--verbosity no-warn` option to suppress warning messages.
* Flagged various v1 compatibility options as deprecated and generated warnings for most.
* Deprecated intermixing of input file names with commands in favour of input file names having to be listed first. Warnings are generated when this intermixing is detected.
* Improved code that ensures that HTML text elements are escaped correctly.
* Updated text of help screen re changes.
* Some refactoring

### PasHiGUI v1.1.0 [build 6]

* Updated Options pane to provide support for new `--viewport` and `--edge-compatibility` options.
* Flagged deprecated commands and options as such in Options pane.

### General

* Updated user guide `UserGuide.html`:
  * with details of new commands.
  * re deprecation of certain commands / options.
  * fixed display issues on phones and tablets.
* Converted license file to markdown format and renamed from `LICENSE` to `LICENSE.md`.
* Converted this change log to markdown format, moved from `Docs` directory to project root and renamed from `ChangeLog.txt` to `CHANGELOG.md`.
* Updated `config-template` comments:
  * flagged deprecated commands and parameters
  * noted fact that the `help` command can no longer be used in the `config` file
  * added details of new `viewport` and `edge-compatibility` commands
  * noted new command parameters
* Commented all v1 CSS classes as deprecated in `.css` files.

## Release 2.0.0 - 2016-09-22

This is a major release. Changes from v1.1.0 include the changes below along with all changes from releases 2.0 beta 1 and beta 2.

### PasHi v2.0.0 [build 11]

* Help screen text corrected and clarified.
* Manifested program as being compatible with Windows Vista through to Windows 10 and updated program version number in manifest.

### PasHiGUI v1.0.0 [build 5]

* Main window size and position now persists between runs.
* Hints are now displayed in main window.
* Help menu option to display online help replaced with option to display user guide that is installed with the program.
* Updates to About box:
  * Program version number and copyright details are now extracted from program resources instead of being hard coded.
  * The name of the license file was updated.
* Fixed potential bug in synchronising visibility of Options Bar with state of Show/Hide Options Bar menu option and toolbar button.
* Manifested program as being compatible with Windows Vista through to Windows 10.

### General

* Standardised format of version information for PasHi and PasHiGUI.
* Programs now compiled with Delphi XE instead of Delphi.
* Major overhaul of documentation including:
  * Former read-me HTML file was split into two documents: an HTML user guide named `UserGuide.html` that is installed with the programs and a read-me text file that is included with the installer in the program download.
  * All license information was consolidated in a new `LICENSE` file that is installed with the programs. This replaces `License.txt` and `SourceCodeLicenses.txt`.
  * Minor modification were made to license summary displayed by installer.
  * Many documents were updated re changes in v2 and were corrected and/or clarified.
* Corrections were made to config file templates and some of the optionally installed CSS files. Some comments were also clarified.
* Some code re-factored and commenting standardised.

## Release 2.0-beta 2 - 2014-08-12

### PasHi v1.99.2 [build 10] (aka v2.0.0 beta 2)

* Changed some parameters to `--encoding` command.
* Fixed bug where blank source code lines were not being displayed by browsers.
* Sign-on message now shows this is a v2.0.0 beta version.

### PasHiGUI v0.99.2 [build 4] (aka v1.0.0 beta 2)

* Removed descriptive text that was shown in main display when code fragments were displayed.
* `--default-css` option is no longer hard wired: now user configured or taken from gui-config file.
* Changed name of Help menu item that accesses online documentation.
* Changed main icon to be same as PasHi.
* Changed program title and caption to "PasHi GUI".
* Main window now animates correctly when minimized to task bar.
* Adjusted size of, and arrangement of controls on, option frame.
* About box now shows this is a v1.0.0 beta version.
* Some refactoring.

### General

* Updated documentation.
* Some code refactoring and removed some redundant code.
* Some tweaks to default CSS files to fix problem displaying colours on Blogger.com.
* New simplified EULA: installer now displays a summary instead of the full license.

## Release 2.0-beta 1 - 2011-04-11

### PasHi v1.99.1 [build 9] (aka v2.0.0 beta 1)

* Improved Pascal syntax highlighter:
* Now understands Delphi 2010 keywords and directives.
  * Support added for some context sensitive directives.
  * Reserved words prefixed with '&' now treated as identifiers.
* New input handling:
  * Source files may now be in UTF-16 (LE and BE), UTF-8 or default ANSI. Unicode formats are detected using byte order mark.
  * Input source can now be read directly from files passed on command line in addition to standard input and clipboard.
  * Where more than one input file is specified, files are concatenated before highlighting, separated by user specified number of blank lines.
  * Input source code can optionally have leading and trailing blank lines removed.
* Changes to generated XHTML files:
  * Output can now be in HTML 4 or HTML 5 in addition to XHTML and HTML fragments.
  * HTML file encoding is now user configurable and defaults to UTF-8. Byte order marks and HTML character set attributes are used as necessary.
  * User can specify language attribute of HTML output.
  * Source code can now be preceded by line numbers.
  * Alternate source code lines can now be styled differently.
  * Custom style sheets can now be used. They can be either embedded or external.
  * CSS class names changed but user can specify that old style names are used for compatibility with existing CSS code.
  * Document title can be changed.
  * "Branding" (comments or meta tags declaring PasHi as generator) can be inhibited.
  * Output file name can now be specified on command line as an alternative to using shell redirection.
  * HTML mark-up changed and requires some additional CSS classes to be defined.
* Program now has full Unicode support.
* Support for a `config` file added to allow program defaults to be configured.
* Heavily revised command line options:
  * Many new commands to control new options.
  * Some new commands to reinstate program defaults that may have been overridden by config file.
  * All commands now have a long form beginning with double dashes. Some commands also have a short form comprising a single dash and a single letter.
  * Commands from earlier program versions retained but made into aliases to relevant new commands.
* Help screen completely re-written.
* Bug fixes:
  * Exceptions are no longer raised on checking clipboard when another program has it open.
  * Parser no longer crashes when unexpected characters are encountered in source code.
* Significant refactoring of source code.

### PasHiGUI v0.99.1 [build 3] (aka v1.0.0 beta 1)

* Now requires PasHi v2 beta or later.
* Now Unicode compatible.
* UI changes:
  * "Source Code" tab removed from display: input source code is no longer displayed.
  * Options to be passed to PasHi can now be set in new "Options Side Bar" displayed at the right of the main window. The side bar can be shown or hidden as required.
  * "Fragments" tool button removed: this option is now set in Options side bar.
  * Status bar removed: hints and document type are no longer displayed.
  * A new styling is used to display HTML code fragments.
  * Menus and toolbar revised to reflect program changes.
  * Main window now constrained to a minimum size.
* Multiple file names can now be passed to PasHi via file open dialog box or by dragging and dropping from Explorer.
* Input files are now passed directly to the PasHi command line rather than being opened and sent to PasHi via a pipe. (Text from clipboard or drag/drop is still piped to PasHi).
* Interaction with PasHi changed to permit user defined options to be passed on command line.
* Options entered in Options Side Bar are persisted in PasHiGUI's own config file.
* Errors returned from PasHi are now reported to user.
* Online documentation can now be accessed from Help menu.
* Some refactoring.

### General
* Recompiled PasHi and PasHiGUI with Delphi 2010.
* Re-licensed source code: changed from Mozilla Public License v1.1 to v2.0.
* New sample CSS style sheets and config template files.
* New installer program that installs PasHi and its support files and provides options to:
  * Install PasHiGUI.
  * Install sample CSS and config templates files.
  * Add PasHi's install directory to the all-user system path.
* Updated and expanded documentation.

## Release 1.1.0 - 2010-02-15

### PasHi v1.0.1 [build 8]

* Renamed PasH to PasHi to avoid clash with another open source project name PasH.
* Rebuilt with Delphi 2006 instead of Delphi 7. Brings into line with PasHiGUI.
* Updated documentation and merged in PasHiGUI docs.

### PasHiGUI v0.1.1 Beta [build 2]

* Added PasHiGUI (renamed from PasHGUI) to release. No longer to be released separately.
* Merged documentation with PasHi

> For before _PasHi_ release 1.1.0, listed below, _PasH_ and _PasHGUI_ (as they were then known) were released as separate products and are labelled as such. Releases 1.1.0 and above above have both programs as part of the main release.

## PasH Release 1.0 [build 7] - 2009-05-31

* Added new -hidecss switch to hide contents of `<style>` tag in HTML comments. Default is now not to hide contents.
* Replaced on-the-fly generation of embedded style sheets for XHTML documents with a default style sheet read from resources.
* Updated to use Delphi 2006 keyword and directives list instead of those from Delphi 7.
* Replaced generic DelphiDabbler icon with custom PasH icon set.
* Added Vista manifest.
* Removed unnecessary compiler directives in units, i.e. those that replicate directives in project file.
* Made localisable string literals into resource strings.
* Fixed potential future bug in clipboard handling code.

## PasH Release 0.1.5-beta [build 6] - 2007-03-10

* Heavily refactored main program and parameter handling code.
* Invalid command line parameters now halt program with error message.
* Cosmetic changes to help display.
* Added new batch file to build program.
* Changed to new end user license agreement for the executable program. The program remains open source.

## PasHGUI Release 0.1.0-beta [build 1] - 2006-06-17

* Original beta release of PasHGUI as stand-alone program. Merged into main PasHi release at release 1.1.0.

## PasH Release 0.1.4-beta [build 5] - 2006-04-17

* Corrected title tag written to XHTML documents. Previously referred to CodeSnip Database, now refers to PasH.

## PasH Release 0.1.3-beta [build 4] - 2005-12-09

* Fixed bug that was causing program to crash when standard error output was redirected to a pipe when under control of an external program.

## PasH Release 0.1.2-beta [build 3] - 2005-11-03

* Program now traps exceptions and displays error message before terminating rather than exceptions crashing program.
* Documentation updated and changed to HTML from plain text.
* Moved program from alpha to beta release status.

## PasH Release 0.1.1-alpha [build 2] - 2005-06-04

* Made multi-line comments generate correctly formatted HTML when processed by syntax highlighter.
* Corrected minor typo in help screen.

## PasH Release 0.1.0-alpha [build 1] - 2005-05-28

* Original alpha version.
