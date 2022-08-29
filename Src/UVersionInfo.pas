{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014-2022, Peter Johnson (www.delphidabbler.com).
 *
 * Gets selected version information for PasHi and PasHiGUI.
}


unit UVersionInfo;

interface

uses
  // Delphi
  Classes;

type
  ///  <summary>Class that retrieves version information for both PasHi and
  ///  PasHiGUI from resources.</summary>
  ///  <remarks>Version numbers are retrieved from a copy of the VERSION file
  ///  that has been included as a RCDATA resource. String information is
  ///  retrieved directly from the host program's version information resource.
  ///  </remarks>
  TVersionInfo = class(TObject)
  strict private
    const
      // Name of RCDATA resource containing version numbers
      VerResName = 'VERSION_DATA';
      // Various keys to values in RCDATA resource
      GUIFileVerKey = 'guifilever';
      GUIBuildKey = 'guibuild';
      CmdLineFileVerKey = 'cmdlinefilever';
    var
      ///  <summary>Container for file version information read from RCDATA
      ///  resource in <c>key=value</c> format.</summary>
      ///  <remarks> Data read depends on RCDATA resource and is independent of
      ///  host program's version information resource.</remarks>
      fResData: TStringList;

    ///  <summary>Reads and processes data stored in RCDATA resource.</summary>
    procedure ReadResData;

    ///  <summary>Gets file version for PasHi.</summary>
    ///  <remarks>Reads required data from <c>fResData</c>.</remarks>
    function GetCmdLineVersion: string;

    ///  <summary>Gets file version for PasHiGUI.</summary>
    ///  <remarks>Reads required data from <c>fResData</c>.</remarks>
    function GetGUIVersion: string;

    ///  <summary>Gets build number for PasHiGUI.</summary>
    ///  <remarks>Reads required data from <c>fResData</c>.</remarks>
    function GetGUIBuild: string;

    ///  <summary>Gets copyright information for host program.</summary>
    ///  <remarks>Reads required data directly from the host program's version
    ///  information resource.</remarks>
    function GetCopyright: string;
  public
    constructor Create;
    destructor Destroy; override;

    ///  <summary>PasHiGUI's version number.</summary>
    property GUIVersion: string read GetGUIVersion;

    ///  <summary>PasHiGUI's build number.</summary>
    property GUIBuild: string read GetGUIBuild;

    ///  <summary>PasHi's version number.</summary>
    property CmdLineVersion: string read GetCmdLineVersion;

    ///  <summary>PasHiGUI's copyright information.</summary>
    property Copyright: string read GetCopyright;
  end;

implementation

uses
  // Delphi
  SysUtils, StrUtils, Windows;

{ TVersionInfo }

constructor TVersionInfo.Create;
begin
  inherited Create;
  fResData := TStringList.Create;
  ReadResData;
end;

destructor TVersionInfo.Destroy;
begin
  fResData.Free;
  inherited;
end;

function TVersionInfo.GetCmdLineVersion: string;
begin
  Result := fResData.Values[CmdLineFileVerKey];
end;

function TVersionInfo.GetCopyright: string;
var
  Ptr: Pointer;                       // pointer to result of API call
  Len: UINT;                          // length of structure returned from API
  VerInfoSize: Integer;               // size of version information data
  VerInfoBuf: Pointer;                // buffer holding version information
  Dummy: DWORD;                       // unused variable required in API calls
const
  // Sub-block identifying copyright info
  SubBlock = '\StringFileInfo\080904E4\LegalCopyright';
begin
  Result := '';
  // get size of version info
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize <= 0 then
    Exit;
  // create buffer and read version info into it
  GetMem(VerInfoBuf, VerInfoSize);
  try
    if not GetFileVersionInfo(
      PChar(ParamStr(0)), Dummy, VerInfoSize, VerInfoBuf
    ) then Exit;
    if not VerQueryValue(VerInfoBuf, SubBlock, Ptr, Len) then
      Exit;
    Result := PChar(Ptr);
  finally
    FreeMem(VerInfoBuf);
  end;
end;

function TVersionInfo.GetGUIBuild: string;
begin
  Result := fResData.Values[GUIBuildKey];
end;

function TVersionInfo.GetGUIVersion: string;
begin
  Result := fResData.Values[GUIFileVerKey];
end;

procedure TVersionInfo.ReadResData;
var
  ResStream: TResourceStream;
  StrStream: TStringStream;
  I: Integer;
  Line: string;
begin
  StrStream := nil;
  ResStream := TResourceStream.Create(HInstance, VerResName, RT_RCDATA);
  try
    StrStream := TStringStream.Create('', TEncoding.UTF8);
    StrStream.CopyFrom(ResStream, 0);
    fResData.Text := StrStream.DataString;
    for I := Pred(fResData.Count) downto 0 do
    begin
      Line := Trim(fResData[I]);
      if StartsStr('#', Line) or (Line = '') then
        fResData.Delete(I)
      else
        fResData[I] := Line;
    end;
  finally
    ResStream.Free;
    StrStream.Free;
  end;
end;

end.
