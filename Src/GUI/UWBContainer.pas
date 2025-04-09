{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Class that hosts the IE web browser control and enables both direct loading
 * of browser's HTML and customisation of the user interface.
}


unit UWBContainer;


interface


uses
  // Delphi
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.ActiveX,
  ShDocVw,
  // Project
  UNulWBContainer,
  IntfUIHandlers;


type

  ///  <summary>Type of event triggered when a key is pressed in the web browser
  ///  control.</summary>
  TWBTranslateEvent = procedure(Sender: TObject;
    const Msg: TMSG; const CmdID: DWORD; var Handled: Boolean) of object;

  ///  <summary>Provides a container for a web browser control, customises its
  ///  UI and loads HTML into the control.</summary>
  TWBContainer = class(TNulWBContainer, IDocHostUIHandler, IOleClientSite)
  private // properties
    fUseCustomCtxMenu: Boolean;
    fShowScrollBars: Boolean;
    fShow3DBorder: Boolean;
    fAllowTextSelection: Boolean;
    fCSS: string;
    fHostedBrowser: TWebBrowser;
    fDropTarget: IDropTarget;
    fOnTranslateAccel: TWBTranslateEvent;
  private
    procedure NavigateToURL(const URL: string);
    procedure LoadFromStream(const Stm: TStream);
    procedure LoadDocumentFromStream(const Stream: TStream);
    procedure WaitForDocToLoad;
  protected
    // Re-implemented IDocHostUIHandler methods
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown;
      const pdispReserved: IDispatch): HResult; stdcall;
    function GetHostInfo(var pInfo: TDocHostUIInfo): HResult; stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HResult; stdcall;
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HResult; stdcall;
  public
    constructor Create(const HostedBrowser: TWebBrowser);
    procedure LoadFromString(const HTML: string; const Encoding: TEncoding);
    procedure EmptyDocument;
    property HostedBrowser: TWebBrowser
      read fHostedBrowser;
    property UseCustomCtxMenu: Boolean
      read fUseCustomCtxMenu write fUseCustomCtxMenu default False;
    property Show3DBorder: Boolean
      read fShow3DBorder write fShow3DBorder default True;
    property ShowScrollBars: Boolean
      read fShowScrollBars write fShowScrollBars default True;
    property AllowTextSelection: Boolean
      read fAllowTextSelection write fAllowTextSelection default True;
    property CSS: string
      read fCSS write fCSS;
    property DropTarget: IDropTarget
      read fDropTarget write fDropTarget;
    property OnTranslateAccel: TWBTranslateEvent
      read fOnTranslateAccel write fOnTranslateAccel;
  end;


implementation


uses
  // Delphi
  System.StrUtils,
  Vcl.Themes,
  Vcl.Forms,
  // Project
  UUtils;


{ TWBContainer }

constructor TWBContainer.Create(const HostedBrowser: TWebBrowser);
begin
  inherited;
  // Set default property values
  fHostedBrowser := HostedBrowser;
  fUseCustomCtxMenu := False;
  fShowScrollBars := True;
  fShow3DBorder := True;
  fAllowTextSelection := True;
  fCSS := '';
end;

procedure TWBContainer.EmptyDocument;
begin
  // Load the special blank document
  NavigateToURL('about:blank');
end;

function TWBContainer.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HResult;
begin
  if Assigned(fDropTarget) then
  begin
    ppDropTarget := fDropTarget;
    Result := S_OK;
  end
  else
    Result := inherited GetDropTarget(pDropTarget, ppDropTarget);
end;

function TWBContainer.GetHostInfo(var pInfo: TDocHostUIInfo): HResult;
begin
  try
    ZeroMemory(@pInfo, SizeOf(TDocHostUIInfo));
    pInfo.cbSize := SizeOf(TDocHostUIInfo);
    // set dwFlags
    if not fShowScrollBars then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_SCROLL_NO;
    if not fShow3DBorder then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NO3DBORDER;
    if not fAllowTextSelection then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_DIALOG;
    if StyleServices.Enabled then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_THEME
    else if StyleServices.Available then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NOTHEME;
    // set CSS: must allocate space with task allocator
    // (browser frees this memory)
    pInfo.pchHostCss := TaskAllocWideString(fCSS);
    if not Assigned(pInfo.pchHostCss) then
      raise Exception.Create(
        'TWBContainer.GetHostInfo: Task allocator can''t allocate CSS string'
      );
    // Return S_OK to indicate we've made changes
    Result := S_OK;
  except
    // Return E_FAIL on error
    Result := E_FAIL;
  end;
