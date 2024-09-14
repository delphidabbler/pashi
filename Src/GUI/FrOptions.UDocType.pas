{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2021, Peter Johnson (www.delphidabbler.com).
 *
 * Frame that is used to edit various PasHi options relating to output document
 * type.
}


unit FrOptions.UDocType;

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
  Vcl.CheckLst,
  FrOptions.UHelper,
  FrOptions.UBase,
  UOptions;

type
  TDocTypeOptionsFrame = class(TBaseOptionsFrame)
    rbDocTypeFragment: TRadioButton;
    rbDocTypeComplete: TRadioButton;
    cbCompleteDocType: TComboBox;
    lblCompleteDocType: TLabel;
    clbInhibitStyling: TCheckListBox;
    lblInhibitStyling: TLabel;
    procedure rbDocTypeFragmentClick(Sender: TObject);
    procedure rbDocTypeCompleteClick(Sender: TObject);
  private
    fDocTypeMap: TValueMap;
    fInhibitStylesMap: TValueMap;
    procedure UpdateControls;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialise(const Options: TOptions); override;
    procedure UpdateOptions(const Options: TOptions); override;
  end;


implementation

uses
  System.StrUtils,
  System.Types,
  UUtils;

{$R *.dfm}

{ TDocTypeOptionsFrame }

constructor TDocTypeOptionsFrame.Create(AOwner: TComponent);
begin
  inherited;
  fDocTypeMap := TValueMap.Create;
  with fDocTypeMap do
  begin
    Add('XHTML', 'xhtml');
    Add('HTML 4 (deprecated)', 'html4');
    Add('HTML 5', 'html5');
  end;
  fDocTypeMap.GetDescriptions(cbCompleteDocType.Items);
  cbCompleteDocType.ItemIndex := fDocTypeMap.IndexOfValue('html5');

  fInhibitStylesMap := TValueMap.Create;
  fInhibitStylesMap.Add('White space', 'space');
  fInhibitStylesMap.Add('Comments', 'comment');
  fInhibitStylesMap.Add('Keywords', 'kwd');
  fInhibitStylesMap.Add('Identifiers', 'ident');
  fInhibitStylesMap.Add('Symbols', 'sym');
  fInhibitStylesMap.Add('String literals', 'str');
  fInhibitStylesMap.Add('Integers', 'num');
  fInhibitStylesMap.Add('Floating Point Numbers', 'float');
  fInhibitStylesMap.Add('Hexadecimal numbers', 'hex');
  fInhibitStylesMap.Add('Pre-processor instructions', 'preproc');
  fInhibitStylesMap.Add('Inline assembler', 'asm');
  fInhibitStylesMap.Add('Syntax Errors', 'err');
  fInhibitStylesMap.GetDescriptions(clbInhibitStyling.Items);
  clbInhibitStyling.ItemIndex := fInhibitStylesMap.IndexOfValue('space');

  UpdateControls;
end;

destructor TDocTypeOptionsFrame.Destroy;
begin
  fInhibitStylesMap.Free;
  fDocTypeMap.Free;
  inherited;
end;

procedure TDocTypeOptionsFrame.Initialise(const Options: TOptions);
var
  DocType: string;
  Styles: TStringDynArray;
  StylesStr: string;
  Style: string;
  Idx: Integer;
begin
  DocType := Options.GetParamAsStr('doc-type');
  if IsStrInList(DocType, ['fragment', 'frag'], False) then
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

  StylesStr := Options.GetParamAsStr('inhibit-styling');
  if Length(StylesStr) >= 2 then
  begin
    StylesStr := Copy(StylesStr, 2, Length(StylesStr) - 2);
    Styles := SplitString(StylesStr, ',');
    for Style in Styles do
    begin
      Idx := fInhibitStylesMap.IndexOfValue(Style);
      if Idx >= 0 then
        clbInhibitStyling.Checked[Idx] := True;
    end;
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
var
  Idx: Integer;
  Value: string;
begin
  if rbDocTypeFragment.Checked then
    Options.Store('doc-type', 'fragment')
  else if rbDocTypeComplete.Checked then
    Options.Store(
      'doc-type', fDocTypeMap.ValueByIndex(cbCompleteDocType.ItemIndex)
    );

  Value := '';
  for Idx := 0 to Pred(clbInhibitStyling.Count) do
  begin
    if clbInhibitStyling.Checked[Idx] then
    begin
      if Value = '' then
        Value := fInhibitStylesMap.ValueByIndex(Idx)
      else
        Value := Value + ',' + fInhibitStylesMap.ValueByIndex(Idx);
    end;
  end;
  Options.Store('inhibit-styling', '{' + Value + '}');
end;

procedure TDocTypeOptionsFrame.UpdateControls;
begin
  cbCompleteDocType.Enabled := rbDocTypeComplete.Checked;
  lblCompleteDocType.Enabled := rbDocTypeComplete.Checked;
end;

end.
