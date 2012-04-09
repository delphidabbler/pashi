unit FrOptions.UCSS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FrOptions.UHelper, FrOptions.UBase, UOptions, ActnList, StdActns,
  StdCtrls;

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
  Options.Delete('embed-ccc');
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
