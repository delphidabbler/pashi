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
 * Interface and classes that route input data from various sources to the
 * application.
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

//class function TInputDataFactory.CreateFromFile(
//  const FileName: string): IInputData;
//  {Creates object that can read data from file.
//    @param FileName [in] Name of file containing data.
//    @return Required object.
//  }
//begin
//  Result := TFileInputData.Create(FileName);
//end;

class function TInputDataFactory.CreateFromText(const Text: string): IInputData;
  {Creates object that can read data from string.
    @param Text [in] Data as text.
    @return Required object.
  }
begin
  Result := TTextInputData.Create(Text);
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
  PreambleBytes: TBytes;
  ContentBytes: TBytes;
begin
  PreambleBytes := TEncoding.UTF8.GetPreamble;
  ContentBytes := TEncoding.UTF8.GetBytes(fText);
  if Length(PreambleBytes) > 0 then
    Stream.WriteBuffer(Pointer(PreambleBytes)^, Length(PreambleBytes));
  Stream.WriteBuffer(Pointer(ContentBytes)^, Length(ContentBytes));
end;

end.

