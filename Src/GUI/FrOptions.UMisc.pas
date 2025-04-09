{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Frame that is used to edit various miscellaneous PasHi options not edited via
 * other option frames.
}


unit FrOptions.UMisc;

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
  Vcl.StdCtrls,
  Vcl.Samples.Spin,
  FrOptions.UBase,
  FrOptions.UHelper,
  UOptions;

type
  TMiscOptionsFrame = class(TBaseOptionsFrame)
    chkTrimLines: TCheckBox;
    lblSeparatorLines: TLabel;
    seSeparatorLines: TSpinEdit;
    lblSeparatorLinesEnd: TLabel;
    lblLanguage: TLabel;
    lblTitle: TLabel;
    edLanguage: TEdit;
    edTitle: TEdit;
    chkBranding: TCheckBox;
    chkViewport: TCheckBox;
    chkEdgeCompatibility: TCheckBox;
    chkTrimSpaces: TCheckBox;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialise(const Options: TOptions); override;
    procedure UpdateOptions(const Options: TOptions); override;
  end;

implementation

uses
  UUtils;

{$R *.dfm}

{ TMultiFileOptionsFrame }

constructor TMiscOptionsFrame.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TMiscOptionsFrame.Destroy;
begin

  inherited;
end;

procedure TMiscOptionsFrame.Initialise(const Options: TOptions);
var
  StrVal: string;
begin
  StrVal := Options.GetParamAsStr('trim');
  // Filter out deprecated values for --trim command
  if IsStrInList(StrVal, ['true', '1', 'y', 'yes', 'on'], False) then
    StrVal := 'lines'
  else if IsStrInList(StrVal, ['false', '0', 'n', 'no', 'off'], False) then
    StrVal := '-'
  // Choose one item from aliases for --trim parameter names
  else if IsStrInList(StrVal, ['none', 'nothing'], False) then
    StrVal := '-'
  else if IsStrInList(StrVal, ['everything'], False) then
    StrVal := 'all';
  chkTrimLines.Checked := IsStrInList(StrVal, ['all', 'lines'], False);
  chkTrimSpaces.Checked := IsStrInList(StrVal, ['all', 'spaces'], False);

  seSeparatorLines.Value := Options.GetParamAsInt('separator-lines');

  edLanguage.Text := '';
  if Options.IsSet('language') then
  begin
    StrVal := Options.GetParamAsStr('language');
    if (StrVal <> 'neutral') and (StrVal <> '-') then
      edLanguage.Text := StrVal;
  end;

  edTitle.Text := '';
  if Options.IsSet('title') then
  begin
    StrVal := Options.GetParamAsStr('title');
    if (StrVal <> '-') then
      edTitle.Text := StrVal;
  end;

  chkBranding.Checked := Options.GetParamAsBool('branding');

  chkViewport.Checked := not SameText(
    Options.GetParamAsStr('viewport'), 'none'
  );

  chkEdgeCompatibility.Checked := Options.GetParamAsBool('edge-compatibility');
end;

procedure TMiscOptionsFrame.UpdateOptions(const Options: TOptions);
begin
  if chkTrimLines.Checked then
  begin
    if chkTrimSpaces.Checked then
      Options.Store('trim', 'all')
    else
      Options.Store('trim', 'lines');
  end
  else
  begin
    if chkTrimSpaces.Checked then
      Options.Store('trim', 'spaces')
    else
      Options.Store('trim', '-');
  end;

  Options.Store('separator-lines', seSeparatorLines.Value);

  Options.Delete('language');
  Options.Delete('language-neutral'); // deprecated: shouldn't get written again
  if Trim(edLanguage.Text) <> '' then
    Options.Store('language', Trim(edLanguage.Text))
  else
    Options.Store('language', 'neutral');

  Options.Delete('title');
  Options.Delete('title-default');    // deprecated: shouldn't get written again
  if Trim(edTitle.Text) <> '' then
    Options.Store('title', Trim(edTitle.Text))
  else
    Options.Store('title', '-');

  Options.Store('branding', chkBranding.Checked);

  if chkViewPort.Checked then
    Options.Store('viewport', 'mobile')
  else
    Options.Store('viewport', 'none');

  Options.Store('edge-compatibility', chkEdgeCompatibility.Checked);
end;

end.
