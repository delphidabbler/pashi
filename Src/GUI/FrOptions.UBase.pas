{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Base class for the different frames used to edit PasHi options.
}


unit FrOptions.UBase;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  UOptions;

type
  TBaseOptionsFrame = class(TFrame)
  public
    procedure Initialise(const Options: TOptions); virtual; abstract;
    procedure UpdateOptions(const Options: TOptions); virtual; abstract;
  end;

implementation

{$R *.dfm}

end.
