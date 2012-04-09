unit FrOptions.UMisc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FrOptions.UBase, FrOptions.UHelper, UOptions, StdCtrls, Spin;

type
  TMiscOptionsFrame = class(TBaseOptionsFrame)
    chkTrim: TCheckBox;
    lblSeparatorLines: TLabel;
    seSeparatorLines: TSpinEdit;
    lblSeparatorLinesEnd: TLabel;
    lblLanguage: TLabel;
    lblTitle: TLabel;
    edLanguage: TEdit;
    edTitle: TEdit;
    chkBranding: TCheckBox;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialise(const Options: TOptions); override;
    procedure UpdateOptions(const Options: TOptions); override;
  end;

implementation

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
begin
  chkTrim.Checked := TBooleanLookup.ToBoolean(Options.GetParam('trim'));

  seSeparatorLines.Value := StrToInt(Options.GetParam('separator-lines'));

  if Options.IsSet('language') then
    edLanguage.Text := Options.GetParam('language')
  else // 'language-neutral' must be set
    edLanguage.Text := '';

  if Options.IsSet('title') then
    edTitle.Text := Options.GetParam('title')
  else // 'title-default' must be set
    edTitle.Text := '';

  chkBranding.Checked := TBooleanLookup.ToBoolean(Options.GetParam('branding'));
end;

procedure TMiscOptionsFrame.UpdateOptions(const Options: TOptions);
begin
  Options.Update('trim', TBooleanLookup.ToString(chkTrim.Checked));

  Options.Update('separator-lines', IntToStr(seSeparatorLines.Value));

  Options.Delete('language');
  Options.Delete('language-neutral');
  if Trim(edLanguage.Text) <> '' then
    Options.Update('language', Trim(edLanguage.Text))
  else
    Options.Update('language-neutral');

  Options.Delete('title');
  Options.Delete('title-default');
  if Trim(edTitle.Text) <> '' then
    Options.Update('title', Trim(edTitle.Text))
  else
    Options.Update('title-default');

  Options.Update('branding', TBooleanLookup.ToString(chkBranding.Checked));
end;

end.
