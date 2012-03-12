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
 * Interface defining methods implemented by objects that process OLE drag drop
 * operations.
}


unit IntfDropDataHandler;


interface


uses
  // Delphi
  Classes, ActiveX;


type

  {
  TDragDropEffect:
    Enumeration of visible effects used in drag-drop.
  }
  TDragDropEffect = (
    deNone = DROPEFFECT_NONE,   // drop not accepted: "no entry" cursor
    deCopy = DROPEFFECT_COPY,   // dropped item to be copied
    deMove = DROPEFFECT_MOVE,   // dropped item to be moved
    deLink = DROPEFFECT_LINK    // dropped item to be linked
  );

  {
  TDragDropEffects
    Set of TDragDropEffect values.
  }
  TDragDropEffects = set of TDragDropEffect;

  {
  IDropDataHandler:
    Interface to be implemented by object that accept and handle OLE drag drop
    operations. Methods of this interface are called by the TDropTarget object
    that interacts with Windows OLE drag drop sub system.
  }
  IDropDataHandler = interface(IInterface)
    ['{8ED85360-0F73-4A79-A60B-7E2C7CEBA620}']
    function CanAccept(const DataObj: IDataObject): Boolean;
      {Called by TDragDrop to check if application wants to accept a
      data object. Called when a drag enters window.
        @param DataObj [in] Data object being dragged.
        @return True if data object can be accepted, false if not.
      }
    procedure HandleData(const DataObj: IDataObject);
      {Called by TDragDrop when a data object is dropped. Only called if
      CanAccept has returned true. Implementor should incorprate data object.
        @param DataObj [in] Dropped data object.
      }
    function DropEffect(const Shift: TShiftState;
      const AllowedEffects: TDragDropEffects): TDragDropEffect;
      {Repeatedly called by TDragDrop to determine drop effect. Only called if
      CanAccept returned true.
        @param Shift [in] Set describing shift keys and mouse button pressed.
        @param AllowedEffects [in] Effects supported by data source.
        @return Desired drop effect (must be member of AllowedEffects set).
      }
    procedure ExceptionHandler(const E: TObject);
      {Handle exception trapped in drag-drop. Handler should swallow exception
      and not re-raise it.
        @param E [in] Exception object to be handled.
      }
  end;


implementation

end.

