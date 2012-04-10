{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Application's main form. Handles main user inteface interaction.
}


unit FmMain;


interface

uses
  // Delphi
  ExtActns, ImgList, Controls, ActnList, StdActns, Classes, Menus, Forms,
  ExtCtrls, StdCtrls, OleCtrls, SHDocVw, ComCtrls, ToolWin, ActiveX, Windows,
  // Project
  IntfDropDataHandler, UOptions, UDocument, UWBContainer, UInputData,
  FrOptions.UBase, FrOptions.UDocType, FrOptions.ULineStyle, FrOptions.UCSS,
  FrOptions.UMisc;


type

  TOptionFrameCallback = reference to procedure(Frame: TBaseOptionsFrame);

  {
  TMainForm:
    Application's main form and used interaction.
  }
  TMainForm = class(TForm, IDropDataHandler)
    actAbout: TAction;
    actCopy: TAction;
    actExit: TFileExit;
    actOpen: TFileOpen;
    actPaste: TAction;
    actSaveAs: TFileSaveAs;
    alMain: TActionList;
    edHTML: TMemo;
    ilMain: TImageList;
    miAbout: TMenuItem;
    miCopy: TMenuItem;
    miEdit: TMenuItem;
    miExit: TMenuItem;
    miFile: TMenuItem;
    miHelp: TMenuItem;
    miOpen: TMenuItem;
    miOptions: TMenuItem;
    miPaste: TMenuItem;
    miSaveAs: TMenuItem;
    miSpacer: TMenuItem;
    mnuMain: TMainMenu;
    pcMain: TPageControl;
    pnlHTML: TPanel;
    pnlRendered: TPanel;
    tbCopy: TToolButton;
    tbMain: TToolBar;
    tbOpen: TToolButton;
    tbSaveAs: TToolButton;
    tbSpacer1: TToolButton;
    tbSpacer2: TToolButton;
    tbPaste: TToolButton;
    tsHTML: TTabSheet;
    tsRendered: TTabSheet;
    wbRendered: TWebBrowser;
    pnlOptions: TPanel;
    btnApplyOptions: TButton;
    btnRestoreDefaults: TButton;
    actRestoreDefaults: TAction;
    actApply: TAction;
    lblOptionsTitle: TLabel;
    cpgrpOptions: TCategoryPanelGroup;
    cpnlDocType: TCategoryPanel;
    cpnlLines: TCategoryPanel;
    frmDocType: TDocTypeOptionsFrame;
    frmLines: TLineStyleOptionsFrame;
    cpnlCSS: TCategoryPanel;
    frmCSS: TCSSOptionsFrame;
    cpnlMisc: TCategoryPanel;
    frmMisc: TMiscOptionsFrame;
    tbOptions: TToolButton;
    miOptionsBar: TMenuItem;
    actOptionsBar: TAction;
    lblOptionsHide: TLabel;
    actPasHiGUIWiki: TBrowseURL;
    miPasHiGUIWiki: TMenuItem;
    procedure actAboutExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
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
    procedure actRestoreDefaultsExecute(Sender: TObject);
    procedure actApplyExecute(Sender: TObject);
    procedure actOptionsBarExecute(Sender: TObject);
    procedure actOptionsBarUpdate(Sender: TObject);
    procedure lblOptionsHideClick(Sender: TObject);
    procedure lblOptionsHideMouseEnter(Sender: TObject);
    procedure lblOptionsHideMouseLeave(Sender: TObject);
  private
    fOptions: TOptions;
    fDocLoaded: Boolean;
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
    procedure UpdateDisplay;
      {Updates main display with contents of document.
      }
    procedure DoLoad(const InputData: IInputData); overload;
      {Loads data into document, setting program busy while load takes place.
        @param InputData [in] Object encapsulating data to be loaded.
      }
    procedure DoLoad(const Files: TArray<string>); overload;
    procedure DoLoad(const FileName: string); overload;
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
    procedure EnumOptionFrames(const Callback: TOptionFrameCallback);
    procedure DisplayOptions;
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
  SysUtils, ComObj, Messages,
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
  Application.MessageBox(
      'PasHiGUI v0.2.0 beta.'#13#10#13#10
      + 'A GUI front end for the PasHi Syntax Highlighter v2.'#13#10#13#10
      + 'Copyright (c) 2006-2012 by Peter D Johnson (www.delphidabbler.com).',
    'About',
    MB_OK
  );
