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
 * Class that encapsulates a Pascal document and manages the various views
 * displayed by the program.
}


unit UDocument;


interface


uses
  // Delphi
  Classes,
  // Project
  UPasHi, UInputData, UOutputData;


type

  TDocOutputType = (
    doXHTML,
    doXHTMLFragment
  );

  {
  TDocument:
    Encapsulates a Pascal document and manages the various views displayed by
    the program.
  }
  TDocument = class(TObject)
  private
    fOutputType: TDocOutputType;
    fInputData: IInputData;
    fPasHi: TPasHi;
      {Reference to object that performs highlighting by interacting with PasHi}
    fHilitedStream: TMemoryStream;
      {Stream containing highlighted source code}
    fSourceStream: TMemoryStream;
      {Stream containing raw un-highlighted source code}
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
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    procedure Highlight;
    procedure Save(const OutputData: IOutputData);
      {Saves document via output data object.
        @param OutputData [in] Object used to write the highlighted document's
          content.
      }
    function IsEmpty: Boolean;
      {Checks if document is empty.
        @return True if document has no content.
      }
    property OutputType: TDocOutputType read fOutputType write fOutputType;
    property InputData: IInputData read fInputData write fInputData;
    property SourceCode: string read GetSourceCode;
      {Raw, un-highlighted source code}
    property HilitedCode: string read GetHilitedCode;
      {Highlighted source code}
    property DisplayHTML: string read GetDisplayHTML;
      {HTML displayed in main program window. If Fragment = True this is
      document that contains fragment otherwise it is the same as HilitedCode}
  end;


implementation


uses
  // Delphi
  SysUtils, Windows,
  // Project
  UUtils;


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
  fPasHi.Hilite(fSourceStream, fHilitedStream, fOutputType = doXHTMLFragment);
end;

function TDocument.GetDisplayHTML: string;
  {Read accessor for DisplayHTML property.
    @return Required HTML code.
  }
begin
  if fOutputType = doXHTMLFragment then
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

procedure TDocument.Highlight;
begin
  if not Assigned(fInputData) then
    Exit;
  fSourceStream.Size := 0;
  fInputData.ReadData(fSourceStream);
  DoHilite;
end;

function TDocument.IsEmpty: Boolean;
  {Checks if document is empty.
    @return True if document has no content.
  }
begin
  Result := fSourceStream.Size = 0;
end;

function TDocument.LoadHTMLTemplate: string;
  {Loads HTML document template used to display HTML code fragments. Document is
  loaded from resources.
    @return Document template.
  }
var
  ResStm: TResourceStream;    // stream onto template resource
begin
  ResStm := TResourceStream.Create(
    HInstance, 'FRAGMENTTPLT', RT_RCDATA    // ** do not localise
  );
  try
    Result := StringFromStream(ResStm);
  finally
    ResStm.Free;
  end;
end;

function TDocument.SampleHTMLFragmentDoc: string;
  {Builds complete HTML document containing fragment of highlighted HTML. Used
  as display document when HTML fragments being generated.
    @return Required HTML document.
  }
begin
  Assert(fOutputType = doXHTMLFragment,
    'TDocument.SampleHTMLFragmentDoc: Fragment not true');
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

end.

