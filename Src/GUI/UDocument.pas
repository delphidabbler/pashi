{
 * UDocument.pas
 *
 * Class that encapsulates a Pascal document and manages the various views
 * displayed by the program.
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
 * The Original Code is UDocument.pas
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


unit UDocument;


interface


uses
  // Delphi
  Classes,
  // Project
  UPasHi, UInputData, UOutputData;


type

  {
  TDocument:
    Encapsulates a Pascal document and manages the various views displayed by
    the program.
  }
  TDocument = class(TObject)
  private
    fPasHi: TPasHi;
      {Reference to object that performs highlighting by interacting with PasHi}
    fFragment: Boolean;
      {Value of Fragment property}
    fHilitedStream: TMemoryStream;
      {Stream containing highlighted source code}
    fSourceStream: TMemoryStream;
      {Stream containing raw un-highlighted source code}
    fOnHilite: TNotifyEvent;
      {References OnHilite event handler}
    function GetDisplayHTML: string;
      {Read accessor for DisplayHTML property.
        @return Required HTML code.
      }
    function GetHilitedCode: string;
      {Read accessor for HilitedCode property.
        @return Required highlighted code.
      }
    function GetSourceCode: string;
      {Read accessor for SourceCode property.
        @return Un-highlighted source code.
      }
    procedure SetFragment(const Value: Boolean);
      {Write accessor for Fragment property. Re-highlights source code in
      required style.
        @param Value [in] Flag indicating whether to generate HTML fragment or
          complete HTML document.
      }
    procedure DoHilite;
      {Highlights document from source stream, writes to output stream and
      triggers OnHilite event.
      }
    function SampleHTMLFragmentDoc: string;
      {Builds complete HTML document containing fragment of highlighted HTML.
      Used as display document when HTML fragments being generated.
        @return Required HTML document.
      }
    function LoadHTMLTemplate: string;
      {Loads HTML document template used to display HTML code fragments.
      Document is loaded from resources.
        @return Document template.
      }
    function StringFromStream(const Stm: TStream): string;
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    procedure Load(const InputData: IInputData);
      {Loads document via input data object and highlights it.
        @param InputData [in] Object that can access and read data.
      }
    procedure Save(const OutputData: IOutputData);
      {Saves document via output data object.
        @param OutputData [in] Object used to write the highlighted document's
          content.
      }
    function IsEmpty: Boolean;
      {Checks if document is empty.
        @return True if document has no content.
      }
    property Fragment: Boolean read fFragment write SetFragment;
      {Generate highlighted source as HTML fragments when property true and
      complete HTML documents when false}
    property SourceCode: string read GetSourceCode;
      {Raw, un-highlighted source code}
    property HilitedCode: string read GetHilitedCode;
      {Highlighted source code}
    property DisplayHTML: string read GetDisplayHTML;
      {HTML displayed in main program window. If Fragment = True this is
      document that contains fragment otherwise it is the same as HilitedCode}
    property OnHilite: TNotifyEvent read fOnHilite write fOnHilite;
      {Event triggered when document is highlighted}
  end;


implementation


uses
  // Delphi
  SysUtils, Windows;


{ TDocument }

constructor TDocument.Create;
  {Class constructor. Sets up object.
  }
begin
  inherited Create;
  fPasHi := TPasHi.Create;
  fHilitedStream := TMemoryStream.Create;
  fSourceStream := TMemoryStream.Create;
end;

destructor TDocument.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fSourceStream);
  FreeAndNil(fHilitedStream);
  FreeAndNil(fPasHi);
  inherited;
end;

procedure TDocument.DoHilite;
  {Highlights document from source stream, writes to output stream and triggers
  OnHilite event.
  }
begin
  fHilitedStream.Size := 0;
  fSourceStream.Position := 0;
  fPasHi.Hilite(fSourceStream, fHilitedStream, fFragment);
  if Assigned(fOnHilite) then
    fOnHilite(Self);
end;

function TDocument.GetDisplayHTML: string;
  {Read accessor for DisplayHTML property.
    @return Required HTML code.
  }
begin
  if fFragment then
    Result := SampleHTMLFragmentDoc
  else
    Result := GetHilitedCode;
end;

function TDocument.GetHilitedCode: string;
  {Read accessor for HilitedCode property.
    @return Required highlighted code.
  }
begin
  Result := StringFromStream(fHilitedStream);
end;

function TDocument.GetSourceCode: string;
  {Read accessor for SourceCode property.
    @return Un-highlighted source code.
  }
begin
  Result := StringFromStream(fSourceStream);
end;

function TDocument.IsEmpty: Boolean;
  {Checks if document is empty.
    @return True if document has no content.
  }
begin
  Result := fSourceStream.Size = 0;
end;

procedure TDocument.Load(const InputData: IInputData);
  {Loads document via input data object and highlights it.
    @param InputData [in] Object that can access and read data.
  }
begin
  fSourceStream.Size := 0;
  InputData.ReadData(fSourceStream);
  DoHilite;
end;

function TDocument.LoadHTMLTemplate: string;
  {Loads HTML document template used to display HTML code fragments. Document is
  loaded from resources.
    @return Document template.
  }
var
  ResStm: TResourceStream;    // stream onto template resource
  StrStm: TStringStream;      // helper stream for getting resource as string
begin
  StrStm := TStringStream.Create('');
  try
    ResStm := TResourceStream.Create(
      HInstance, 'FRAGMENTTPLT', RT_RCDATA    // ** do not localise
    );
    try
      StrStm.CopyFrom(ResStm, 0);
    finally
      FreeAndNil(ResStm);
    end;
    Result := StrStm.DataString;
  finally
    FreeAndNil(StrStm);
  end;
end;

function TDocument.SampleHTMLFragmentDoc: string;
  {Builds complete HTML document containing fragment of highlighted HTML. Used
  as display document when HTML fragments being generated.
    @return Required HTML document.
  }
begin
  Assert(fFragment, 'TDocument.SampleHTMLFragmentDoc: Fragment not true');
  Result := StringReplace(
    LoadHTMLTemplate,
    '<%Fragment-Here%>',    // ** do not localise
    GetHilitedCode,
    []
  );
end;

procedure TDocument.Save(const OutputData: IOutputData);
  {Saves document via output data object.
    @param OutputData [in] Object used to write the highlighted document's
      content.
  }
begin
  fHilitedStream.Position := 0;
  OutputData.WriteData(fHilitedStream);
end;

procedure TDocument.SetFragment(const Value: Boolean);
  {Write accessor for Fragment property. Re-highlights source code in required
  style.
    @param Value [in] Flag indicating whether to generate HTML fragment or
      complete HTML document.
  }
begin
  fFragment := Value;
  if fSourceStream.Size > 0 then
    DoHilite;
end;

function TDocument.StringFromStream(const Stm: TStream): string;
var
  Bytes: TBytes;
  Encoding: TEncoding;
  PreambleSize: Integer;
begin
  SetLength(Bytes, Stm.Size);
  if Length(Bytes) = 0 then
    Exit('');
  Stm.Position := 0;
  Stm.ReadBuffer(Pointer(Bytes)^, Length(Bytes));
  Encoding := nil;
  PreambleSize := TEncoding.GetBufferEncoding(Bytes, Encoding);
  try
    Result := Encoding.GetString(
      Bytes, PreambleSize, Length(Bytes) - PreambleSize
    );
  finally
    if not TEncoding.IsStandardEncoding(Encoding) then
      Encoding.Free;
  end;
end;

end.

