PasHi Pascal Highlighter - ReadMe File
======================================

Introduction
------------

PasHi is a fully featured command line program that highlights Pascal source
code. It reads the original source code from standard input, files or the
clipboard and writes the highlighted code as HTML to standard output, a file,
or the clipboard.

HTML 4 (deprecated), XHTML and HTML 5 are all supported. CSS is used for
styling. Style sheets may be external or can be embedded in the HTML document.
Several predefined style sheets may be installed with the program. You can also
create your own.

PasHi can either generate complete HTML documents or just fragments of HTML
code.

HTML fragments make it easy to embed highlighted code in existing web pages. Web
page authors simply need to ensure that the necessary CSS classes are available.
The easiest way to do this is to use an external style sheet. The program's user
guide contains details of the required CSS classes.

PasHiGUI, an optional GUI front end for PasHi, is included in the release. This
provides a point and click interface to PasHi. Most, but not all, of PasHi's
command line options are supported. Files and text can be dragged and dropped
onto the GUI to highlight them.

Why another Pascal highlighter?
-------------------------------

Simple. I wanted an easy to use tool to format Pascal code for the DelphiDabbler
website that:

* Generated conformant XHTML or HTML 5 code.
* Styled the HTML using cascading style sheets.
* Provided full control over the appearance of the resulting document.
* Had the ability to highlight via the clipboard.
* Could optionally generate HTML code fragments for inserting into existing HTML
  documents.

On checking the available free tools I found that they were either too complex
or they didn't provide all the features I wanted.

I had already written highlighter code for my CodeSnip program, so I extracted
that, tweaked it and wrapped it up in a command line program. Having made it I
thought I'd release it in case anyone else found it useful. Since then it's been
greatly enhanced.

Installation
------------

PasHi requires Windows 7 SP1 or later to run. You need to have administrative
privileges to install it.

If you have PasHi (a.k.a PasH) v1.x or earlier you need to remove it before
installing this version. These early versions of the program have no setup
program, so you must uninstall manually. Simply find the program and delete the
executable file along with any support files you installed. If you included the
v1.x install directory on the system path you should remove it. If you used
PasHGUI v0.1.0 beta you also need to remove that program manually.

PasHi is provided in a zip file that contains a setup program named
PasHi-Setup-xxx.exe (where xxx is the program's version number). The zip file
also contains this read-me file.

Extract the setup program from the zip file and run it, following the on-screen
instructions.

You will need to accept the license before proceeding with the installation. The
license is permissive and lets you copy and share PasHi freely.

After agreeing to the license you then choose the installation directory
followed by the name of the start menu program group. After that you have three
options, all of which are selected by default:

1. Add PasHi's directory to the system path for all users:

    This lets you run PasHi simply by typing its name on the command line,
    without specifying the path to the program. The installer modifies the
    system PATH environment variable. This option is recommended for everyone.

    Please note that any open command shell windows will need to be closed and
    re-opened before the updated path will be recognised.

2. Install sample style sheets and config file templates:

    This option installs various CSS style sheets and config file templates. The
    files take up very little disk space so this option is recommended unless
    you are sure you will never need them.

    See the program's user guide for details of how to create a config file for
    PasHi from the provided template files.

    The files will appear in your %AppData%\DelphiDabbler\PasHi directory
    immediately after you first run PasHi.

3. Install GUI front end program, PasHiGUI:

    This installs the PasHiGUI program alongside PasHi. This program is worth
    installing if you prefer to use PasHi from a GUI rather than mastering the
    command line. Most, but not all, of PasHi's options are available from
    PasHiGUI.

Once you have made your choices you can review them. You can go back to make
changes or commit to installing. Once installation is complete then the last
page is displayed. It gives an option to display this ReadMe file. If you have
installed PasHiGUI you are also given the option to run it.

The installer makes the following changes to your system:

  * The main program's executable files and documentation are installed into the
    chosen install folder (%ProgramFiles%\DelphiDabbler\PasHi or
    %ProgramFiles(x86)%\DelphiDabbler\PasHi by default on 32 bit and 64 bit
    Windows respectively). If you chose to install it, PasHiGUI will also be
    placed in the same directory.

  * Files required by the uninstaller are stored in the main installation's
    Uninst sub-folder.

  * The program's uninstall information is registered with Windows. This updates
    the system registry.

  * The system path will have been modified for all users if you chose the
    relevant option.

  * A program group will be created in the start menu.

  * Sample .css and config files are copied to
    %ProgramData%\DelphiDabbler\PasHi if you chose to install them. The first
    time that PasHi is run by each user, these files are also copied to that
    users's %AppData%\DelphiDabbler\PasHi directory.

Uninstallation
--------------

Open the application settings app appropriate to your version of Windows,
locate DelphiDabbler PasHi in the list of installed programs and select the
remove option. You will be asked to confirm removal of the program. Click Yes to
proceed.

PasHi, PasHiGUI (if installed) and all documentation will be removed.

The directory %ProgramData%\DelphiDabbler\PasHi will be removed but each user's
%AppData%\DelphiDabbler\PasHi directory and all its files will be left behind.

PasHi's install directory will be removed from the system path if present.

Installation information should be removed from the registry by the uninstaller.

Documentation
-------------

Details of how to use both the command line and GUI programs can be found in the
file UserGuide.html that is installed with the program.

Bug Reports
-----------

Please report any bugs using the program's issue tracker on GitHub at
https://github.com/delphidabbler/pashi/issues. You will need a free GitHub
account in order to create an issue.

Source Code
-----------

Source code is available from the program's GitHub repository at
https://github.com/delphidabbler/pashi/.

Source code of each release of the program going back to v1.0.0 is available for
download from https://github.com/delphidabbler/pashi/releases.

License
-------

For details please see the file LICENSE.md that is installed in the directory
where PasHi was installed.
