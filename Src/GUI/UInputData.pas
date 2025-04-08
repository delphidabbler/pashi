{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Interface and classes that route input data from various sources to the
 * application.
}


unit UInputData;


interface


uses
  // Delphi
  System.Classes;


type

  ///  <summary>Interface supported by classes that are used to read source code
  ///  data into a document.</summary>
  IInputData = interface(IInterface)
    ['{F48A8B32-31D3-49FD-8D5D-6338D0E63E43}']
    procedure ReadData(const Stream: TStream);
  end;

  ///  <summary>Factory for IInputData implementations.</summary>
  TInputDataFactory = class(TObject)
  public
    class function CreateFromText(const Text: string): IInputData;
  end;


implementation


uses
  // Delphi
  System.SysUtils;


type

  ///  <summary>IInputData implementation that reads data from a string.
  ///  </summary>
  TTextInputData = class(TInterfacedObject, IInputData)
  private
    fText: string;
  protected
    procedure ReadData(const Stream: TStream);
  public
    constructor Create(const Text: string);
  end;


{ TInputDataFactory }

class function TInputDataFactory.CreateFromText(const Text: string): IInputData;
begin
  Result := TTextInputData.Create(Text);
end;

{ TTextInputData }

constructor TTextInputData.Create(const Text: string);
begin
  inherited Create;
  fText := Text;
end;

procedure TTextInputData.ReadData(const Stream: TStream);
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

