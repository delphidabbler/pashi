{
 * UInputData.pas
 *
 * Interface and classes that route input data from various sources to the
 * application.
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
 * The Original Code is UInputData.pas
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


unit UInputData;


interface


uses
  // Delphi
  Classes;


type

  {
  IInputData:
    Interface supported by classes that are used to read source code data into a
    document.
  }
  IInputData = interface(IInterface)
    ['{F48A8B32-31D3-49FD-8D5D-6338D0E63E43}']
    procedure ReadData(const Stream: TStream);
      {Reads data into a stream.
        @param Stream [in] Stream to receive data.
      }
  end;

  {
  TInputDataFactory:
    Factory for IInputData implementations.
  }
  TInputDataFactory = class(TObject)
  public
    class function CreateFromFile(const FileName: string): IInputData;
      {Creates object that can read data from file.
        @param FileName [in] Name of file containing data.
        @return Required object.
      }
    class function CreateFromText(const Text: string): IInputData;
      {Creates object that can read data from string.
        @param Text [in] Data as text.
        @return Required object.
      }
  end;


implementation


uses
  // Delphi
  SysUtils;


type

  {
  TFileInputData:
    IInputData implementation that reads data from a file.
  }
  TFileInputData = class(TInterfacedObject, IInputData)
  private
    fFileName: string;
      {Name of file containing data}
  protected
    { IInputData }
    procedure ReadData(const Stream: TStream);
      {Reads data from file into stream.
        @param Stream [in] Stream to receive file data.
      }
  public
    constructor Create(const FileName: string);
      {Class constructor. Sets up object.
      }
  end;

  {
  TTextInputData:
    IInputData implementation that reads data from a string.
  }
  TTextInputData = class(TInterfacedObject, IInputData)
  private
    fText: string;
      {Data as text}
  protected
    { IInputData }
    procedure ReadData(const Stream: TStream);
      {Reads data from text into stream.
        @const Stream [in] Stream to receive text.
      }
  public
    constructor Create(const Text: string);
      {Class constructor. Sets up object.
      }
  end;


{ TInputDataFactory }

class function TInputDataFactory.CreateFromFile(
  const FileName: string): IInputData;
  {Creates object that can read data from file.
    @param FileName [in] Name of file containing data.
    @return Required object.
  }
begin
  Result := TFileInputData.Create(FileName);
end;

class function TInputDataFactory.CreateFromText(const Text: string): IInputData;
  {Creates object that can read data from string.
    @param Text [in] Data as text.
    @return Required object.
  }
begin
  Result := TTextInputData.Create(Text);
end;


{ TFileInputData }

constructor TFileInputData.Create(const FileName: string);
  {Class constructor. Sets up object.
  }
begin
  inherited Create;
  fFileName := FileName;
end;

procedure TFileInputData.ReadData(const Stream: TStream);
  {Reads data from file into stream.
    @param Stream [in] Stream to receive file data.
  }
var
  FileStream: TFileStream;  // stream onto file
begin
  FileStream := TFileStream.Create(fFileName, fmOpenRead or fmShareDenyNone);
  try
    Stream.CopyFrom(FileStream, 0);
  finally
    FreeAndNil(FileStream);
  end;
end;


{ TTextInputData }

constructor TTextInputData.Create(const Text: string);
  {Class constructor. Sets up object.
  }
begin
  inherited Create;
  fText := Text;
end;

procedure TTextInputData.ReadData(const Stream: TStream);
  {Reads data from text into stream.
    @const Stream [in] Stream to receive text.
  }
var
  StringStream: TStringStream;  // stream onto text string
begin
  StringStream := TStringStream.Create(fText);
  try
    Stream.CopyFrom(StringStream, 0);
  finally
    FreeAndNil(StringStream);
  end;
end;

end.