end;

procedure TWBContainer.LoadDocumentFromStream(const Stream: TStream);
var
  PersistStreamInit: IPersistStreamInit;  // object used to load stream into doc
begin
  Assert(Assigned(fHostedBrowser.Document));
  // Get IPersistStreamInit interface on document object
  if fHostedBrowser.Document.QueryInterface(
    IPersistStreamInit, PersistStreamInit
  ) = S_OK then
  begin
    // Clear document
    if PersistStreamInit.InitNew = S_OK then
    begin
      // Load data from Stream into WebBrowser
      PersistStreamInit.Load(TStreamAdapter.Create(Stream));
      WaitForDocToLoad;
    end;
  end;
end;

procedure TWBContainer.LoadFromStream(const Stm: TStream);
begin
  // Must read into existing document: we create a new empty one before loading
  EmptyDocument;
  LoadDocumentFromStream(Stm);
end;

procedure TWBContainer.LoadFromString(const HTML: string;
  const Encoding: TEncoding);
var
  StringStream: TStringStream;  // stream onto string
begin
  StringStream := TStringStream.Create(HTML, Encoding);
  try
    LoadFromStream(StringStream);
  finally
    StringStream.Free;
  end;
end;

procedure TWBContainer.NavigateToURL(const URL: string);
var
  Flags: OleVariant;    // flags that determine action
begin
  // Prevent recording in history and caching of local files
  Flags := navNoHistory;
  if AnsiStartsText('res://', URL) or AnsiStartsText('file://', URL)
    or AnsiStartsText('about:', URL) or AnsiStartsText('javascript:', URL)
    or AnsiStartsText('mailto:', URL) then
    Flags := Flags or navNoReadFromCache or navNoWriteToCache;
  // Do the navigation
  fHostedBrowser.Navigate(WideString(URL), Flags);
  WaitForDocToLoad;
end;

function TWBContainer.ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
  const pcmdtReserved: IInterface; const pdispReserved: IDispatch): HResult;
begin
  if fUseCustomCtxMenu then
  begin
    Result := S_OK;     // tells IE not to display its context menu
    if Assigned(HostedBrowser.PopupMenu) then
      HostedBrowser.PopupMenu.Popup(ppt.X, ppt.Y);
  end
  else
    Result := S_FALSE;  // tells IE to display its context menu
end;

function TWBContainer.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HResult;
var
  Handled: Boolean; // flag set true by in if event handler handles key
  Msg: TMsg;        // Windows message record for given message
begin
  // Assume not handled by event handler
  Handled := False;
  // Call event handler if set
  if Assigned(fOnTranslateAccel) then
  begin
    // create copy of message: set all fields zero if lpMsg is nil
    if Assigned(lpMsg) then
      Msg := lpMsg^
    else
      FillChar(Msg, SizeOf(Msg), 0);
    // trigger event
    fOnTranslateAccel(Self, Msg, nCmdID, Handled);
  end;
  // If event handler handled accelerator then return S_OK to stop web browser
  // handling it otherwise return S_FALSE so browser will handle it
  if Handled then
    Result := S_OK
  else
    Result := S_FALSE;
end;

procedure TWBContainer.WaitForDocToLoad;
begin
  // Loop until browser's ReadyState indicates completion
  // NOTE: do not call this method in a FormCreate event handler since the
  // browser will never reach this state - use a FormShow event handler instead.
  while fHostedBrowser.ReadyState <> READYSTATE_COMPLETE do
  begin
    Application.ProcessMessages;
    Sleep(0);
  end;
end;

end.

