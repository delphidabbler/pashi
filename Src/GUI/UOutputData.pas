{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2016, Peter Johnson (www.delphidabbler.com).
 *
 * Interface and classes that route data output from application to various
 * destinations.
}


unit UOutputData;


interface


uses
  // Delphi
  System.Classes,
  Winapi.ActiveX;


type

  ///  <summary>Interface supported by classes that are used to write document
  ///  output.</summary>
  IOutputData = interface(IInterface)
    ['{057B452E-31F4-4CD9-9BB2-E89317460DB2}']
    procedure WriteData(const Stm: TStream);
  end;

  ///  <summary>Factory for IOutputData implementations.</summary>
  TOutputDataFactory = class(TObject)
  public
    class function CreateForClipboard: IOutputData;
    class function CreateForFile(const FileName: string): IOutputData;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Vcl.Clipbrd,
  // Project
  UUtils;


type

  ///  <summary>IOutputData implementation that writes data to a file.</summary>
  TFileOutputData = class(TInterfacedObject,
    IOutputData
  )
  private
    fFileName: string;
  protected
    procedure WriteData(const Stm: TStream);
  public
    constructor Create(const FileName: string);
  end;

  ///  <summary>IOutputData implementation that writes data to clipboard.
  ///  </summary>
  TClipboardOutputData = class(TInterfacedObject,
    IOutputData
  )
  protected
    procedure WriteData(const Stm: TStream);
  end;

{ TOutputDataFactory }

class function TOutputDataFactory.CreateForClipboard: IOutputData;
begin
  Result := TClipboardOutputData.Create;
end;

class function TOutputDataFactory.CreateForFile(
  const FileName: string): IOutputData;
begin
  Result := TFileOutputData.Create(FileName);
end;

{ TFileOutputData }

constructor TFileOutputData.Create(const FileName: string);
begin
  inherited Create;
  fFileName := FileName;
end;

procedure TFileOutputData.WriteData(const Stm: TStream);
var
  FileStream: TFileStream;  // stream onto file
begin
  FileStream := TFileStream.Create(fFileName, fmCreate);
  try
    FileStream.CopyFrom(Stm, 0);
  finally
    FreeAndNil(FileStream);
  end;
end;

{ TClipboardOutputData }

procedure TClipboardOutputData.WriteData(const Stm: TStream);
begin
  Clipboard.AsText := StringFromStream(Stm);
end;

end.

