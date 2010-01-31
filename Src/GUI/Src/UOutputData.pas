{
 * UOutputData.pas
 *
 * Interface and classes that route data output from application to various
 * destinations.
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
 * The Original Code is UOutputData.pas
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
    class function CreateForClipboard(const Fmt: TClipFormat): IOutputData;
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
  SysUtils,
  // Project
  UClipboardWriteStream;


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
  private
    fClipFmt: TClipFormat;
      {Clipboard data format}
  protected
    procedure WriteData(const Stm: TStream);
      {Writes data from stream to clipboard.
        @param Stm [in] Stream containing data to write to clipboard.
      }
  public
    constructor Create(const ClipFmt: TClipFormat);
      {Class constructor. Sets up object.
        @param Fmt [in] Clipboard data format.
      }
  end;


{ TOutputDataFactory }

class function TOutputDataFactory.CreateForClipboard(
  const Fmt: TClipFormat): IOutputData;
  {Creates object that can write data to a clipboard.
    @param Fmt [in] Required clipboard format.
    @return Required object.
  }
begin
  Result := TClipboardOutputData.Create(Fmt);
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

constructor TClipboardOutputData.Create(const ClipFmt: TClipFormat);
  {Class constructor. Sets up object.
    @param Fmt [in] Clipboard data format.
  }
begin
  inherited Create;
  fClipFmt := ClipFmt;
end;

procedure TClipboardOutputData.WriteData(const Stm: TStream);
  {Writes data from stream to clipboard.
    @param Stm [in] Stream containing data to write to clipboard.
  }
var
  ClipStm: TClipboardWriteStream; // stream onto clipboard
  ZeroChar: AnsiChar;             // string termination character
begin
  ClipStm := TClipboardWriteStream.Create(fClipFmt);
  try
    ClipStm.CopyFrom(Stm, 0);
    ZeroChar := #0;
    ClipStm.WriteBuffer(ZeroChar, SizeOf(AnsiChar));  // ensure ends with #0
  finally
    FreeAndNil(ClipStm);
  end;
end;

end.

