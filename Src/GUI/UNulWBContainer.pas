{
 * UNulWBContainer.pas
 *
 * Defines a class that provides a "do-nothing" implementation of the
 * IDocHostUIHandler interface. All methods are "stubbed out" to return values
 * that will make no changes to the web browser control if this class is
 * assigned as the browser's UI handler.
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
 * The Original Code is UNulWBContainer.pas
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


unit UNulWBContainer;


interface


uses
  // Delphi
  Windows, ActiveX, SHDocVw,
  // Project
  IntfUIHandlers;


type

  {
  TNulWBContainer:
    "Do nothing" non reference counted implementation of IDocHostUIHandler and
    IOleClientSite that is designed for use as a base class for classes that
    host and customise web browser controls. The effect of this class, on the
    browser control is neutral.
  }
  TNulWBContainer = class(TObject,
    IUnknown, IOleClientSite, IDocHostUIHandler
  )
  private
    fHostedBrowser: TWebBrowser;
      {Reference to hosted browser control}
    procedure SetBrowserOleClientSite(const Site: IOleClientSite);
      {Registers / unregisters object as container (client site) of web browser
      control.
        @param Site [in] Self to register or nil to unregister.
      }
  protected
    { IUnknown - non reference counted implementation }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      {Determines if this object supports an interface. Has no effect on
      reference count.
        @param IID [in] Required interface.
        @param Obj [out] Reference to object that supports interface.
        @return S_OK if interface supported, E_NOINTERFACE if not.
      }
    function _AddRef: Integer; stdcall;
      {Called by Delphi when interface is referenced. Does not increase
      reference count in this implementation.
        @return -1.
      }
    function _Release: Integer; stdcall;
      {Called by Delphi when interface is dereferenced. Does not decrease
      reference count in this implementation.
        @return -1.
      }
    { IOleClientSite }
    function SaveObject: HResult; stdcall;
      {Saves the object associated with the client site. No action taken.
        @return S_OK to inform we have responded.
      }
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
      {Returns a moniker to an object's client site. We don't implement
      monikers.
        @param dwAssign [in] Not used.
        @param dwWhichMoniker [in] Not used.
        @param mk [out] Set to nil.
        @return E_NOTIMPL to indicate method is not implemented.
      }
    function GetContainer(out container: IOleContainer): HResult; stdcall;
      {Returns a pointer to the container's IOleContainer interface if
      supported. We don't support the interface.
        @param container [out] Set to nil.
        @return E_NOINTERFACE to indicate we don't support IOleContainer.
      }
    function ShowObject: HResult; stdcall;
      {Tells the container to position the object so it is visible to the user.
      No action taken.
        @return S_OK to inform we have responded.
      }
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
      {Notifies a container when an embedded object's window is about to become
      visible or invisible. No action taken.
        @param fShow [in] Not used.
        @return S_OK to inform we have responded.
      }
    function RequestNewObjectLayout: HResult; stdcall;
      {Asks container to allocate more or less space for displaying an embedded
      object. We don't support layout requests.
        @return E_NOTIMPL to indicate layout requests not implemented.
      }
    { IDocHostUIHandler }
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HResult;
      stdcall;
      {Called when browser ready to display its context menu. Allows browser to
      display default menu.
        @param dwID [in] Not used.
        @param ppt [in] Not used.
        @param pcmdtReserved [in] Not used.
        @param pdispReserved [in] Not used.
        @return S_FALSE to indicate we did not display any UI.
      }
    function GetHostInfo(var pInfo: TDocHostUIInfo): HResult; stdcall;
      {Retrieves UI capabilities. No action taken.
        @param pInfo [in/out] Not used.
        @return S_OK to indicate success.
      }
    function ShowUI(const dwID: DWORD;
      const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow): HResult; stdcall;
      {Called to enable host to modify IE menus, toolbars etc. No changes made.
        @param dwID [in] Not used.
        @param pActiveObject [in] Not used.
        @param pCommandTarget [in] Not used.
        @param pDoc [in] Not used.
        @return S_OK to indicate we displayed own UI (required since browser is
          not displaying its UI).
      }
    function HideUI: HResult; stdcall;
      {Called when IE menus, toolbars etc are to be removed. No action taken.
        @return S_OK to indicate we handled successfully.
      }
    function UpdateUI: HResult; stdcall;
      {Called when menus, toolbars etc need to be updated. No action taken.
        @return S_OK to indicate we handled successfully.
      }
    function EnableModeless(const fEnable: BOOL): HResult; stdcall;
      {Called when a modal UI is displayed by IE. No action taken.
        @param fEnable [in] Not used.
        @return S_OK to indicate we handled successfully.
      }
    function OnDocWindowActivate(const fActivate: BOOL): HResult; stdcall;
      {Called when the document window is activated/deactivated. No action
      taken.
        @param fActivate [in] Not used.
        @return S_OK to indicate we handled successfully.
      }
    function OnFrameWindowActivate(const fActivate: BOOL): HResult; stdcall;
      {Called when the top level frame window is activated/deactivated. No
      action taken.
        @param fActivate [in] Not used.
        @return S_OK to indicate we handled successfully.
      }
    function ResizeBorder(const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
      stdcall;
      {Called when frame or document window changing. No action taken.
        @param prcBorder [in] Not used.
        @param pUIWindow [in] Not used.
        @param fFrameWindow [in] Not used.
        @return S_FALSE to indicate we did nothing.
      }
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HResult; stdcall;
      {Called when accelerator keys are used to enable behaviour to be changed.
      No changes are made.
        @param lpMsg [in] Not used.
        @param pguidCmdGroup [in] Not used.
        @param nCmdID [in] Not used.
        @return S_FALSE to indicate no translations are made.
      }
    function GetOptionKeyPath(var pchKey: POLESTR; const dw: DWORD ): HResult;
      stdcall;
      {Called when IE retrieves data from registry and enables sub key path to
      be changed. Default registry settings not changed.
        @param pchKey [in/out] Set to nil to indicate usage of default registry
          settings.
        @param dw [in] Not used.
        @return E_FAIL to use default registry setting.
      }
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HResult; stdcall;
      {Called when browser is used as drop target to enable alternative drop
      target interface to be displayed. No alternative drop target is supplied.
        @param pDropTarget [in] Not used.
        @param ppDropTarget [out] Set to nil to indicate no alternative drop
          target.
        @return E_FAIL to indicate to alternative drop target supplied.
      }
    function GetExternal(out ppDispatch: IDispatch): HResult; stdcall;
      {Called to get host's implementation of browser's external object to
      enable browser (e.g. scripts) to call host's methods. No object is
      exposed.
        @param ppDispatch [out] Set to nil to indicate no external object
          exposed.
        @return E_FAIL to indicate to external object.
      }
    function TranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR;
      var ppchURLOut: POLESTR): HResult; stdcall;
      {Gives an opportunity to modify the URL to be loaded. No changes made.
        @param dwTranslate [in] Not used.
        @param pchURLIn [in] Not used.
        @param ppchURLOut [in/out] Set to nil to indicate no translation.
        @return S_FALSE to indicate URL not translated.
      }
    function FilterDataObject(const pDO: IDataObject;
      out ppDORet: IDataObject): HResult; stdcall;
      {Called to enable host to block or add additional clipboard objects. No
      changes made.
        @param pDO [in] Not used.
        @param ppDORet [out] Set to nil to indicate no additional formats.
        @return S_FALSE to indicate no additional formats.
      }
  public
    constructor Create(const HostedBrowser: TWebBrowser);
      {Class constructor. Sets up object as container for a browser control.
        @param WebBrowser Contained browser control.
      }
    destructor Destroy; override;
      {Class destructor. Unregisters object as browser control container and
      tears down object.
      }
    property HostedBrowser: TWebBrowser read fHostedBrowser;
      {Reference to hosted browser control}
  end;


implementation


uses
  // Delphi
  SysUtils;


{ TNulWBContainer }

constructor TNulWBContainer.Create(const HostedBrowser: TWebBrowser);
  {Class constructor. Sets up object as container for a browser control.
    @param WebBrowser Contained browser control.
  }
begin
  Assert(Assigned(HostedBrowser));
  inherited Create;
  fHostedBrowser := HostedBrowser;
  SetBrowserOleClientSite(Self as IOleClientSite);
end;

destructor TNulWBContainer.Destroy;
  {Class destructor. Unregisters object as browser control container and tears
  down object.
  }
begin
  SetBrowserOleClientSite(nil);
  inherited;
end;

function TNulWBContainer.EnableModeless(const fEnable: BOOL): HResult;
  {Called when a modal UI is displayed by IE. No action taken.
    @param fEnable [in] Not used.
    @return S_OK to indicate we handled successfully.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.FilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HResult;
  {Called to enable host to block or add additional clipboard objects. No
  changes made.
    @param pDO [in] Not used.
    @param ppDORet [out] Set to nil to indicate no additional formats.
    @return S_FALSE to indicate no additional formats.
  }
begin
  ppDORet := nil;
  Result := S_FALSE;
end;

function TNulWBContainer.GetContainer(
  out container: IOleContainer): HResult;
  {Returns a pointer to the container's IOleContainer interface if supported. We
  don't support the interface.
    @param container [out] Set to nil.
    @return E_NOINTERFACE to indicate we don't support IOleContainer.
  }
begin
  container := nil;
  Result := E_NOINTERFACE;
end;

function TNulWBContainer.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HResult;
  {Called when browser is used as drop target to enable alternative drop target
  interface to be displayed. No alternative drop target is supplied.
    @param pDropTarget [in] Not used.
    @param ppDropTarget [out] Set to nil to indicate no alternative drop target.
    @return E_FAIL to indicate to alternative drop target supplied.
  }
begin
  ppDropTarget := nil;
  Result := E_FAIL;
end;

function TNulWBContainer.GetExternal(out ppDispatch: IDispatch): HResult;
  {Called to get host's implementation of browser's external object to enable
  browser (e.g. scripts) to call host's methods. No object is exposed.
    @param ppDispatch [out] Set to nil to indicate no external object exposed.
    @return E_FAIL to indicate to external object.
  }
begin
  ppDispatch := nil;
  Result := E_FAIL;
end;

function TNulWBContainer.GetHostInfo(var pInfo: TDocHostUIInfo): HResult;
  {Retrieves UI capabilities. No action taken.
    @param pInfo [in/out] Not used.
    @return S_OK to indicate success.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.GetMoniker(dwAssign, dwWhichMoniker: Integer;
  out mk: IMoniker): HResult;
  {Returns a moniker to an object's client site. We don't implement monikers.
    @param dwAssign [in] Not used.
    @param dwWhichMoniker [in] Not used.
    @param mk [out] Set to nil.
    @return E_NOTIMPL to indicate method is not implemented.
  }
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

function TNulWBContainer.GetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HResult;
  {Called when IE retrieves data from registry and enables sub key path to be
  changed. Default registry settings not changed.
    @param pchKey [in/out] Set to nil to indicate usage of default registry
      settings.
    @param dw [in] Not used.
    @return E_FAIL to use default registry setting.
  }
begin
  pchKey := nil;
  Result := E_FAIL;
end;

function TNulWBContainer.HideUI: HResult;
  {Called when IE menus, toolbars etc are to be removed. No action taken.
    @return S_OK to indicate we handled successfully.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.OnDocWindowActivate(
  const fActivate: BOOL): HResult;
  {Called when the document window is activated/deactivated. No action taken.
    @param fActivate [in] Not used.
    @return S_OK to indicate we handled successfully.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.OnFrameWindowActivate(
  const fActivate: BOOL): HResult;
  {Called when the top level frame window is activated/deactivated. No action
  taken.
    @param fActivate [in] Not used.
    @return S_OK to indicate we handled successfully.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.OnShowWindow(fShow: BOOL): HResult;
  {Notifies a container when an embedded object's window is about to become
  visible or invisible. No action taken.
    @param fShow [in] Not used.
    @return S_OK to inform we have responded.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.QueryInterface(const IID: TGUID; out Obj): HResult;
  {Determines if this object supports an interface. Has no effect on reference
  count.
    @param IID [in] Required interface.
    @param Obj [out] Reference to object that supports interface.
    @return S_OK if interface supported, E_NOINTERFACE if not.
  }
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNulWBContainer.RequestNewObjectLayout: HResult;
  {Asks container to allocate more or less space for displaying an embedded
  object. We don't support layout requests.
    @return E_NOTIMPL to indicate layout requests not implemented.
  }
begin
  Result := E_NOTIMPL;
end;

function TNulWBContainer.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
  {Called when frame or document window changing. No action taken.
    @param prcBorder [in] Not used.
    @param pUIWindow [in] Not used.
    @param fFrameWindow [in] Not used.
    @return S_FALSE to indicate we did nothing.
  }
begin
  Result := S_FALSE;
end;

function TNulWBContainer.SaveObject: HResult;
  {Saves the object associated with the client site. No action taken.
    @return S_OK to inform we have responded.
  }
begin
  Result := S_OK;
end;

procedure TNulWBContainer.SetBrowserOleClientSite(
  const Site: IOleClientSite);
  {Registers / unregisters object as container (client site) of web browser
  control.
    @param Site [in] Self to register or nil to unregister.
  }
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
  {Called when browser ready to display its context menu. Allows browser to
  display default menu.
    @param dwID [in] Not used.
    @param ppt [in] Not used.
    @param pcmdtReserved [in] Not used.
    @param pdispReserved [in] Not used.
    @return S_FALSE to indicate we did not display any UI.
  }
begin
  Result := S_FALSE
end;

function TNulWBContainer.ShowObject: HResult;
  {Tells the container to position the object so it is visible to the user. No
  action taken.
    @return S_OK to inform we have responded.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.ShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HResult;
  {Called to enable host to modify IE menus, toolbars etc. No changes made.
    @param dwID [in] Not used.
    @param pActiveObject [in] Not used.
    @param pCommandTarget [in] Not used.
    @param pDoc [in] Not used.
    @return S_OK to indicate we displayed own UI (required since browser is not
      displaying its UI).
  }
begin
  Result := S_OK;
end;

function TNulWBContainer.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HResult;
  {Called when accelerator keys are used to enable behaviour to be changed. No
  changes are made.
    @param lpMsg [in] Not used.
    @param pguidCmdGroup [in] Not used.
    @param nCmdID [in] Not used.
    @return S_FALSE to indicate no translations are made.
  }
begin
  Result := S_FALSE;
end;

function TNulWBContainer.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HResult;
  {Gives an opportunity to modify the URL to be loaded. No changes made.
    @param dwTranslate [in] Not used.
    @param pchURLIn [in] Not used.
    @param ppchURLOut [in/out] Set to nil to indicate no translation.
    @return S_FALSE to indicate URL not translated.
  }
begin
  ppchURLOut := nil;
  Result := S_FALSE;
end;

function TNulWBContainer.UpdateUI: HResult;
  {Called when menus, toolbars etc need to be updated. No action taken.
    @return S_OK to indicate we handled successfully.
  }
begin
  Result := S_OK;
end;

function TNulWBContainer._AddRef: Integer;
  {Called by Delphi when interface is referenced. Does not increase reference
  count in this implementation.
    @return -1.
  }
begin
  Result := -1;
end;

function TNulWBContainer._Release: Integer;
  {Called by Delphi when interface is dereferenced. Does not decrease reference
  count in this implementation.
    @return -1.
  }
begin
  Result := -1;
end;

end.

