{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Class that highlights source code into HTML suitable for all supported
 * document types.
}


unit Renderers.USourceCode;

interface

uses
  Hiliter.UGlobals,
  Renderers.UTypes;

type
  TSourceCodeRenderer = class sealed(TInterfacedObject, IRenderer)
  strict private
    fSourceCode: string;
    fLegacyCSSNames: Boolean;
    fHiliteOptions: THiliteOptions;
  public
    constructor Create(const SourceCode: string;
      const LegacyCSSClasses: Boolean; const HiliteOptions: THiliteOptions);
    function Render: string;
  end;

implementation

uses
  SysUtils,
  Hiliter.UHiliters;

{ TSourceCodeRenderer }

constructor TSourceCodeRenderer.Create(const SourceCode: string;
  const LegacyCSSClasses: Boolean; const HiliteOptions: THiliteOptions);
begin
  inherited Create;
  fSourceCode := SourceCode;
  fLegacyCSSNames := LegacyCSSClasses;
  fHiliteOptions := HiliteOptions;
end;

function TSourceCodeRenderer.Render: string;
var
  Hiliter: ISyntaxHiliter;
begin
  if fLegacyCSSNames then
    Hiliter := TXHTMLHiliter.Create(TLegacyCSSNames.Create)
  else
    Hiliter := TXHTMLHiliter.Create(TCSSNames.Create);
  Result := Trim(Hiliter.Hilite(fSourceCode, fHiliteOptions));
end;

end.
