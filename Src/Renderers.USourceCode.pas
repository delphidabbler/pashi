{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2021, Peter Johnson (www.delphidabbler.com).
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
    fUseLegacyCSSNames: Boolean;
    fHiliteOptions: THiliteOptions;
  public
    constructor Create(const SourceCode: string;
      const UseLegacyCSSClasses: Boolean; const HiliteOptions: THiliteOptions);
    function Render: string;
  end;

implementation

uses
  SysUtils,
  Hiliter.UHiliters;

{ TSourceCodeRenderer }

constructor TSourceCodeRenderer.Create(const SourceCode: string;
  const UseLegacyCSSClasses: Boolean; const HiliteOptions: THiliteOptions);
begin
  inherited Create;
  fSourceCode := SourceCode;
  fUseLegacyCSSNames := UseLegacyCSSClasses;
  fHiliteOptions := HiliteOptions;
end;

function TSourceCodeRenderer.Render: string;
var
  Hiliter: ISyntaxHiliter;
begin
  if fUseLegacyCSSNames then
    Hiliter := THTMLHiliter.Create(TLegacyCSSNames.Create)
  else
    Hiliter := THTMLHiliter.Create(TCSSNames.Create);
  Result := Trim(Hiliter.Hilite(fSourceCode, fHiliteOptions));
end;

end.
