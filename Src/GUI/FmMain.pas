{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2021, Peter Johnson (www.delphidabbler.com).
 *
 * Application's main form. Handles main user inteface interaction.
}


unit FmMain;


interface

uses
  // Delphi
  ExtActns, ImgList, Controls, ActnList, StdActns, Classes, Menus, Forms,
  ExtCtrls, StdCtrls, OleCtrls, SHDocVw, ComCtrls, ToolWin, ActiveX, Windows,
  // 3rd Party
  PJWdwState,
  // Project
  IntfDropDataHandler, UOptions, UDocument, UWBContainer, UInputData,
  FrOptions.UBase, FrOptions.UDocType, FrOptions.ULineStyle, FrOptions.UCSS,
  FrOptions.UMisc;


type

  TOptionFrameCallback = reference to procedure(Frame: TBaseOptionsFrame);

  ///  <summary>
  ///  Application's main form and user interaction.
  ///  </summary>
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
    miUserGuide: TMenuItem;
    actUserGuide: TAction;
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
    procedure actRestoreDefaultsExecute(Sender: TObject);
    procedure actApplyExecute(Sender: TObject);
    procedure actOptionsBarExecute(Sender: TObject);
    procedure actOptionsBarUpdate(Sender: TObject);
    procedure lblOptionsHideClick(Sender: TObject);
    procedure lblOptionsHideMouseEnter(Sender: TObject);
    procedure lblOptionsHideMouseLeave(Sender: TObject);
    procedure actUserGuideExecute(Sender: TObject);
    procedure actUserGuideUpdate(Sender: TObject);
  strict private
    type
      TLoadProc = reference to procedure;
  private
    fOptions: TOptions;
    fWdwState: TPJWdwState;
    fDocLoaded: Boolean;
    fDocument: TDocument;
    fDropTarget: IDropTarget;
    fWBContainer: TWBContainer;
    fBusy: Boolean;
    fForcedActionUpdate: Boolean;

    procedure UpdateDisplay;
    procedure Render;
    procedure LoadText(const Text: string);
    procedure LoadFiles(const FileNames: TArray<string>);
    procedure LoadFile(const FileName: string);
    procedure InternalLoad(const Callback: TLoadProc);
    ///  <summary>Handles key events in web browser control</summary>
    procedure TranslateAccelHandler(Sender: TObject; const Msg: TMSG;
      const CmdID: DWORD; var Handled: Boolean);
    ///  <summary>Checks if a data object is of a kind supported by the program.
    ///  </summary>
    function IsValidDataObj(const DataObj: IDataObject): Boolean;
    procedure UpdateAllActions;
    procedure Busy(const Flag: Boolean);
    ///  <summary>Checks if a document is loaded in web browser control.
    ///  </summary>
    function DocHasContent: Boolean;
    procedure EnumOptionFrames(const Callback: TOptionFrameCallback);
    procedure DisplayOptions;
  protected
    { IDropDataHandler methods }
    function CanAccept(const DataObj: IDataObject): Boolean;
    procedure HandleData(const DataObj: IDataObject);
    function DropEffect(const Shift: TShiftState;
      const AllowedEffects: TDragDropEffects): TDragDropEffect;
    procedure IDropDataHandler.ExceptionHandler = DragDropExceptionHandler;
    procedure DragDropExceptionHandler(const E: TObject);
  end;


var
  MainForm: TMainForm;


implementation


uses
  // Delphi
  SysUtils, ComObj, Messages,
  // Project
  UClipFmt, UConfigFiles, UDataObjectAdapter, UOutputData, UUtils, UDropTarget,
  UUserGuide, UVersionInfo;


{$R *.dfm}


const
  // Default style sheet for HTML documents
  cBodyCSS = 'body {margin:0;font-size:9pt;font-family:"Arial";}';

{ TMainForm }

