{
 * UWBContainer.pas
 *
 * Class that hosts the IE web browser control and enables both direct loading
 * of browser's HTML and customisation of the user interface.
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
 * The Original Code is UWBContainer.pas
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


unit UWBContainer;


interface


uses
  // Delphi
  SysUtils, Classes, Windows, ActiveX, ShDocVw,
  // Project
  UNulWBContainer, IntfUIHandlers;


type

  {
  TWBTranslateEvent:
    Type of event triggered when a key is pressed in the web browser control.
    The program decides whether to handle (translate) the keypress itself or
    allow the web browser to handle it.
      @param Sender [in] Object triggering event.
      @param Msg [in] Windows message record identifying the message that
        triggered the event. This may be zeroed if there was no such message.
      @param CmdID [in] Browser command that normally occurs in response to the
        event. This value may be zero if there is no related command.
      @param Handled [in/out] Set false when the event handler is called. Set to
        true of the program handles (translates) the keypress and leave false to
        let the web browser handle it. Keypresses can be supressed by setting
        Handled to true and doing nothing with the key press.
  }
  TWBTranslateEvent = procedure(Sender: TObject;
    const Msg: TMSG; const CmdID: DWORD; var Handled: Boolean) of object;

  {
  TWBContainer:
    Provides a container for a web browser control, customises its UI and loads
    HTML into the control.
  }
  TWBContainer = class(TNulWBContainer, IDocHostUIHandler, IOleClientSite)
  private // properties
    fUseCustomCtxMenu: Boolean;
      {Whether browser control displays custom context menu}
    fShowScrollBars: Boolean;
      {Whether browser control displays scroll bars}
    fShow3DBorder: Boolean;
      {Whether browser control displays 3D border}
    fAllowTextSelection: Boolean;
      {Whether user can select text in browser control}
    fCSS: string;
      {Default cascading style sheet applied by browser control to documents}
    fHostedBrowser: TWebBrowser;
      {Reference to hosted browser control}
    fDropTarget: IDropTarget;
      {Reference to drop target handler object}
    fOnTranslateAccel: TWBTranslateEvent;
      {OnTranslateAccel event handler}
  private
    procedure NavigateToURL(const URL: string);
      {Navigates to a document at a specified URL.
        @param URL [in] Full URL of the document.
      }
    procedure LoadFromStream(const Stm: TStream);
      {Loads and displays valid HTML document from the current location in a
      stream.
        @param Stream [in] Stream containing the HTML document.
      }
    procedure LoadDocumentFromStream(const Stream: TStream);
      {Updates the web browser's current document from HTML read from stream.
        @param Stream [in] Stream containing valid HTML source code.
      }
    procedure WaitForDocToLoad;
      {Waits for a document to complete loading.
      }
  protected
    { Re-implemented IDocHostUIHandler methods }
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown;
      const pdispReserved: IDispatch): HResult; stdcall;
      {Called by browser when about to display a context menu. We change
      behaviour as required by relevant property values.
        @param dwID [in] Specifies identifier of the shortcut menu to be
          displayed.
        @param ppt [in] Pointer screen coordinates for the menu.
        @param pcmdtReserved [in] Not used.
        @param pdispReserved [in] IDispatch interface of HTML object under
          mouse.
        @return S_OK to prevent IE displaying its menu or S_FALSE to enable the
          IE menu.
      }
    function GetHostInfo(var pInfo: TDocHostUIInfo): HResult; stdcall;
      {Called by browser to get UI capabilities. We configure the required UI
      appearance per relevant property values.
        @param pInfo [in] Reference to structure that we fill in to configure
          appearance of browser.
        @return S_OK to show we handled OK.
      }
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HResult; stdcall;
      {Notifies browser control of any drag drop handler object assigned to
      DropTarget property.
        @param pDropTarget [in] Not used.
        @param ppDropTarget [out] Set to object assigned to DropTarget property.
        @return E_FAIL if DropTarget is nil or S_OK if DropTarget is assigned.
      }
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HResult; stdcall;
      {Called by browser when a key press is received. We trigger
      OnTranslateAccel event to filter out key presses not to be handled by
      browser.
        @param lpMsg [in] Pointer to structure that specifies message to be
          translated.
        @param pguidCmdGroup [in] Not used.
        @param nCmdID [in] Command identifier.
        @return S_OK to prevent IE handling message or S_FALSE to allow it.
      }
  public
    constructor Create(const HostedBrowser: TWebBrowser);
      {Class constructor. Creates object that hosts a web browser control.
        @param HostedBrowser [in] Browser control this object is to host.
      }
    procedure LoadFromString(const HTML: string; const Encoding: TEncoding);
      {Loads and displays valid HTML source from a string.
        @param HTML [in] String containing the HTML source.
        @param Encoding [in] Document encoding.
      }
    procedure EmptyDocument;
      {Creates an empty document. This method guarantees that the browser
      contains a valid document object. The browser displays a blank page.
      }
    property HostedBrowser: TWebBrowser
      read fHostedBrowser;
      {Reference to hosted browser control}
    property UseCustomCtxMenu: Boolean
      read fUseCustomCtxMenu write fUseCustomCtxMenu default False;
      {Indicates whether browser control is to use custom context menus (true)
      or default context menus (false). When the property is true the browser
      will display any popup menu assigned to its PopupMenu property. If that
      property is nil then no context menu is displayed}
    property Show3DBorder: Boolean
      read fShow3DBorder write fShow3DBorder default True;
      {Indicates whether or not browser control should display 3D borders when a
      document is loaded}
    property ShowScrollBars: Boolean
      read fShowScrollBars write fShowScrollBars default True;
      {Indicates whether or not browser control should display vertical
      scrollbars}
    property AllowTextSelection: Boolean
      read fAllowTextSelection write fAllowTextSelection default True;
      {Indicates whether user can select text in the browser control}
    property CSS: string
      read fCSS write fCSS;
      {Default cascading style sheet that is to be applied to documents}
    property DropTarget: IDropTarget
      read fDropTarget write fDropTarget;
      {Reference to a drop target object that controls browser's drag drop
      functionality. When this property is nil the browser performs its default
      drag-drop operations}
    property OnTranslateAccel: TWBTranslateEvent
      read fOnTranslateAccel write fOnTranslateAccel;
      {Event triggered when browser receives a key press. Handler determines
      whether to handle this key press and sets event handler's Handled
      parameter true if so, thus inhibiting the browser from handling it}
  end;


