{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2021, Peter Johnson (www.delphidabbler.com).
 *
 * Frame that is used to edit various PasHi options relating cascading style
 * sheets.
}


unit FrOptions.UCSS;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Actions,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.StdActns,
  Vcl.StdCtrls,
  FrOptions.UHelper,
  FrOptions.UBase,
  UOptions;

type
  TCSSOptionsFrame = class(TBaseOptionsFrame)
    rbEmbedCSS: TRadioButton;
    rbLinkCSS: TRadioButton;
    chkLegacyCSS: TCheckBox;
    cbCSSFile: TComboBox;
    lblCSSFile: TLabel;
    lblCSSURL: TLabel;
    edCSSURL: TEdit;
    chkHideCSS: TCheckBox;
    btnCSSFileDlg: TButton;
    alCSSActions: TActionList;
    actCSSFileBrowse: TFileOpen;
    rbDefaultCSS: TRadioButton;
    lblHideCSSDeprecated: TLabel;
    lblLegacyCSSDeprecated: TLabel;
    procedure RadioButtonClick(Sender: TObject);
    procedure actCSSFileBrowseAccept(Sender: TObject);
  private
    fCSSFileMap: TValueMap;
    procedure UpdateControls;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialise(const Options: TOptions); override;
    procedure UpdateOptions(const Options: TOptions); override;
  end;

implementation

uses
  UGUIConfigFiles;

{$R *.dfm}

{ TCSSOptionsFrame }

procedure TCSSOptionsFrame.actCSSFileBrowseAccept(Sender: TObject);
begin
  cbCSSFile.Text := actCSSFileBrowse.Dialog.FileName;
end;

constructor TCSSOptionsFrame.Create(AOwner: TComponent);
var
  CSSFiles: TArray<string>;
  CSSFile: string;
begin
  inherited;
  CSSFiles := TGUIConfigFiles.CSSFiles;
  fCSSFileMap := TValueMap.Create;
  for CSSFile in CSSFiles do
    fCSSFileMap.Add(CSSFile, CSSFile);
  fCSSFileMap.GetDescriptions(cbCSSFile.Items);
  UpdateControls;
end;

destructor TCSSOptionsFrame.Destroy;
begin
  fCSSFileMap.Free;
  inherited;
end;

procedure TCSSOptionsFrame.Initialise(const Options: TOptions);
begin
  rbDefaultCSS.Checked := Options.IsSet('default-css');
  rbEmbedCSS.Checked := Options.IsSet('embed-css');
  if Options.IsSet('embed-css') then
    cbCSSFile.Text := Options.GetParamAsStr('embed-css');
  chkHideCSS.Checked := Options.GetParamAsBool('hide-css');
  rbLinkCSS.Checked := Options.IsSet('link-css');
  if Options.IsSet('link-css') then
    edCSSURL.Text := Options.GetParamAsStr('link-css');
  chkLegacyCSS.Checked := Options.GetParamAsBool('legacy-css');
  UpdateControls;
end;

procedure TCSSOptionsFrame.RadioButtonClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TCSSOptionsFrame.UpdateControls;
begin
  lblCSSFile.Enabled := rbEmbedCSS.Checked;
  cbCSSFile.Enabled := rbEmbedCSS.Checked;
  btnCSSFileDlg.Enabled := rbEmbedCSS.Checked;
  lblCSSURL.Enabled := rbLinkCSS.Checked;
  edCSSURL.Enabled := rbLinkCSS.Checked;
  chkHideCSS.Enabled := rbDefaultCSS.Checked or rbEmbedCSS.Checked;
end;

procedure TCSSOptionsFrame.UpdateOptions(const Options: TOptions);
begin
  Options.Delete('default-css');
  Options.Delete('embed-css');
  Options.Delete('link-css');
  if rbDefaultCSS.Checked then
    Options.Store('default-css')
  else if rbEmbedCSS.Checked then
  begin
    if Trim(cbCSSFile.Text) = '' then
      raise Exception.Create('You must enter a CSS file to be embedded');
    Options.Store('embed-css', cbCSSFile.Text);
  end
  else if rbLinkCSS.Checked then
  begin
    if Trim(edCSSURL.Text) = '' then
      raise Exception.Create('You must enter URL of CSS file to be linked');
    Options.Store('link-css', edCSSURL.Text);
  end;
  Options.Store('legacy-css', chkLegacyCSS.Checked);
  Options.Store('hide-css', chkHideCSS.Checked);
end;

end.
