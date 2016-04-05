PasHi Pascal Highlighter - ReadMe File
======================================

Introduction
------------

PasHi is a fully featured command line program that highlights Pascal source
code. It reads the original source code from standard input, files or the
clipboard and writes the highlighted code as HTML to standard output, a file,
or the clipboard.

HTML 4, XHTML and HTML 5 are all supported. CSS is used for styling. Style
sheets may be external or can be embedded in the HTML document. Several
predefined style sheets are installed with the program. You can also create your
own.

PasHi can either generate complete HTML documents or just fragments of HTML
code. HTML fragments make it easy to embed highlighted code in existing web
pages. Web page authors simply need to ensure that the necessary CSS classes are
available. The easiest way to do this is to use an external style sheet.

PasHiGUI, a GUI front end for PasHi, is included in the release. This provides a
point and click way of using PasHi. Most, but not all, command line options are
supported. Files and text can be dragged and dropped onto the window to
highlight them.


Why another Pascal highlighter?
-------------------------------

Simple, I wanted an easy to use tool to format Pascal code for the DelphiDabbler
website. I wanted the following:

* Conformant XHTML and later HTML 5.
* Styling by means of cascading style sheets.
* Full control over the appearance of the output code.
* Ability to highlight via the clipboard.
* The option to generate HTML fragments for inserting into existing documents.

On checking the available free tools I found that they were either too complex
or they didn't provide one or more of the features I wanted.

I had already written highlighter code for my CodeSnip program, so I extracted
that, tweaked it and wrapped it up in a command line program. Having made it I
thought I'd release it in case anyone else found it useful. Since then it's been
greatly enhanced.


Installation
------------

PasHi requires Windows 2000 or later to run. You need to have administrative
privileges to install it. Elevation may be required to install on Windows Vista
and later.

If you have PasHi v1.x or earlier you need to remove it before installing this
version. These early versions of the program have no setup program, so you must
uninstall manually. Simply find the program (and PasHiGUI if you have it) and
delete the executable file(s) along with any support files you installed. If you
included the v1.x install directory on the system path you should remove it.

PasHi is provided in a zip file that contains a setup program,
PasHi-Setup-xxx.exe (where xxx is the program's version number). The zip file
also contains this read-me file.

Extract the setup program from the zip file and run it, following the on-screen
instructions.

You will need to accept the license before configuring and completing the
installation. The license is permissive and lets you copy and share PasHi
freely. You can also modify it providing you make the source code of your
changes freely available.

After agreeing to the license the installer you choose the installation
directory followed by the name of the start menu program group. Following that
you have three options, all of which are selected by default:

1. Add PasHi's directory to the system path for all users:

    This lets you run PasHi simply by typing its name on the command line,
    without specifying the path to the program. The installer modifies the
    system PATH environment variable. This option is recommended for everyone.

2. Install sample style sheets and config file templates:

    This option installs various CSS style sheets and config file templates.
    These files will appear in your %AppData%\DelphiDabbler\PasHi directly
    immediately after you first run PasHi. The files take up very little disk
    space so this option is recommended unless you are sure you will never need
    to use the files.

3. Install GUI front end program, PasHiGUI:

    This installs the PasHiGUI program alongside PasHi. This program is worth
    installing if you prefer to use PasHi from a GUI rather than mastering the
    command line. Most, but not all, of PasHi's options are available from
    PasHiGUI.

Once you have made your choices, you can review them then either go back to make
changes or commit to installing. Once installation is complete then the last
page is displayed. It gives an option to display this ReadMe file. If you have
installed PasHiGUI you are given the option to run it.

The installer makes the following changes to your system:

  * The main program's executable files and documentation are installed into the
    chosen install folder (%ProgramFiles%\DelphiDabbler\PasHi or
    %ProgramFiles(x86)%\DelphiDabbler\PasHi by default on 32 bit and 64 bit
    Windows respectively). If you  chose to install it, PasHiGUI will also be
    placed in the same directory.

  * Files required by the uninstaller are stored in the main installation's
    Uninst sub-folder.

  * The program's uninstall information is registered with the Programs and
    Features (aka Add / Remove Programs) control panel applet.

  * The system path may be updated if you chose the relevant option.

  * A program group will be created in the start menu.

  * Sample .css and config files are installed in
    %ProgramData%\DelphiDabbler\PasHi. The first time that PasHi is run by each
    user, these files are also copied to that users's
    %AppData%\DelphiDabbler\PasHi directory.


Uninstallation
--------------

Open the Programs and Features (aka Add / Remove Programs) applet from the
Control Panel, navigate to the DelphiDabbler PasHi entry and click the Remove or
Uninstall button. You will be asked to confirm removal of the program. Click Yes
to proceed.

PasHi, PasHiGUI (if installed) and all documentation will be removed.

The directory %ProgramData%\DelphiDabbler\PasHi will be removed but each user's %AppData%\DelphiDabbler\PasHi directory and all its files will be left behind.

PasHi's install directory will be removed from the system path if present.


Documentation
-------------

Details of how to use both the command line and GUI programs can be found in the
file UserGuide.html that is installed with the program.


Bug Reports
-----------

Please report any bugs using the program's issue tracker on GitHub at
<https://github.com/delphidabbler/pashi/issues>. You will need a free GitHub
account in order to create an issue.


Source Code
-----------

Source code is available from the program's GitHub repository at
<https://github.com/delphidabbler/pashi/>. Please read the file ReadMe.md that
is stored in the root of the reposity for details of how to contribute.

Source code of each release of the program going back to v1.0.0 is available for
download from <https://github.com/delphidabbler/pashi/releases>.


License
-------

For details please see the file LICENSE that is installed in the directory where
PasHi was installed.
