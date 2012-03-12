{
 * FmMain.pas
 *
 * Application's main form. Handles main user inteface interaction.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is FmMain.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2006-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit FmMain;


interface

uses
  // Delphi
  ImgList, Controls, ActnList, StdActns, Classes, Menus, StdCtrls, OleCtrls,
  SHDocVw, ExtCtrls, ComCtrls, ToolWin, Forms, ActiveX, Windows, XPMan,
  SysUtils,
  // Project
  IntfDropDataHandler, UDocument, UWBContainer, UInputData;


type

  {
  TMainForm:
    Application's main form and used interaction.
  }
  TMainForm = class(TForm, IDropDataHandler)
    actAbout: TAction;
    actCopy: TAction;
    actExit: TFileExit;
    actFrag: TAction;
    actHints: TAction;
    actOpen: TFileOpen;
    actPaste: TAction;
    actSaveAs: TFileSaveAs;
    alMain: TActionList;
    edHTML: TMemo;
    edSource: TMemo;
    ilMain: TImageList;
    miAbout: TMenuItem;
    miCopy: TMenuItem;
    miEdit: TMenuItem;
    miExit: TMenuItem;
    miFile: TMenuItem;
    miFrag: TMenuItem;
    miHelp: TMenuItem;
    miHints: TMenuItem;
    miOpen: TMenuItem;
    miOptions: TMenuItem;
    miPaste: TMenuItem;
    miSaveAs: TMenuItem;
    miSpacer: TMenuItem;
    mnuMain: TMainMenu;
    pcMain: TPageControl;
    pnlHTML: TPanel;
    pnlRendered: TPanel;
    pnlSource: TPanel;
    sbMain: TStatusBar;
    tbCopy: TToolButton;
    tbFrag: TToolButton;
    tbMain: TToolBar;
    tbOpen: TToolButton;
    tbSaveAs: TToolButton;
    tbSpacer1: TToolButton;
    tbSpacer2: TToolButton;
    tbPaste: TToolButton;
    tsHTML: TTabSheet;
    tsRendered: TTabSheet;
    tsSource: TTabSheet;
    wbRendered: TWebBrowser;
    procedure actAboutExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actFragExecute(Sender: TObject);
    procedure actHintsExecute(Sender: TObject);
    procedure actOpenAccept(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actSaveAsAccept(Sender: TObject);
    procedure actSaveAsUpdate(Sender: TObject);
    procedure alMainUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pcMainMouseLeave(Sender: TObject);
    procedure pcMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbMainHint(Sender: TObject);
  private
    fDocument: TDocument;
      {Currently loaded document}
    fDropTarget: IDropTarget;
      {Object that interacts with OLE drag and drop}
    fWBContainer: TWBContainer;
      {Container for browser control that provide OLE client site and customises
      browser}
    fBusy: Boolean;
      {Flag true if program busy (i.e. highlighting and loading source)}
    fForcedActionUpdate: Boolean;
      {Flag true when program forces actions to update. Used to prevent flicker
      when toolbar actions repeatedly set true then false on idle in
      alMainUpdate event handler}
    procedure UpdateStatusBar;
      {Updates information displayed in status bar.
      }
    procedure UpdateDisplay;
      {Updates main display with contents of document.
      }
    procedure DocHiliteHandler(Sender: TObject);
      {Called when document object reports it has finished highlighting a
      document. Updates display with newly highlighted document.
        @param Sender [in] Not used.
      }
    procedure DoLoad(const InputData: IInputData);
      {Loads data into document, setting program busy while load takes place.
        @param InputData [in] Object encapsulating data to be loaded.
      }
    procedure TranslateAccelHandler(Sender: TObject; const Msg: TMSG;
      const CmdID: DWORD; var Handled: Boolean);
      {Handles event triggered by web browser controller when a key is pressed
      in the browser control. Browser is prevented from certain key down events
      which are instead passed to main window for processing.
        @param Sender [in] Not used.
        @param Msg Message generating accelerator translation request.
        @param CmdID Not used.
        @param Handled [in/out] Set to true if Msg is a key down message that we
          are handling and need to prevent browser control from processing.
      }
    function IsValidDataObj(const DataObj: IDataObject): Boolean;
      {Checks if a data object is of a kind supported by the program.
        @param DataObj [in] Data object to check.
        @return True if data object valid, false if not.
      }
    procedure UpdateAllActions;
      {Updates all actions in action list.
      }
    procedure Busy(const Flag: Boolean);
      {Flags application as busy or idle depending on state of a flag.
        @param Flag [in] True if application is busy, false if idle.
      }
    function DocHasContent: Boolean;
      {Checks if document has content, i.e. is not empty.
        @return True if document has content.
      }
  protected
    { IDropDataHandler methods }
    function CanAccept(const DataObj: IDataObject): Boolean;
      {Checks if application wants to accept a data object.
        @param DataObj [in] Data object being dragged.
        @return True if data object can be accepted, false if not.
      }
    procedure HandleData(const DataObj: IDataObject);
      {Handles drop of a dragged data object. Only called if CanAccept has
      returned true.
        @param DataObj [in] Dropped data object.
      }
    function DropEffect(const Shift: TShiftState;
      const AllowedEffects: TDragDropEffects): TDragDropEffect;
      {Determines drop effect for a dragged data object. Only called if
      CanAccept has returned true.
        @param Shift [in] Set of shift keys and mouse button pressed.
        @param AllowedEffects [in] Effects supported by data source.
        @return Desired drop effect (must be member of AllowedEffects set).
      }
    procedure IDropDataHandler.ExceptionHandler = DragDropExceptionHandler;
    procedure DragDropExceptionHandler(const E: TObject);
      {Handle exception trapped in drag-drop. Handler should swallow exception
      and not re-raise it.
        @param E [in] Exception object to be handled.
      }
  end;


var
  MainForm: TMainForm;


implementation


uses
  // Delphi
  ComObj, Messages,
  // Project
  UClipFmt, UDataObjectAdapter, UOutputData, UUtils, UDropTarget;


{$R *.dfm}


resourcestring
  // Hints
  sDisplayTabHint = 'Displays highlighted source code as it appears in '
    + 'browsers';
  sSourceTabHint = 'Displays source code without highlighting';
  sHTMLTabHint = 'Displays raw XHTML of the highlighted source code';
  // Status messages
  sSBGenHTMLFrag = 'Generating HTML code fragments';
  sSBGenHTMLDoc = 'Generating complete HTML documents';

const
  // Default style sheet for HTML documents
  cBodyCSS = 'body {margin:0;font-size:9pt;font-family:"Arial";}';

  // Maps tab sheets to long hints associated with their tabs. We can't store
  // long hints in tab sheets' Hint property since this is displayed when cursor
  // is over tab content as well as label. We map an index number in tab sheets'
  // Tag property to hint text. We don't use tabsheets' indexes in page control
  // in case tabs get re-ordered.
  cTabSheetHints: array[0..2] of string = (
    sDisplayTabHint, sSourceTabHint, sHTMLTabHint
  );


procedure TMainForm.actAboutExecute(Sender: TObject);
  {Displays about box.
    @param Sender [in] Not used.
  }
begin
  MessageBox(
    Handle,
      'PasHiGUI v0.1.1 beta.'#13#10#13#10
      + 'A GUI front end for the PasHi Syntax Highlighter.'#13#10#13#10
      + 'Copyright (c) 2006-2010 by Peter D Johnson (www.delphidabbler.com).',
    'About',
    MB_OK
  );
end;

procedure TMainForm.actCopyExecute(Sender: TObject);
  {Copies current document to clipboard.
    @param Sender [in] Not used.
  }
begin
  // Document saves to IOutputData object that writes clipboard
  fDocument.Save(TOutputDataFactory.CreateForClipboard(CF_TEXT));
end;

procedure TMainForm.actCopyUpdate(Sender: TObject);
  {Enables / disabled actCopy depending on if a document is loaded.
    @param Sender [in] Not used.
  }
begin
  actCopy.Enabled := DocHasContent;
end;

procedure TMainForm.actFragExecute(Sender: TObject);
  {Toggles between generating complete HTML documents and HTML fragments and
  re-hilites current document. Program is flagged as busy during this process.
    @param Sender [in] Not used.
  }
begin
  actFrag.Checked := not actFrag.Checked;
  Busy(True);
  try
    fDocument.Fragment := actFrag.Checked;
  finally
    Busy(False);
  end;
  UpdateStatusBar;
end;

procedure TMainForm.actHintsExecute(Sender: TObject);
  {Toggles whether hints are displayed or not.
    @param Sender [in] Not used.
  }
begin
  actHints.Checked := not actHints.Checked;
  sbMain.AutoHint := actHints.Checked;
  ShowHint := actHints.Checked;
end;

procedure TMainForm.actOpenAccept(Sender: TObject);
  {Loads the file selected in file open dialog into document.
    @param Sender [in] Not used.
  }
begin
  // Document loaded using IInputData object that can read from file
  DoLoad(TInputDataFactory.CreateFromFile(actOpen.Dialog.FileName));
end;

procedure TMainForm.actPasteExecute(Sender: TObject);
  {Loads contents of clipboard into document.
    @param Sender [in] Not used.
  }
var
  CBData: IDataObject;  // object storing clipboard data
begin
  OleCheck(OleGetClipboard(CBData));
  HandleData(CBData);
end;

procedure TMainForm.actPasteUpdate(Sender: TObject);
  {Enables / disables actPaste depending on whether clipboard contains suitable
  data.
    @param Sender [in] Not used.
  }
var
  CBData: IDataObject;  // object storing clipboard data
begin
  OleCheck(OleGetClipboard(CBData));
  actPaste.Enabled := IsValidDataObj(CBData);
end;

procedure TMainForm.actSaveAsAccept(Sender: TObject);
  {Saves document as file selected in save dialog.
    @param Sender [in] Not used.
  }
begin
  // Document saves to IOutputData object that writes to a file
  fDocument.Save(TOutputDataFactory.CreateForFile(actSaveAs.Dialog.FileName));
end;

procedure TMainForm.actSaveAsUpdate(Sender: TObject);
  {Enables / disables actSaveAs depending on if document has content.
    @param Sender [in] Not used.
  }
begin
  actSaveAs.Enabled := DocHasContent;
end;

procedure TMainForm.alMainUpdate(Action: TBasicAction; var Handled: Boolean);
  {Disables an action if program is busy highlighting a document and enables
  them otherwise. This event handler is called for all actions before individual
  actions' OnUpdate events.
    @param Action [in] Action to enable / disable.
    @param Handled [in/out] Set true if action disabled to prevent other update
      events for action being triggered.
  }
begin
  if fBusy then
  begin
    if (Action is TCustomAction) then
    begin
      TCustomAction(Action).Enabled := False;
      // we set Handled true to prevent other update events changing state
      Handled := True;
    end;
  end
  else
  begin
    if fForcedActionUpdate and (Action is TCustomAction) then
      TCustomAction(Action).Enabled := True;
      // we leave Handled false to allow other update handlers to disable
      // actions if necessary
  end;
end;

procedure TMainForm.Busy(const Flag: Boolean);
  {Flags application as busy or idle depending on state of a flag.
    @param Flag [in] True if application is busy, false if idle.
  }
begin
  // Set main window and browser control's cursors
  if Flag then
  begin
    Screen.Cursor := crHourGlass;
    wbRendered.Cursor := crHourGlass;
  end
  else
  begin
    Screen.Cursor := crDefault;
    wbRendered.Cursor := crDefault;
  end;
  // Record state
  fBusy := Flag;
  // Enable or disable browser control
  wbRendered.Enabled := not Flag;
  // Update all actions - fBusy flag determines if actions disabled or enabled
  UpdateAllActions;
end;

function TMainForm.CanAccept(const DataObj: IDataObject): Boolean;
  {Checks if application wants to accept a data object.
    @param DataObj [in] Data object being dragged.
    @return True if data object can be accepted, false if not.
  }
begin
  Result := IsValidDataObj(DataObj);
end;

function TMainForm.DocHasContent: Boolean;
  {Checks if document has content, i.e. is not empty.
    @return True if document has content.
  }
begin
  Result := not fDocument.IsEmpty;
end;

procedure TMainForm.DocHiliteHandler(Sender: TObject);
  {Called when document object reports it has finished highlighting a document.
  Updates display with newly highlighted document.
    @param Sender [in] Not used.
  }
begin
  UpdateDisplay;
end;

procedure TMainForm.DoLoad(const InputData: IInputData);
  {Loads data into document, setting program busy while load takes place.
    @param InputData [in] Object encapsulating data to be loaded.
  }
begin
  Busy(True);
  try
    fDocument.Load(InputData);
  finally
    Busy(False);
  end;
end;

procedure TMainForm.DragDropExceptionHandler(const E: TObject);
  {Handle exception trapped in drag-drop. Handler should swallow exception and
  not re-raise it.
    @param E [in] Exception object to be handled.
  }
begin
  Application.HandleException(E);
end;

function TMainForm.DropEffect(const Shift: TShiftState;
  const AllowedEffects: TDragDropEffects): TDragDropEffect;
  {Determines drop effect for a dragged data object. Only called if CanAccept
  has returned true.
    @param Shift [in] Set of shift keys and mouse button pressed.
    @param AllowedEffects [in] Effects supported by data source.
    @return Desired drop effect (must be member of AllowedEffects set).
  }
begin
  Result := deNone;
  // Set preferred effects based on keys pressed
  if ssCtrl in Shift then
    Result := deCopy
  else if ssShift in Shift then
    Result := deMove;
  if not (Result in AllowedEffects) then
  begin
    // Can't use shift keys to determine effect: select one of allowed options
    if deCopy in AllowedEffects then
      Result := deCopy    // prefer copy
    else if deMove in AllowedEffects then
      Result := deMove    // can't do copy so try move
    else
      Result := deNone;   // copy/move not allowed, we don't support link
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
  {Initialises program.
    @param Sender [in] Not used.
  }
begin
  // Ensure window title is same as application
  Caption := Application.Title;
  // Set up OLE
  OleInitialize(nil);
  // Create document object
  fDocument := TDocument.Create;
  fDocument.OnHilite := DocHiliteHandler;
  // Create OLE drop target object and register it for this window
  fDropTarget := TDropTarget.Create(Self);
  OleCheck(RegisterDragDrop(Handle, fDropTarget));
  // Create web browser controller object
  fWBContainer := TWBContainer.Create(wbRendered);
  fWBContainer.Show3DBorder := False;
  fWBContainer.UseCustomCtxMenu := True;
  fWBContainer.CSS := cBodyCSS;
  fWBContainer.DropTarget := fDropTarget;
  fWBContainer.OnTranslateAccel := TranslateAccelHandler;
  // Initialise status bar
  UpdateStatusBar;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
  {Tidies up program.
    @param Sender [in] Not used.
  }
begin
  // Unregister drag drop
  RevokeDragDrop(Handle);
  fDropTarget := nil;
  // Free owned objects
  FreeAndNil(fWBContainer);
  FreeAndNil(fDocument);
  // Finalise OLE
  OleUninitialize;
end;

procedure TMainForm.FormShow(Sender: TObject);
  {Initialises controls
    @param Sender [in] Not used.
  }
begin
  // Select rendered page by default
  pcMain.ActivePage := tsRendered;
  // Display empty document
  fWBContainer.EmptyDocument;
end;

procedure TMainForm.HandleData(const DataObj: IDataObject);
  {Handles drop of a dragged data object. Only called if CanAccept has
  returned true.
    @param DataObj [in] Dropped data object.
  }
var
  DOAdapter: TDataObjectAdapter;  // helper object used to access data object
begin
  DOAdapter := TDataObjectAdapter.Create(DataObj);
  try
    if DOAdapter.HasFormat(CF_FILENAME) then
      // Load data from file: we know it is not a directory since this method
      // is only called for valid data objects
      DoLoad(
        TInputDataFactory.CreateFromFile(DOAdapter.GetDataAsText(CF_FILENAME))
      )
    else if DOAdapter.HasFormat(CF_UNICODETEXT) then
      DoLoad(
        TInputDataFactory.CreateFromText(
          DOAdapter.ReadDataAsUnicodeText(CF_UNICODETEXT)
        )
      )
    else if DOAdapter.HasFormat(CF_TEXT) then
      // Load text data
      DoLoad(
        TInputDataFactory.CreateFromText(DOAdapter.ReadDataAsAnsiText(CF_TEXT))
      )
    else
      raise Exception.Create('Expected data format not available');
  finally
    FreeAndNil(DOAdapter);
  end;
end;

function TMainForm.IsValidDataObj(const DataObj: IDataObject): Boolean;
  {Checks if a data object is of a kind supported by the program.
    @param DataObj [in] Data object to check.
    @return True if data object valid, false if not.
  }
var
  DOAdapter: TDataObjectAdapter;  // helper object used to access data object
begin
  DOAdapter := TDataObjectAdapter.Create(DataObj);
  try
    Result := DOAdapter.HasFormat(CF_UNICODETEXT)
      or DOAdapter.HasFormat(CF_TEXT)
      or
        (DOAdapter.HasFormat(CF_FILENAME)
        and not IsDirectory(DOAdapter.GetDataAsText(CF_FILENAME)))
  finally
    FreeAndNil(DOAdapter);
  end;
end;

procedure TMainForm.pcMainMouseLeave(Sender: TObject);
  {Clears any hint relating to page control when mouse leaves it.
    @param Sender [in] Not used.
  }
begin
  pcMain.Hint := '';
end;

procedure TMainForm.pcMainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  {Sets hint describing a tab if mouse is over one and clears hint if not.
    @param Sender [in] Not used.
    @param Shift [in] Not used.
    @param X [in] X coordinate of mouse.
    @param Y [in] Y coordinate of mouse.
  }
var
  TabIdx: Integer;      // index of tab under mouse or -1 if none
  TabSheet: TTabSheet;  // reference of tab sheet under mouse
begin
  if htOnItem in pcMain.GetHitTestInfoAt(X, Y) then
  begin
    TabIdx := pcMain.IndexOfTabAt(X, Y);
    if (0 <= TabIdx) and (TabIdx < pcMain.PageCount) then
    begin
      TabSheet := pcMain.Pages[TabIdx];
      pcMain.Hint := '|' + cTabSheetHints[TabSheet.Tag];  // long hint only
    end
    else
      pcMain.Hint := '';
  end
  else
    pcMain.Hint := '';
end;

procedure TMainForm.sbMainHint(Sender: TObject);
  {Displays current hint in status bar or restores status bar if there is no
  hint.
    @param Sender [in] Not used.
  }
begin
  if Application.Hint <> '' then
  begin
    sbMain.SimplePanel := True;
    sbMain.SimpleText := Application.Hint;
  end
  else
  begin
    sbMain.SimplePanel := False;
    sbMain.SimpleText := '';
    sbMain.Refresh;
  end;
end;

procedure TMainForm.TranslateAccelHandler(Sender: TObject; const Msg: TMSG;
  const CmdID: DWORD; var Handled: Boolean);
  {Handles event triggered by web browser controller when a key is pressed in
  the browser control. Browser is prevented from certain key down events which
  are instead passed to main window for processing.
    @param Sender [in] Not used.
    @param Msg Message generating accelerator translation request.
    @param CmdID Not used.
    @param Handled [in/out] Set to true if Msg is a key down message that we
      are handling and need to prevent browser control from processing.
  }

  // ---------------------------------------------------------------------------
  procedure PostKeyPress(const DownMsg, UpMsg: UINT);
    {Posts a key down and key up message to this window with wParam and lParam
    per handled message.
      @param DownMsg [in] Key down message (WM_KEYDOWN or WM_SYSKEYDOWN).
      @param UpMsg [in] Key up message (WM_KEYUP or WM_SYSKEYUP).
    }
  begin
    PostMessage(Handle, DownMsg, Msg.wParam, Msg.lParam);
    PostMessage(Handle, UpMsg, Msg.wParam, Msg.lParam);
  end;
  // ---------------------------------------------------------------------------

var
  ShiftState: TShiftState;  // state of key modifiers
begin
  // We only handle key down messages
  if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_SYSKEYDOWN)) then
  begin
    // Record state of modifier keys
    ShiftState := Forms.KeyDataToShiftState(Msg.lParam);
    // Process key pressed (wParam field of Msg)
    case Msg.wParam of
      Ord('A')..Ord('Z'), Ord('0')..Ord('9'):
        // We handle Ctrl key with any alphanumeric keys. This enables any
        // of application's shortcut keys to be handled by associated action
        if (ShiftState = [ssCtrl])
          or (ShiftState = [ssCtrl, ssShift])
          or (ShiftState = [ssCtrl, ssShift, ssAlt]) then
          Handled := True;
      VK_F5:
        // We handle F5 key with any modifier to prevent browser refreshing
        // when this key is pressed
        Handled := True;
      VK_LEFT, VK_RIGHT, VK_HOME:
        // We handle Alt+Left, Alt+Right and Alt+Home keys to prevent browser
        // from navigating away from displayed page
        if (ShiftState = [ssAlt]) then
          Handled := True;
    end;
    if Handled then
    begin
      // Any key we handle is posted to window that owns frame, and is
      // therefore passed to main application
      case Msg.message of
        WM_KEYDOWN:     PostKeyPress(WM_KEYDOWN, WM_KEYUP);
        WM_SYSKEYDOWN:  PostKeyPress(WM_SYSKEYDOWN, WM_SYSKEYUP);
      end;
    end;
  end;
end;

procedure TMainForm.UpdateAllActions;
  {Updates all actions in action list.
  }
var
  I: Integer; // loops thru action list's actions
begin
  fForcedActionUpdate := True;
  try
    for I := 0 to Pred(alMain.ActionCount) do
      alMain.UpdateAction(alMain.Actions[I]);
  finally
    fForcedActionUpdate := False;
  end;
end;

procedure TMainForm.UpdateDisplay;
  {Updates main display with contents of document.
  }
begin
  fWBContainer.LoadFromString(fDocument.DisplayHTML, TEncoding.UTF8);
  edSource.Text := fDocument.SourceCode;
  edHTML.Text := fDocument.HilitedCode;
end;

procedure TMainForm.UpdateStatusBar;
  {Updates information displayed in status bar.
  }
begin
  // Display kind of output begin generated
  if actFrag.Checked then
    sbMain.Panels[0].Text := sSBGenHTMLFrag
  else
    sbMain.Panels[0].Text := sSBGenHTMLDoc;
end;

end.

