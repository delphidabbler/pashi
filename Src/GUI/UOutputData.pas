{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2012, Peter Johnson (www.delphidabbler.com).
 *
 * Interface and classes that route data output from application to various
 * destinations.
}


unit UOutputData;


interface


uses
  // Delphi
  Classes, ActiveX;


type

  {
  IOutputData:
    Interface supported by classes that are used to write document output.
  }
  IOutputData = interface(IInterface)
    ['{057B452E-31F4-4CD9-9BB2-E89317460DB2}']
    procedure WriteData(const Stm: TStream);
      {Writes data to stream.
        @param Stm [in] Stream to receive data.
      }
  end;

  {
  TOutputDataFactory:
    Factory for IOutputData implementations.
  }
  TOutputDataFactory = class(TObject)
  public
    class function CreateForClipboard: IOutputData;
      {Creates object that can write data to a clipboard.
        @param Fmt [in] Required clipboard format.
        @return Required object.
      }
    class function CreateForFile(const FileName: string): IOutputData;
      {Creates object that can write data to a file.
        @param FileName [in] Name of file to write.
        @return Required object.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Clipbrd,
  // Project
  UUtils;


type

  {
  TFileOutputData:
    IOutputData implementation that writes data to a file.
  }
  TFileOutputData = class(TInterfacedObject,
    IOutputData
  )
  private
    fFileName: string;
      {Name of file to receive data}
  protected
    procedure WriteData(const Stm: TStream);
      {Writes data from stream to file.
        @param Stm [in] Stream containing data to write to file.
      }
  public
    constructor Create(const FileName: string);
      {Class constructor. Sets up object.
        @param FileName [in] Name of file to receive data.
      }
  end;

  {
  TClipboardOutputData:
    IOutputData implementation that writes data to clipboard.
  }
  TClipboardOutputData = class(TInterfacedObject,
    IOutputData
  )
  protected
    procedure WriteData(const Stm: TStream);
      {Writes data from stream to clipboard.
        @param Stm [in] Stream containing data to write to clipboard.
      }
  end;

{ TOutputDataFactory }

class function TOutputDataFactory.CreateForClipboard: IOutputData;
  {Creates object that can write data to a clipboard.
    @param Fmt [in] Required clipboard format.
    @return Required object.
  }
begin
  Result := TClipboardOutputData.Create;
end;

class function TOutputDataFactory.CreateForFile(
  const FileName: string): IOutputData;
  {Creates object that can write data to a file.
    @param FileName [in] Name of file to write.
    @return Required object.
  }
begin
  Result := TFileOutputData.Create(FileName);
end;

{ TFileOutputData }

constructor TFileOutputData.Create(const FileName: string);
  {Class constructor. Sets up object.
    @param FileName [in] Name of file to receive data.
  }
begin
  inherited Create;
  fFileName := FileName;
end;

procedure TFileOutputData.WriteData(const Stm: TStream);
  {Writes data from stream to file.
    @param Stm [in] Stream containing data to write to file.
  }
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
  {Writes data from stream to clipboard.
    @param Stm [in] Stream containing data to write to clipboard.
  }
begin
  Clipboard.AsText := StringFromStream(Stm);
end;

end.

