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
  UPasHi, UInputData, UOutputData, UOptions;


type

  TDocOutputType = (
    doComplete,
    doFragment
  );

  TDocInputSource = (
    isData,
    isFiles
  );

  {
  TDocument:
    Encapsulates a Pascal document and manages the various views displayed by
    the program.
  }
  TDocument = class(TObject)
  private
    fOutputType: TDocOutputType;
    fInputSource: TDocInputSource;
    fInputData: IInputData;
    fInputFiles: TArray<string>;
    fPasHi: TPasHi;
      {Reference to object that performs highlighting by interacting with PasHi}
    fHilitedStream: TMemoryStream;
      {Stream containing highlighted source code}
    procedure SetInputData(const Value: IInputData);
    procedure SetInputFiles(const Value: TArray<string>);
    function GetDisplayHTML: string;
      {Read accessor for DisplayHTML property.
        @return Required HTML code.
      }
    function GetHilitedCode: string;
      {Read accessor for HilitedCode property.
        @return Required highlighted code.
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
    procedure Highlight(const Options: TOptions);
    procedure Save(const OutputData: IOutputData);
      {Saves document via output data object.
        @param OutputData [in] Object used to write the highlighted document's
          content.
      }
    property OutputType: TDocOutputType read fOutputType write fOutputType;
    property InputData: IInputData read fInputData write SetInputData;
    property InputFiles: TArray<string> read fInputFiles write SetInputFiles;
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
end;

destructor TDocument.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fHilitedStream);
  FreeAndNil(fPasHi);
  inherited;
end;

function TDocument.GetDisplayHTML: string;
  {Read accessor for DisplayHTML property.
    @return Required HTML code.
  }
begin
  if fOutputType = doFragment then
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

procedure TDocument.Highlight(const Options: TOptions);
var
  SourceStm: TStream;
begin
  fHilitedStream.Size := 0;
  case fInputSource of
    isData:
    begin
      if not Assigned(fInputData) then
        Exit;
      SourceStm := TMemoryStream.Create;
      try
        fInputData.ReadData(SourceStm);
        SourceStm.Position := 0;
        fPasHi.Hilite(SourceStm, fHilitedStream, Options);
      finally
        SourceStm.Free;
      end;
    end;
    isFiles:
    begin
      if Length(fInputFiles) = 0 then
        Exit;
      fPasHi.Hilite(fInputFiles, fHilitedStream, Options);
    end;
  end;
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
  Assert(fOutputType = doFragment,
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

procedure TDocument.SetInputData(const Value: IInputData);
begin
  fInputData := Value;
  fInputSource := isData;
  SetLength(fInputFiles, 0);
end;

procedure TDocument.SetInputFiles(const Value: TArray<string>);
begin
  fInputFiles := Copy(Value);
  fInputSource := isFiles;
  fInputData := nil;
end;

end.