end;

procedure TMainForm.actApplyExecute(Sender: TObject);
begin
  EnumOptionFrames(
    procedure(Frame: TBaseOptionsFrame)
    begin
      Frame.UpdateOptions(fOptions);
    end
  );
  Busy(True);
  try
    if fOptions.GetParamAsStr('doc-type') = 'fragment' then
      // todo: change this output type to doFragment
      fDocument.OutputType := doXHTMLFragment
    else
      // todo: change this output type to doComplete
      fDocument.OutputType := doXHTML;
    fDocument.Highlight(fOptions);
    UpdateDisplay;
    fDocLoaded := True;
  finally
    Busy(False);
  end;
end;

procedure TMainForm.actCopyExecute(Sender: TObject);
  {Copies current document to clipboard.
    @param Sender [in] Not used.
  }
begin
  // Document saves to IOutputData object that writes clipboard
  fDocument.Save(TOutputDataFactory.CreateForClipboard);
end;

procedure TMainForm.actCopyUpdate(Sender: TObject);
  {Enables / disabled actCopy depending on if a document is loaded.
    @param Sender [in] Not used.
  }
begin
  actCopy.Enabled := DocHasContent;
end;

procedure TMainForm.actOpenAccept(Sender: TObject);
  {Loads the file selected in file open dialog into document.
    @param Sender [in] Not used.
  }
var
  Files: TArray<string>;
  Idx: Integer;
begin
  SetLength(Files, actOpen.Dialog.Files.Count);
  for Idx := 0 to Pred(actOpen.Dialog.Files.Count) do
    Files[Idx] := actOpen.Dialog.Files[Idx];
  if Length(Files) = 0 then
    Exit;
  DoLoad(Files);
end;

procedure TMainForm.actOptionsBarExecute(Sender: TObject);
begin
  pnlOptions.Visible := actOptionsBar.Checked;
end;

procedure TMainForm.actOptionsBarUpdate(Sender: TObject);
resourcestring
  sShow = 'Show Options Bar';
  sHide = 'Hide Options Bar';
const
  Captions: array[Boolean] of string = (sShow, sHide);
begin
  actOptionsBar.Caption := Captions[actOptionsBar.Checked]
end;

procedure TMainForm.actPasteExecute(Sender: TObject);
  {Loads contents of clipboard into document.
    @param Sender [in] Not used.
  }
var
  CBData: IDataObject;  // object storing clipboard data
begin
  if not Succeeded(OleGetClipboard(CBData)) then
    Exit;
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
  actPaste.Enabled := Succeeded(OleGetClipboard(CBData))
    and IsValidDataObj(CBData);
end;

procedure TMainForm.actRestoreDefaultsExecute(Sender: TObject);
begin
  fOptions.RestoreDefaults;
  DisplayOptions;
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

procedure TMainForm.DisplayOptions;
begin
  EnumOptionFrames(
    procedure(Frame: TBaseOptionsFrame)
    begin
      Frame.Initialise(fOptions);
    end
  );
end;

function TMainForm.DocHasContent: Boolean;
  {Checks if document has content, i.e. is not empty.
    @return True if document has content.
  }
begin
  Result := fDocLoaded;
end;

procedure TMainForm.DoLoad(const FileName: string);
var
  Files: TArray<string>;
begin
  SetLength(Files, 1);
  Files[0] := FileName;
  DoLoad(Files);
end;

procedure TMainForm.DoLoad(const Files: TArray<string>);
// todo: merge DoLoad methods and set fDocument properties via closures
begin
  Busy(True);
  try
    fDocument.InputFiles := Files;
    fDocument.Highlight(fOptions);
    UpdateDisplay;
    fDocLoaded := True;
  finally
    Busy(False);
  end;
end;

procedure TMainForm.DoLoad(const InputData: IInputData);
  {Loads data into document, setting program busy while load takes place.
    @param InputData [in] Object encapsulating data to be loaded.
  }