procedure TMainForm.actAboutExecute(Sender: TObject);
begin
  Application.MessageBox(
    PChar(
      Format('PasHiGUI %s.', [GetFileVersionStr])
        + #10#10
        + 'A GUI front end for the PasHi Syntax Highlighter v2.'
        + #10#10
        + GetLegalCopyright
        + #10#10
        + 'Released under the terms of the Mozilla Public License v2.0. '
        + 'See the file LICENSE.md for full details.'
    ),
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
    if fDocLoaded then
      Render;
  finally
    Busy(False);
  end;
end;

procedure TMainForm.actCopyExecute(Sender: TObject);
begin
  // Document saves to IOutputData object that writes clipboard
  fDocument.Save(TOutputDataFactory.CreateForClipboard);
end;

procedure TMainForm.actCopyUpdate(Sender: TObject);
begin
  actCopy.Enabled := DocHasContent;
end;

procedure TMainForm.actOpenAccept(Sender: TObject);
var
  Files: TArray<string>;
  Idx: Integer;
begin
  SetLength(Files, actOpen.Dialog.Files.Count);
  for Idx := 0 to Pred(actOpen.Dialog.Files.Count) do
    Files[Idx] := actOpen.Dialog.Files[Idx];
  if Length(Files) = 0 then
    Exit;
  LoadFiles(Files);
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
  actOptionsBar.Caption := Captions[actOptionsBar.Checked];
  actOptionsBar.Hint := Captions[actOptionsBar.Checked];
end;

procedure TMainForm.actPasteExecute(Sender: TObject);
var
  CBData: IDataObject;  // object storing clipboard data
begin
  if not Succeeded(OleGetClipboard(CBData)) then
    Exit;
  HandleData(CBData);
end;

procedure TMainForm.actPasteUpdate(Sender: TObject);
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
begin
  // Document saves to IOutputData object that writes to a file
  fDocument.Save(TOutputDataFactory.CreateForFile(actSaveAs.Dialog.FileName));
end;

procedure TMainForm.actSaveAsUpdate(Sender: TObject);
begin
  actSaveAs.Enabled := DocHasContent;
end;

procedure TMainForm.actUserGuideExecute(Sender: TObject);
begin
  TUserGuide.Display;
end;

procedure TMainForm.actUserGuideUpdate(Sender: TObject);
begin
  actUserGuide.Enabled := TUserGuide.CanDisplay;
end;

procedure TMainForm.alMainUpdate(Action: TBasicAction; var Handled: Boolean);
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
begin
  Result := fDocLoaded;
end;

procedure TMainForm.DragDropExceptionHandler(const E: TObject);
begin
  Application.HandleException(E);
end;

function TMainForm.DropEffect(const Shift: TShiftState;
  const AllowedEffects: TDragDropEffects): TDragDropEffect;
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

  fWdwState := TPJWdwState.CreateStandAlone(Self);
  fWdwState.Options := [woFitWorkArea, woIgnoreState];
  fWdwState.IniFileName := TConfigFiles.UserConfigDir + '\gui-state';
  fWdwState.Section := 'MainWindow';
  fWdwState.Restore;

  fOptions := TOptions.Create;
  DisplayOptions;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  fWdwState.Save;
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
begin
  // Select rendered page by default
  pcMain.ActivePage := tsRendered;
  // Display empty document
  fWBContainer.EmptyDocument;
  // Set state of Show/Hide Options action
  actOptionsBar.Checked := pnlOptions.Visible;
end;

procedure TMainForm.HandleData(const DataObj: IDataObject);

  function StripDirectories(const FileNames: TArray<string>): TArray<string>;
  var
    FileName: string; // each file name in array
    Count: Integer;   // number of true files in array
  begin
    SetLength(Result, Length(FileNames));
    Count := 0;
    for FileName in FileNames do
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
      LoadFiles(StripDirectories(DOAdapter.GetHDROPFileNames))
    else if DOAdapter.HasFormat(CF_FILENAMEW) then
      // Load data from file: we know it is not a directory since this method
      // is only called for valid data objects
      LoadFile(DOAdapter.ReadDataAsUnicodeText(CF_FILENAMEW))
    else if DOAdapter.HasFormat(CF_FILENAMEA) then
      // Load data from file: we know it is not a directory since this method
      // is only called for valid data objects
      LoadFile(DOAdapter.ReadDataAsAnsiText(CF_FILENAMEA))
    else if DOAdapter.HasFormat(CF_UNICODETEXT) then
      LoadText(DOAdapter.ReadDataAsUnicodeText(CF_UNICODETEXT))
    else if DOAdapter.HasFormat(CF_TEXT) then
      LoadText(DOAdapter.ReadDataAsAnsiText(CF_TEXT))
    else
      raise Exception.Create('Expected data format not available');
  finally
    FreeAndNil(DOAdapter);
  end;
end;

procedure TMainForm.InternalLoad(const Callback: TLoadProc);
begin
  Busy(True);
  try
    Callback;
    Render;
    fDocLoaded := True;
  finally
    Busy(False);
  end;
end;

function TMainForm.IsValidDataObj(const DataObj: IDataObject): Boolean;

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

procedure TMainForm.LoadFile(const FileName: string);
begin
  LoadFiles(TArray<string>.Create(FileName));
end;

procedure TMainForm.LoadFiles(const FileNames: TArray<string>);
begin
  InternalLoad(
    procedure
    begin
      fDocument.InputFiles := FileNames;
    end
  );
end;

procedure TMainForm.LoadText(const Text: string);
begin
  InternalLoad(
    procedure
    begin
      fDocument.InputData := TInputDataFactory.CreateFromText(Text);
    end
  );
end;

procedure TMainForm.pcMainMouseLeave(Sender: TObject);
begin
  pcMain.Hint := '';
end;

procedure TMainForm.Render;
begin
  if fOptions.GetParamAsStr('doc-type') = 'fragment' then
    fDocument.OutputType := doFragment
  else
    fDocument.OutputType := doComplete;
  fDocument.Highlight(fOptions);
  UpdateDisplay;
end;

procedure TMainForm.TranslateAccelHandler(Sender: TObject; const Msg: TMSG;
  const CmdID: DWORD; var Handled: Boolean);

  procedure PostKeyPress(const DownMsg, UpMsg: UINT);
  begin
    PostMessage(Handle, DownMsg, Msg.wParam, Msg.lParam);
    PostMessage(Handle, UpMsg, Msg.wParam, Msg.lParam);
  end;

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
begin
  fWBContainer.LoadFromString(fDocument.DisplayHTML, TEncoding.UTF8);
  edHTML.Text := fDocument.HilitedCode;
end;

end.

