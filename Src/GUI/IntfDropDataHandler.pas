{
 * IntfDropDataHandler.pas
 *
 * Interface defining methods implemented by objects that process OLE drag drop
 * operations.
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
 * The Original Code is IntfDropDataHandler.pas
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

