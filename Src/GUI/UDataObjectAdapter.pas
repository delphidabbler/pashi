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
 * Defines an adapter class that interacts with and provides an alternate
 * interface to a IDataObject.
}


unit UDataObjectAdapter;


interface


uses
  // Delphi
  ActiveX;


type
  ///  <summary>Adapter class that interacts with and provides an alternate
  ///  interface to a IDataObject.</summary>
  TDataObjectAdapter = class(TObject)
  strict private
    var
      ///  <summary>Adapted data object</summary>
      fDataObject: IDataObject;
    ///  <summary>Returns a TFormatEtc record that has been initialised for the
    ///  given data format.</summary>
    function MakeFormatEtc(const Fmt: TClipFormat): TFormatEtc;

  public
    ///  <summary>Creates adapter for a given IDataObject instance.</summary>
    constructor Create(const DataObject: IDataObject);

    ///  <summary>Checks if data object supports given data format.</summary>
    function HasFormat(const Fmt: TClipFormat): Boolean;

    ///  <summary>Extracts data object's data as ANSI text using given clipboard
    ///  format and returns text converted to Unicode string.</summary>
    ///  <remarks>Clipboard format can be any type where there is a meaningful
    ///  interpretation of the data as ANSI text.</remarks>
    ///  <exception>EOleSysError raised if data object does not support format
    ///  or data can't be read from data object.</exception>
    function ReadDataAsAnsiText(const Fmt: TClipFormat): string;

    ///  <summary>Extracts and returns data object's data as Unicode text using
    ///  given clipboard format.</summary>
    ///  <remarks>Clipboard format can be any type where there is a meaningful
    ///  interpretation of the data as Unicode text.</remarks>
    ///  <exception>EOleSysError raised if data object does not support format
    ///  or data can't be read from data object.</exception>
    function ReadDataAsUnicodeText(const Fmt: TClipFormat): string;

    ///  <summary>Gets all file names from data object in CF_HDROP format and
    ///  returns them in a dynamic string array.</summary>
    ///  <remarks>Data object must support CF_HDROP.</remarks>
    ///  <exception>EOleSysError raised if data can't be read from data
    ///  object.</exception>
    function GetHDROPFileNames: TArray<string>;
  end;


implementation


uses
  // Delphi
  SysUtils, Windows, ComObj, ShellAPI;


{ TDataObjectAdapter }

constructor TDataObjectAdapter.Create(const DataObject: IDataObject);
begin
  inherited Create;
  fDataObject := DataObject;
end;

function TDataObjectAdapter.GetHDROPFileNames: TArray<string>;
var
  Medium: TStgMedium; // storage medium
  HDrop: THandle;     // handle to dropped files
  FileCount: Integer; // number of dropped files
  Idx: Integer;       // loops through all dropped files
  FileName: string;   // name of a dropped file
  NameLen: Integer;   // length of a dropped file name
begin
  Assert(HasFormat(CF_HDROP));
  SetLength(Result, 0);
  OleCheck(fDataObject.GetData(MakeFormatEtc(CF_HDROP), Medium));
  HDrop := Medium.hGlobal;
  if HDrop = 0 then
    Exit;
  // Scan through files specified by HDROP handle, adding to lists
  FileCount := DragQueryFile(HDrop, Cardinal(-1), nil, 0);
  SetLength(Result, FileCount);
  try
    for Idx := 0 to Pred(FileCount) do
    begin
      NameLen := DragQueryFile(HDrop, Idx, nil, 0);
      SetLength(FileName, NameLen);
      DragQueryFile(HDrop, Idx, PChar(FileName), NameLen + 1);
      Result[Idx] := FileName;
    end;
  finally
    DragFinish(HDrop);
  end;
end;

function TDataObjectAdapter.HasFormat(const Fmt: TClipFormat): Boolean;
begin
  Result := fDataObject.QueryGetData(MakeFormatEtc(Fmt)) = S_OK;
end;

function TDataObjectAdapter.MakeFormatEtc(const Fmt: TClipFormat): TFormatEtc;
begin
  Result.cfFormat := Fmt;               // record format type
  Result.ptd := nil;                    // device independent
  Result.dwAspect := DVASPECT_CONTENT;  // display representation
  Result.lindex := -1;                  // get all of data
  Result.tymed := TYMED_HGLOBAL;        // pass data in global memory
end;

function TDataObjectAdapter.ReadDataAsAnsiText(const Fmt: TClipFormat): string;
var
  Medium: TStgMedium;   // storage medium
  PText: PAnsiChar;     // pointer to ANSI text
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
  Medium: TStgMedium;   // storage medium
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

