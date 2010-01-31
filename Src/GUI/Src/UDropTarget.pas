{
 * UDropTarget.pas
 *
 * Class that implements IDropTarget to interact with OLE drag drop system.
 * Hands drop handling off to object that implements IDropDataHandler interface.
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
 * The Original Code is UDropTarget.pas
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


unit UDropTarget;


interface


uses
  // Delphi
  Windows, ActiveX,
  // Project
  IntfDropDataHandler;


type

  {
  TDropTarget:
    Interacts with OLE drag-drop system by implementing IDropTarget. Hands drop
    handling to object that implements IDropDataHandler.
  }
  TDropTarget = class(TInterfacedObject, IDropTarget)
  private
    fDropDataHandler: IDropDataHandler;
      {Reference to object that accepts and handles drag drops}
    fAllowDrop: Boolean;
      {Flag true if we accept current drop object. Set in DragEnter()}
    function DropEffect(const KeyState: Integer;
      const AllowedEffects: LongInt): LongInt;
      {Determines drop effect based on key state and effects permitted.
        @param KeyState [in] Current state of keyboard modifier keys.
        @param AllowedEffects [in] Bitmask of permitted drop effects.
        @return Required drop effect.
      }
  protected
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
      {Determines whether a drop can be accepted and its effect if it is
      accepted.
        @param dataObj [in] Data object being transferred in the drag-and-drop
          operation.
        @param grfKeyState [in] Current state of keyboard modifier keys.
        @param pt [in] Cursor co-ordinates in drop target window. Ignored.
        @param dwEffect [in] Specifies valid drop effects as bitmask of
          DROPEFFECT_* flags. [out] Required drop effect.
        @return S_OK if method completes successfully or error value otherwise.
      }
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
      {Indicates kind of drop accepted (if any) as mouse moves over drop window.
        @param grfKeyState [in] Current state of keyboard modifier keys.
        @param pt [in] Cursor co-ordinates in drop target window. Ignored.
        @param dwEffect [in] Specifies valid drop effects as bitmask of
          DROPEFFECT_* flags. [out] Required drop effect.
        @return S_OK if method completes successfully or error value otherwise.
      }
    function DragLeave: HResult; stdcall;
      {Removes target feedback and releases the data object. We do nothing.
        @return S_OK if method completes successfully or error values otherwise.
      }
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
      {Handles drop of data object if accepted.
        @param dataObj [in] Data object being transferred in the drag-and-drop
          operation.
        @param grfKeyState [in] Current state of keyboard modifier keys.
        @param pt [in] Cursor co-ordinates in drop target window. Ignored.
        @param dwEffect [in] Specifies valid drop effects as bitmask of
          DROPEFFECT_* flags. [out] Required drop effect.
        @return S_OK if method completes successfully or error value otherwise.
      }
  public
    constructor Create(const DropDataHandler: IDropDataHandler);
      {Class constructor. Create drop target that works with a specified data
      handler.
        @param DropDataHandler [in] Object that handles drag drops.
      }
  end;


implementation


uses
  // Delphi
  Classes, Forms;


{ TDropTarget }

constructor TDropTarget.Create(const DropDataHandler: IDropDataHandler);
  {Class constructor. Create drop target that works with a specified data
  handler.
    @param DropDataHandler [in] Object that handles drag drops.
  }
begin
  Assert(Assigned(DropDataHandler));
  inherited Create;
  fDropDataHandler := DropDataHandler;
end;

function TDropTarget.DragEnter(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
  {Determines whether a drop can be accepted and its effect if it is accepted.
    @param dataObj [in] Data object being transferred in the drag-and-drop
      operation.
    @param grfKeyState [in] Current state of keyboard modifier keys.
    @param pt [in] Cursor co-ordinates in drop target window. Ignored.
    @param dwEffect [in] Specifies valid drop effects as bitmask of DROPEFFECT_*
      flags. [out] Required drop effect.
    @return S_OK if method completes successfully or error value otherwise.
  }
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
  {Removes target feedback and releases the data object. We do nothing.
    @return S_OK if method completes successfully or error values otherwise.
  }
begin
  Result := S_OK;
end;

function TDropTarget.DragOver(grfKeyState: Integer; pt: TPoint;
  var dwEffect: Integer): HResult;
  {Indicates kind of drop accepted (if any) as mouse moves over drop window.
    @param grfKeyState [in] Current state of keyboard modifier keys.
    @param pt [in] Cursor co-ordinates in drop target window. Ignored.
    @param dwEffect [in] Specifies valid drop effects as bitmask of DROPEFFECT_*
      flags. [out] Required drop effect.
    @return S_OK if method completes successfully or error value otherwise.
  }
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
  {Handles drop of data object if accepted.
    @param dataObj [in] Data object being transferred in the drag-and-drop
      operation.
    @param grfKeyState [in] Current state of keyboard modifier keys.
    @param pt [in] Cursor co-ordinates in drop target window. Ignored.
    @param dwEffect [in] Specifies valid drop effects as bitmask of DROPEFFECT_*
      flags. [out] Required drop effect.
    @return S_OK if method completes successfully or error value otherwise.
  }
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
  {Determines drop effect based on key state and effects permitted.
    @param KeyState [in] Current state of keyboard modifier keys.
    @param AllowedEffects [in] Bitmask of permitted drop effects.
    @return Required drop effect.
  }

  // ---------------------------------------------------------------------------
  function GetShiftState: TShiftState;
    {Converts KeyState bitmask into a TShiftState set.
      @return Required set of values.
    }
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

  function GetAllowedEffects: TDragDropEffects;
    {Converts bitmask of permitted effects into TDragDropEffects set.
      @return Required set of values.
    }
  begin
    Result := [];
    if AllowedEffects and DROPEFFECT_COPY <> 0 then
      Include(Result, deCopy);
    if AllowedEffects and DROPEFFECT_MOVE <> 0 then
      Include(Result, deMove);
    if AllowedEffects and DROPEFFECT_LINK <> 0 then
      Include(Result, deLink);
  end;

  function WantedEffect(const Effect: TDragDropEffect): LongInt;
    {Determines drop effect flag from TDragDropEffect value.
      @param Effect [in] Required drop effect.
      @return Required flag.
    }
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

