{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2016, Peter Johnson (www.delphidabbler.com).
 *
 * Interface defining methods implemented by objects that process OLE drag drop
 * operations.
}


unit IntfDropDataHandler;


interface


uses
  // Delphi
  System.Classes,
  WinApi.ActiveX;


type

  ///  <summary>Enumeration of visible effects used in drag-drop.</summary>
  TDragDropEffect = (
    deNone = DROPEFFECT_NONE,   // drop not accepted: "no entry" cursor
    deCopy = DROPEFFECT_COPY,   // dropped item to be copied
    deMove = DROPEFFECT_MOVE,   // dropped item to be moved
    deLink = DROPEFFECT_LINK    // dropped item to be linked
  );

  ///  <summary>Set of TDragDropEffect values.</summary>
  TDragDropEffects = set of TDragDropEffect;

  ///  <summary>Interface to be implemented by object that accept and handle OLE
  ///  drag drop operations.</summary>
  ///  <remarks>Methods of this interface are called by the TDropTarget object
  ///  that interacts with Windows OLE drag drop sub system.</remarks>
  IDropDataHandler = interface(IInterface)
    ['{8ED85360-0F73-4A79-A60B-7E2C7CEBA620}']
    function CanAccept(const DataObj: IDataObject): Boolean;
    procedure HandleData(const DataObj: IDataObject);
    function DropEffect(const Shift: TShiftState;
      const AllowedEffects: TDragDropEffects): TDragDropEffect;
    procedure ExceptionHandler(const E: TObject);
  end;


implementation

end.