implementation


uses
  // Delphi
  StrUtils, Themes, Forms,
  // Project
  UUtils;


{ TWBContainer }

constructor TWBContainer.Create(const HostedBrowser: TWebBrowser);
  {Class constructor. Creates object that hosts a web browser control.
    @param HostedBrowser [in] Browser control this object is to host.
  }
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
  {Creates an empty document. This method guarantees that the browser contains a
  valid document object. The browser displays a blank page.
  }
begin
  // Load the special blank document
  NavigateToURL('about:blank');
end;

function TWBContainer.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HResult;
  {Notifies browser control of any drag drop handler object assigned to
  DropTarget property.
    @param pDropTarget [in] Not used.
    @param ppDropTarget [out] Set to object assigned to DropTarget property.
    @return E_FAIL if DropTarget is nil or S_OK if DropTarget is assigned.
  }
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
  {Called by browser to get UI capabilities. We configure the required UI
  appearance per relevant property values.
    @param pInfo [in] Reference to structure that we fill in to configure
      appearance of browser.
    @return S_OK to show we handled OK.
  }
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
    if ThemeServices.ThemesEnabled then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_THEME
    else if ThemeServices.ThemesAvailable then
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
  {Updates the web browser's current document from HTML read from stream.
    @param Stream [in] Stream containing valid HTML source code.
  }
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
  {Loads and displays valid HTML document from the current location in a stream.
    @param Stream [in] Stream containing the HTML document.
  }
begin
  // Must read into existing document: we create a new empty one before loading
  EmptyDocument;
  LoadDocumentFromStream(Stm);
end;

procedure TWBContainer.LoadFromString(const HTML: string;
  const Encoding: TEncoding);
  {Loads and displays valid HTML source from a string.
    @param HTML [in] String containing the HTML source.
    @param Encoding [in] Document encoding.
  }
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
  {Navigates to a document at a specified URL.
    @param URL [in] Full URL of the document.
  }
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
  {Called by browser when about to display a context menu. We change behaviour
  as required by relevant property values.
    @param dwID [in] Specifies identifier of the shortcut menu to be displayed.
    @param ppt [in] Pointer screen coordinates for the menu.
    @param pcmdtReserved [in] Not used.
    @param pdispReserved [in] IDispatch interface of HTML object under mouse.
    @return S_OK to prevent IE displaying its menu or S_FALSE to enable the IE
      menu.
  }
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
  {Called by browser when a key press is received. We trigger OnTranslateAccel
  event to filter out key presses not to be handled by browser.
    @param lpMsg [in] Pointer to structure that specifies message to be
      translated.
    @param pguidCmdGroup [in] Not used.
    @param nCmdID [in] Command identifier.
    @return S_OK to prevent IE handling message or S_FALSE to allow it.
  }
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
  {Waits for a document to complete loading.
  }
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

