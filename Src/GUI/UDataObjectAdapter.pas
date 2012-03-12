{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Class that interacts with and provides an alternate interface to a
 * IDataObject.
}


unit UDataObjectAdapter;


interface


uses
  // Delphi
  ActiveX;


type

  {
  TDataObjectAdapter:
    Helper class that interacts with and provides an alternate interface to a
    IDataObject.
  }
  TDataObjectAdapter = class(TObject)
  private
    fDataObject: IDataObject;
      {Adapted data object}
    function MakeFormatEtc(const Fmt: TClipFormat): TFormatEtc;
      {Initialises a TFormatEtc record for a specified data format.
        @param Fmt [in] Required data format.
        @return Initialised record.
      }
  public
    constructor Create(const DataObject: IDataObject);
      {Class constructor. Creates adapter for a IDataObject.
        @param DataObject [in] Object to be adapted.
      }
    function HasFormat(const Fmt: TClipFormat): Boolean;
      {Checks if data object supports a data format.
        @param Fmt [in] Format to check.
        @return True if format supported, false otherwise.
      }
    function GetDataAsText(const Fmt: TClipFormat): string;
      {Extracts data object's data as text. The data object can be any format
      type where there is a meaningful interpretation of data as text.
        @param Fmt [in] Data object format required.
        @return Required text.
        @except EOleSysError raised if can't extract data from data object or
          data object does not support required format.
      }
    function ReadDataAsAnsiText(const Fmt: TClipFormat): string;
    function ReadDataAsUnicodeText(const Fmt: TClipFormat): string;
  end;


implementation


uses
  // Delphi
  SysUtils, Windows, ComObj;


{ TDataObjectAdapter }

constructor TDataObjectAdapter.Create(const DataObject: IDataObject);
  {Class constructor. Creates adapter for a IDataObject.
    @param DataObject [in] Object to be adapted.
  }
begin
  inherited Create;
  fDataObject := DataObject;
end;

function TDataObjectAdapter.GetDataAsText(const Fmt: TClipFormat): string;
  {Extracts data object's data as text. The data object can be any format type
  where there is a meaningful interpretation of data as text.
    @param Fmt [in] Data object format required.
    @return Required text.
    @except EOleSysError raised if can't extract data from data object or data
      object does not support required format.
  }
var
  Medium: TStgMedium;   // handle to storage medium
  PText: PChar;         // pointer to text
begin
  Result := '';
  OleCheck(fDataObject.GetData(MakeFormatEtc(Fmt), Medium));
  try
    PText := GlobalLock(Medium.hGlobal);
    try
      Result := PText;
    finally
      GlobalUnlock(Medium.hGlobal);
    end;
  finally
    ReleaseStgMedium(Medium);
  end;
end;

function TDataObjectAdapter.HasFormat(const Fmt: TClipFormat): Boolean;
  {Checks if data object supports a data format.
    @param Fmt [in] Format to check.
    @return True if format supported, false otherwise.
  }
begin
  Result := fDataObject.QueryGetData(MakeFormatEtc(Fmt)) = S_OK;
end;

function TDataObjectAdapter.MakeFormatEtc(const Fmt: TClipFormat): TFormatEtc;
  {Initialises a TFormatEtc record for a specified data format.
    @param Fmt [in] Required data format.
    @return Initialised record.
  }
begin
  Result.cfFormat := Fmt;               // record format type
  Result.ptd := nil;                    // device independent
  Result.dwAspect := DVASPECT_CONTENT;  // display representation
  Result.lindex := -1;                  // get all of data
  Result.tymed := TYMED_HGLOBAL;        // pass data in global memory
end;

function TDataObjectAdapter.ReadDataAsAnsiText(const Fmt: TClipFormat): string;
var
  Medium: TStgMedium;   // handle to storage medium
  PText: PAnsiChar;
begin
  Result := '';
  OleCheck(fDataObject.GetData(MakeFormatEtc(Fmt), Medium));
  try
    PText := GlobalLock(Medium.hGlobal);
    try
      Result := string(AnsiString(PText));
    finally
      GlobalUnlock(Medium.hGlobal);
    end;
  finally
    ReleaseStgMedium(Medium);
  end;
end;

function TDataObjectAdapter.ReadDataAsUnicodeText(const Fmt: TClipFormat):
  string;
var
  Medium: TStgMedium;   // handle to storage medium
  PText: PChar;         // pointer to text
begin
  Result := '';
  OleCheck(fDataObject.GetData(MakeFormatEtc(Fmt), Medium));
  try
    PText := GlobalLock(Medium.hGlobal);
    try
      Result := PText;
    finally
      GlobalUnlock(Medium.hGlobal);
    end;
  finally
    ReleaseStgMedium(Medium);
  end;
end;

end.

