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
 * Class that implements IDropTarget to interact with the OLE drag drop system.
}


unit UDropTarget;


interface


uses
  // Delphi
  Windows, ActiveX,
  // Project
  IntfDropDataHandler;


type
  ///  <summary>Class that interacts with the OLE drag-drop system by
  ///  implementing IDropTarget.</summary>
  ///  <remarks>Hands drop handling to object that implements IDropDataHandler.
  ///  </remarks>
  TDropTarget = class(TInterfacedObject, IDropTarget)
  strict private
    var
      ///  <summary>Reference to object that accepts and handles drag drops.
      ///  </summary>
      fDropDataHandler: IDropDataHandler;
      ///  <summary>Flag that indicates if we accept the current drop object.
      ///  </summary>
      ///  <remarks>Set in DragEnter method.</remarks>
      fAllowDrop: Boolean;
    ///  <summary>Determines drop effect based on key state and permitted
    ///  effects.</summary>
    ///  <param name="KeyState">Integer [in] Current state of keyboard modifier
    ///  keys.</param>
    ///  <param name="AllowedEffects">LongInt [in] Bitmask of permitted drop
    ///  effects.</param>
    ///  <returns>LongInt. Required drop effect.</returns>
    function DropEffect(const KeyState: Integer;
      const AllowedEffects: LongInt): LongInt;
  public
    ///  <summary>Constructs drop target object that hands off drop operations
    ///  to given drop data handler object.</summary>
    constructor Create(const DropDataHandler: IDropDataHandler);

    ///  <summary>Determines whether a drop can be accepted and its effect if it
    ///  is.</summary>
    ///  <param name="dataObj">IDataObject [in] Data object being transferred in
    ///  drag-drop operation.</param>
    ///  <param name="grfKeyState">Longint [in] Current state of keyboard
    ///  modifier keys.</param>
    ///  <param name="pt">TPoint [in] Mouse cursor co-ordinates in drop target
    ///  window.</param>
    ///  <param name="dwEffect">Longint [in/out] Valid drop effects as bitmask
    ///  of DROPEFFECT_* flags. Changed to required drop effect, which must be
    ///  a vlaid one.</param>
    ///  <returns>HResult. S_OK always returned.</returns>
    ///  <remarks>Method of IDropTarget.</remarks>
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;

    ///  <summary>Indicates kind of drop accepted (if any) as mouse moves over
    ///  drop window.</summary>
    ///  <param name="grfKeyState">Longint [in] Current state of keyboard
    ///  modifier keys.</param>
    ///  <param name="pt">TPoint [in] Mouse cursor co-ordinates in drop target
    ///  window.</param>
    ///  <param name="dwEffect">Longint [in/out] Valid drop effects as bitmask
    ///  of DROPEFFECT_* flags. Changed to required drop effect, which must be
    ///  a vlaid one.</param>
    ///  <returns>HResult. S_OK always returned.</returns>
    ///  <remarks>Method of IDropTarget.</remarks>
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;

    ///  <summary>Called when mouse leaves drop target window. We do ntohing.
    ///  </summary>
    ///  <returns>HResult. S_OK always returned.</returns>
    ///  <remarks>Method of IDropTarget.</remarks>
    function DragLeave: HResult; stdcall;

    ///  <summary>Handles drop of data object if accepted.</summary>
    ///  <param name="dataObj">IDataObject [in] Data object being transferred in
    ///  drag-drop operation.</param>
    ///  <param name="grfKeyState">Longint [in] Current state of keyboard
    ///  modifier keys.</param>
    ///  <param name="pt">TPoint [in] Mouse cursor co-ordinates in drop target
    ///  window.</param>
    ///  <param name="dwEffect">Longint [in/out] Valid drop effects as bitmask
    ///  of DROPEFFECT_* flags. Changed to required drop effect, which must be
    ///  a vlaid one.</param>
    ///  <returns>HResult. S_OK always returned.</returns>
    ///  <remarks>Method of IDropTarget.</remarks>
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
  end;


implementation


uses
  // Delphi
  Classes, Forms;


{ TDropTarget }

constructor TDropTarget.Create(const DropDataHandler: IDropDataHandler);
begin
  Assert(Assigned(DropDataHandler));
  inherited Create;
  fDropDataHandler := DropDataHandler;
end;

function TDropTarget.DragEnter(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
begin
  try
    // Ask data handler if we accept this data type
    fAllowDrop := fDropDataHandler.CanAccept(dataObj);
    dwEffect := DropEffect(grfKeyState, dwEffect);
  except
    fDropDataHandler.ExceptionHandler(ExceptObject);
  end;
  Result := S_OK;
end;

function TDropTarget.DragLeave: HResult;
begin
  Result := S_OK;
end;

function TDropTarget.DragOver(grfKeyState: Integer; pt: TPoint;
  var dwEffect: Integer): HResult;
begin
  try
    dwEffect := DropEffect(grfKeyState, dwEffect);
  except
    fDropDataHandler.ExceptionHandler(ExceptObject);
  end;
  Result := S_OK;
end;

function TDropTarget.Drop(const dataObj: IDataObject; grfKeyState: Integer;
  pt: TPoint; var dwEffect: Integer): HResult;
begin
  try
    try
      // Determine drop effect
      dwEffect := DropEffect(grfKeyState, dwEffect);
      if fAllowDrop then
        // Use drag drop handler to process drop
        fDropDataHandler.HandleData(dataObj);
    finally
      DragLeave;
    end;
  except
    fDropDataHandler.ExceptionHandler(ExceptObject);
  end;
  Result := S_OK;
end;

function TDropTarget.DropEffect(const KeyState,
  AllowedEffects: Integer): LongInt;

  // ---------------------------------------------------------------------------
  // Converts Converts KeyState bitmask into a TShiftState set.
  function GetShiftState: TShiftState;
  begin
    Result := [];
    if KeyState and MK_CONTROL <> 0 then
      Include(Result, ssCtrl);
    if KeyState and MK_SHIFT <> 0 then
      Include(Result, ssShift);
    if KeyState and MK_ALT <> 0 then
      Include(Result, ssAlt);
    if KeyState and MK_LBUTTON <> 0 then
      Include(Result, ssLeft);
    if KeyState and MK_RBUTTON <> 0 then
      Include(Result, ssRight);
    if KeyState and MK_MBUTTON <> 0 then
      Include(Result, ssMiddle);
  end;

  // Converts bitmask of permitted effects into TDragDropEffects set.
  function GetAllowedEffects: TDragDropEffects;
  begin
    Result := [];
    if AllowedEffects and DROPEFFECT_COPY <> 0 then
      Include(Result, deCopy);
    if AllowedEffects and DROPEFFECT_MOVE <> 0 then
      Include(Result, deMove);
    if AllowedEffects and DROPEFFECT_LINK <> 0 then
      Include(Result, deLink);
  end;

  // Determines drop effect flag from TDragDropEffect value.
  function WantedEffect(const Effect: TDragDropEffect): LongInt;
  begin
    case Effect of
      deNone: Result := DROPEFFECT_NONE;
      deCopy: Result := DROPEFFECT_COPY;
      deMove: Result := DROPEFFECT_MOVE;
      deLink: Result := DROPEFFECT_LINK;
      else Result := DROPEFFECT_NONE;
    end;
  end;
  // ---------------------------------------------------------------------------

begin
  // If we allow drops we get required drop effect from drop data handler
  Result := DROPEFFECT_NONE;
  if fAllowDrop then
  begin
    Result := WantedEffect(
      fDropDataHandler.DropEffect(GetShiftState, GetAllowedEffects)
    );
  end;
end;

end.

