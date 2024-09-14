{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2016, Peter Johnson (www.delphidabbler.com).
 *
 * Defines a class that provides a "do-nothing" implementation of the
 * IDocHostUIHandler interface. All methods are "stubbed out" to return values
 * that will make no changes to the web browser control if this class is
 * assigned as the browser's UI handler.
}


unit UNulWBContainer;


interface


uses
  // Delphi
  Winapi.Windows,
  Winapi.ActiveX,
  SHDocVw,
  // Project
  IntfUIHandlers;


type

  ///  <summary>Do nothing non reference counted implementation of
  ///  IDocHostUIHandler and IOleClientSite.</summary>
  ///  <remarks>Designed for use as a base class for classes that host and
  ///  customise web browser controls. The effect of this class on the browser
  ///  control is neutral.</remarks>
  TNulWBContainer = class(TObject,
    IUnknown, IOleClientSite, IDocHostUIHandler
  )
  private
    fHostedBrowser: TWebBrowser;
    procedure SetBrowserOleClientSite(const Site: IOleClientSite);
  protected
    // IUnknown - non reference counted implementation
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // IOleClientSite
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
    { IDocHostUIHandler }
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
  public
    constructor Create(const HostedBrowser: TWebBrowser);
    destructor Destroy; override;
    property HostedBrowser: TWebBrowser read fHostedBrowser;
  end;


implementation


uses
  // Delphi
  System.SysUtils;


{ TNulWBContainer }

constructor TNulWBContainer.Create(const HostedBrowser: TWebBrowser);
begin
  Assert(Assigned(HostedBrowser));
  inherited Create;
  fHostedBrowser := HostedBrowser;
  SetBrowserOleClientSite(Self as IOleClientSite);
end;

destructor TNulWBContainer.Destroy;
begin
  SetBrowserOleClientSite(nil);
  inherited;
end;

function TNulWBContainer.EnableModeless(const fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.FilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HResult;
begin
  ppDORet := nil;
  Result := S_FALSE;
end;

function TNulWBContainer.GetContainer(
  out container: IOleContainer): HResult;
begin
  container := nil;
  Result := E_NOINTERFACE;
end;

function TNulWBContainer.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HResult;
begin
  ppDropTarget := nil;
  Result := E_FAIL;
end;

function TNulWBContainer.GetExternal(out ppDispatch: IDispatch): HResult;
begin
  ppDispatch := nil;
  Result := E_FAIL;
end;

function TNulWBContainer.GetHostInfo(var pInfo: TDocHostUIInfo): HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.GetMoniker(dwAssign, dwWhichMoniker: Integer;
  out mk: IMoniker): HResult;
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

function TNulWBContainer.GetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HResult;
begin
  pchKey := nil;
  Result := E_FAIL;
end;

function TNulWBContainer.HideUI: HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.OnDocWindowActivate(
  const fActivate: BOOL): HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.OnFrameWindowActivate(
  const fActivate: BOOL): HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.OnShowWindow(fShow: BOOL): HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNulWBContainer.RequestNewObjectLayout: HResult;
begin
  Result := E_NOTIMPL;
end;

function TNulWBContainer.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
begin
  Result := S_FALSE;
end;

function TNulWBContainer.SaveObject: HResult;
begin
  Result := S_OK;
end;

procedure TNulWBContainer.SetBrowserOleClientSite(
  const Site: IOleClientSite);
var
  OleObj: IOleObject; // browser object's interface used to register client site
begin
  Assert((Site = Self as IOleClientSite) or (Site = nil));
  if not Supports(
    fHostedBrowser.DefaultInterface, IOleObject, OleObj
  ) then
    raise Exception.Create(
      'Browser''s Default interface does not support IOleObject'
    );
  OleObj.SetClientSite(Site);
end;

function TNulWBContainer.ShowContextMenu(const dwID: DWORD;
  const ppt: PPOINT; const pcmdtReserved: IInterface;
  const pdispReserved: IDispatch): HResult;
begin
  Result := S_FALSE
end;

function TNulWBContainer.ShowObject: HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.ShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HResult;
begin
  Result := S_FALSE;
end;

function TNulWBContainer.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HResult;
begin
  ppchURLOut := nil;
  Result := S_FALSE;
end;

function TNulWBContainer.UpdateUI: HResult;
begin
  Result := S_OK;
end;

function TNulWBContainer._AddRef: Integer;
begin
  Result := -1;
end;

function TNulWBContainer._Release: Integer;
begin
  Result := -1;
end;

end.