begin
  Busy(True);
  try
    fDocument.InputData := InputData;
    fDocument.Highlight(fOptions);
    UpdateDisplay;
    fDocLoaded := True;
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

procedure TMainForm.EnumOptionFrames(const Callback: TOptionFrameCallback);
var
  Idx: Integer;
  Cmp: TComponent;
begin
  for Idx := 0 to Pred(ComponentCount) do
  begin
    Cmp := Components[Idx];
    if Cmp is TBaseOptionsFrame then
      Callback(Cmp as TBaseOptionsFrame);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
  {Initialises program.
    @param Sender [in] Not used.
  }
begin
  Caption := Application.Title;

  lblOptionsHide.Font.Color := cpgrpOptions.ChevronColor;

  OleInitialize(nil);

  fDocument := TDocument.Create;

  fDropTarget := TDropTarget.Create(Self);
  OleCheck(RegisterDragDrop(Handle, fDropTarget));

  fWBContainer := TWBContainer.Create(wbRendered);
  fWBContainer.Show3DBorder := False;
  fWBContainer.UseCustomCtxMenu := True;
  fWBContainer.CSS := cBodyCSS;
  fWBContainer.DropTarget := fDropTarget;
  fWBContainer.OnTranslateAccel := TranslateAccelHandler;

  fOptions := TOptions.Create;
  DisplayOptions;
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
  fOptions.Free;
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

  function StripDirectories(const Files: TArray<string>): TArray<string>;
  var
    FileName: string;
    Count: Integer;
  begin
    SetLength(Result, Length(Files));
    Count := 0;
    for FileName in Files do
    begin
      if IsDirectory(FileName) then
        Continue;
      Result[Count] := FileName;
      Inc(Count);
    end;
    SetLength(Result, Count);
  end;

var
  DOAdapter: TDataObjectAdapter;  // helper object used to access data object
begin
  DOAdapter := TDataObjectAdapter.Create(DataObj);
  try
    if DOAdapter.HasFormat(CF_HDROP) then
      DoLoad(StripDirectories(DOAdapter.GetHDROPFileNames))
    else if DOAdapter.HasFormat(CF_FILENAMEW) then
      // Load data from file: we know it is not a directory since this method
      // is only called for valid data objects
      DoLoad(DOAdapter.ReadDataAsUnicodeText(CF_FILENAMEW))
    else if DOAdapter.HasFormat(CF_FILENAMEA) then
      // Load data from file: we know it is not a directory since this method
      // is only called for valid data objects
      DoLoad(DOAdapter.ReadDataAsAnsiText(CF_FILENAMEA))
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

  function HasTrueFiles(const Files: TArray<string>): Boolean;
  var
    FileName: string;
  begin
    Result := False;
    for FileName in Files do
      if not IsDirectory(FileName) then
        Exit(True);
  end;

var
  DOAdapter: TDataObjectAdapter;  // helper object used to access data object
begin
  DOAdapter := TDataObjectAdapter.Create(DataObj);
  try
    Result := DOAdapter.HasFormat(CF_UNICODETEXT)
      or DOAdapter.HasFormat(CF_TEXT)
      or (DOAdapter.HasFormat(CF_HDROP)
        and HasTrueFiles(DOAdapter.GetHDROPFileNames))
      or
        (DOAdapter.HasFormat(CF_FILENAMEW)
        and not IsDirectory(DOAdapter.ReadDataAsUnicodeText(CF_FILENAMEW)))
      or
        (DOAdapter.HasFormat(CF_FILENAMEA)
        and not IsDirectory(DOAdapter.ReadDataAsAnsiText(CF_FILENAMEA)))
  finally
    FreeAndNil(DOAdapter);
  end;
end;

procedure TMainForm.lblOptionsHideClick(Sender: TObject);
begin
  actOptionsBar.Execute;
end;

procedure TMainForm.lblOptionsHideMouseEnter(Sender: TObject);
begin
  lblOptionsHide.Font.Color := cpgrpOptions.ChevronHotColor;
end;

procedure TMainForm.lblOptionsHideMouseLeave(Sender: TObject);
begin
  lblOptionsHide.Font.Color := cpgrpOptions.ChevronColor;
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
  edHTML.Text := fDocument.HilitedCode;
end;

end.

