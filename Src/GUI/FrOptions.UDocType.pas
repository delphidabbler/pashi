{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * Frame that is used to edit various PasHi options relating to output document
 * type.
}


unit FrOptions.UDocType;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  FrOptions.UHelper, FrOptions.UBase, UOptions;

type
  TDocTypeOptionsFrame = class(TBaseOptionsFrame)
    rbDocTypeFragment: TRadioButton;
    rbDocTypeComplete: TRadioButton;
    cbCompleteDocType: TComboBox;
    lblCompleteDocType: TLabel;
    procedure rbDocTypeFragmentClick(Sender: TObject);
    procedure rbDocTypeCompleteClick(Sender: TObject);
  private
    fDocTypeMap: TValueMap;
    procedure UpdateControls;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialise(const Options: TOptions); override;
    procedure UpdateOptions(const Options: TOptions); override;
  end;


implementation

{$R *.dfm}

{ TDocTypeOptionsFrame }

constructor TDocTypeOptionsFrame.Create(AOwner: TComponent);
begin
  inherited;
  fDocTypeMap := TValueMap.Create;
  with fDocTypeMap do
  begin
    Add('XHTML', 'xhtml');
    Add('HTML 4', 'html4');
    Add('HTML 5', 'html5');
  end;
  fDocTypeMap.GetDescriptions(cbCompleteDocType.Items);
  cbCompleteDocType.ItemIndex := fDocTypeMap.IndexOfValue('html5');
  UpdateControls;
end;

destructor TDocTypeOptionsFrame.Destroy;
begin
  fDocTypeMap.Free;
  inherited;
end;

procedure TDocTypeOptionsFrame.Initialise(const Options: TOptions);
var
  DocType: string;
begin
  DocType := Options.GetParamAsStr('doc-type');
  if DocType = 'fragment' then
  begin
    rbDocTypeFragment.Checked := True;
    rbDocTypeComplete.Checked := False;
  end
  else
  begin
    rbDocTypeFragment.Checked := False;
    rbDocTypeComplete.Checked := True;
    cbCompleteDocType.ItemIndex := fDocTypeMap.IndexOfValue(DocType);
  end;
  UpdateControls;
end;

procedure TDocTypeOptionsFrame.rbDocTypeCompleteClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TDocTypeOptionsFrame.rbDocTypeFragmentClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TDocTypeOptionsFrame.UpdateOptions(const Options: TOptions);
begin
  if rbDocTypeFragment.Checked then
    Options.Store('doc-type', 'fragment')
  else if rbDocTypeComplete.Checked then
    Options.Store(
      'doc-type', fDocTypeMap.ValueByIndex(cbCompleteDocType.ItemIndex)
    );
end;

procedure TDocTypeOptionsFrame.UpdateControls;
begin
  cbCompleteDocType.Enabled := rbDocTypeComplete.Checked;
  lblCompleteDocType.Enabled := rbDocTypeComplete.Checked;
end;

end.
