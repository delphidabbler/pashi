{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Interfaces, records and constants used when customising a hosted the IE
 * WebBrowser Control. The content of the unit is based on Microsoft UI
 * documentation from MSDN.
}


unit IntfUIHandlers;


interface


uses
  // Delphi
  Winapi.Windows,
  Winapi.ActiveX;


const

  // Set of flags that indicate the capabilities of an IDocHostUIHandler
  // implementation. They are used in a TDocHostUIInfo record.
  DOCHOSTUIFLAG_DIALOG = $00000001;
  DOCHOSTUIFLAG_DISABLE_HELP_MENU = $00000002;
  DOCHOSTUIFLAG_NO3DBORDER = $00000004;
  DOCHOSTUIFLAG_SCROLL_NO = $00000008;
  DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE = $00000010;
  DOCHOSTUIFLAG_OPENNEWWIN = $00000020;
  DOCHOSTUIFLAG_DISABLE_OFFSCREEN = $00000040;
  DOCHOSTUIFLAG_FLAT_SCROLLBAR = $00000080;
  DOCHOSTUIFLAG_DIV_BLOCKDEFAULT = $00000100;
  DOCHOSTUIFLAG_ACTIVATE_CLIENTHIT_ONLY = $00000200;
  DOCHOSTUIFLAG_OVERRIDEBEHAVIORFACTORY = $00000400;
  DOCHOSTUIFLAG_CODEPAGELINKEDFONTS = $00000800;
  DOCHOSTUIFLAG_URL_ENCODING_DISABLE_UTF8 = $00001000;
  DOCHOSTUIFLAG_URL_ENCODING_ENABLE_UTF8 = $00002000;
  DOCHOSTUIFLAG_ENABLE_FORMS_AUTOCOMPLETE = $00004000;
  DOCHOSTUIFLAG_ENABLE_INPLACE_NAVIGATION = $00010000;
  DOCHOSTUIFLAG_IME_ENABLE_RECONVERSION = $00020000;
  DOCHOSTUIFLAG_THEME = $00040000;
  DOCHOSTUIFLAG_NOTHEME = $00080000;
  DOCHOSTUIFLAG_NOPICS = $00100000;
  DOCHOSTUIFLAG_NO3DOUTERBORDER = $00200000;
  DOCHOSTUIFLAG_DISABLE_EDIT_NS_FIXUP = $00400000;
  DOCHOSTUIFLAG_LOCAL_MACHINE_ACCESS_CHECK = $00800000;
  DOCHOSTUIFLAG_DISABLE_UNTRUSTEDPROTOCOL = $01000000;
  DOCHOSTUIFLAG_HOST_NAVIGATES = $02000000;
  DOCHOSTUIFLAG_ENABLE_REDIRECT_NOTIFICATION = $04000000;
  DOCHOSTUIFLAG_USE_WINDOWLESS_SELECTCONTROL = $08000000;
  DOCHOSTUIFLAG_USE_WINDOWED_SELECTCONTROL = $10000000;
  DOCHOSTUIFLAG_ENABLE_ACTIVEX_INACTIVATE_MODE = $20000000;
  DOCHOSTUIFLAG_DPI_AWARE = $40000000;

  DOCHOSTUIFLAG_BROWSER = DOCHOSTUIFLAG_DISABLE_HELP_MENU
    or DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE;

  // Set of values used to indicate the proper action on a double-click event.
  // Used in a TDocHostUIInfo record. Later versions of the web browser control
  // ignore these values.
  DOCHOSTUIDBLCLK_DEFAULT = 0;
  DOCHOSTUIDBLCLK_SHOWPROPERTIES = 1;
  DOCHOSTUIDBLCLK_SHOWCODE = 2;

  // Values that that indicate the type of user interface. Used in
  // IDocHostUIHandler.ShowUI method.
  DOCHOSTUITYPE_BROWSE = 0;
  DOCHOSTUITYPE_AUTHOR = 1;

  // Browser context menu command ids.
  CONTEXT_MENU_DEFAULT = 0;
  CONTEXT_MENU_IMAGE = 1;
  CONTEXT_MENU_CONTROL = 2;
  CONTEXT_MENU_TABLE = 3;
  CONTEXT_MENU_TEXTSELECT = 4;
  CONTEXT_MENU_ANCHOR = 5;
  CONTEXT_MENU_UNKNOWN = 6;


type

  ///  <summary>Record used by the IDocHostUIHandler.GetHostInfo method to allow
  ///  MSHTML to retrieve information about the host's UI requirements.
  ///  </summary>
  TDocHostUIInfo = record
    cbSize: ULONG;
    dwFlags: DWORD;
    dwDoubleClick: DWORD;
    pchHostCss: PWChar;
    pchHostNS: PWChar;
  end;

  ///  <summary>Pointer to TDocHostUIInfo record.</summary>
  PDocHostUIInfo = ^TDocHostUIInfo;

  ///  <summary>This customisation interface enables an application hosting the
  ///  WebBrowser control or automating IE to replace the menus, toolbars, and
  ///  context menus used by MSHTML.</summary>
  IDocHostUIHandler = interface(IUnknown)
    ['{bd3f23c0-d43e-11cf-893b-00aa00bdce1a}']
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HResult;
      stdcall;
    function GetHostInfo(var pInfo: TDocHostUIInfo): HResult; stdcall;
    function ShowUI(const dwID: DWORD;
      const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow): HResult; stdcall;
    function HideUI: HResult; stdcall;
    function UpdateUI: HResult; stdcall;
    function EnableModeless(const fEnable: BOOL): HResult; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HResult; stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HResult; stdcall;
    function ResizeBorder(const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
      stdcall;
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HResult; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR; const dw: DWORD ): HResult;
      stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HResult; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HResult; stdcall;
    function TranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR;
      var ppchURLOut: POLESTR): HResult; stdcall;
    function FilterDataObject(const pDO: IDataObject;
      out ppDORet: IDataObject): HResult; stdcall;
  end;

  ///  <summary>Interface implemented by MSHTML to allow a host to set the
  ///  MSHTML IDocHostUIHandler interface.</summary>
  ICustomDoc = interface(IUnknown)
    ['{3050f3f0-98b5-11cf-bb82-00aa00bdce0b}']
    function SetUIHandler(const pUIHandler: IDocHostUIHandler): HResult;
      stdcall;
  end;


implementation

end.

