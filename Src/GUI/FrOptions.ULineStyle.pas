unit FrOptions.ULineStyle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FrOptions.UBase, UOptions, StdCtrls, Spin, FrOptions.UHelper;

type
  TLineStyleOptionsFrame = class(TBaseOptionsFrame)
    chkLineNumbering: TCheckBox;
    chkStriping: TCheckBox;
    seNumberWidth: TSpinEdit;
    lblNumberWidth: TLabel;
    lblPadding: TLabel;
    cbPadding: TComboBox;
    procedure chkLineNumberingClick(Sender: TObject);
  private
    fPaddingMap: TValueMap;
    procedure UpdateControls;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialise(const Options: TOptions); override;
    procedure UpdateOptions(const Options: TOptions); override;
  end;


implementation

{$R *.dfm}

{ TLineStyleOptionsFrame }

procedure TLineStyleOptionsFrame.chkLineNumberingClick(Sender: TObject);
begin
  UpdateControls;
end;

constructor TLineStyleOptionsFrame.Create(AOwner: TComponent);
begin
  inherited;
  fPaddingMap := TValueMap.Create;
  with fPaddingMap do
  begin
    Add('Space', 'space');
    Add('Zero (0)', 'zero');
    Add('Dot (.)', 'dot');
    Add('Dash (-)', 'dash');
  end;
  fPaddingMap.GetDescriptions(cbPadding.Items);
  cbPadding.ItemIndex := fPaddingMap.IndexOfValue('space');
  UpdateControls;
end;

destructor TLineStyleOptionsFrame.Destroy;
begin
  fPaddingMap.Free;
  inherited;
end;

procedure TLineStyleOptionsFrame.Initialise(const Options: TOptions);
begin
  chkLineNumbering.Checked := Options.GetParamAsBool('line-numbering');
  seNumberWidth.Value := Options.GetParamAsInt('line-number-width');
  cbPadding.ItemIndex := fPaddingMap.IndexOfValue(
    Options.GetParamAsStr('line-number-padding')
  );
  chkStriping.Checked := Options.GetParamAsBool('striping');
  UpdateControls;
end;

procedure TLineStyleOptionsFrame.UpdateOptions(const Options: TOptions);
begin
  Options.Store('line-numbering', chkLineNumbering.Checked);
  Options.Store('line-number-width', seNumberWidth.Value);
  Options.Store(
    'line-number-padding', fPaddingMap.ValueByIndex(cbPadding.ItemIndex)
  );
  Options.Store('striping', chkStriping.Checked);
end;

procedure TLineStyleOptionsFrame.UpdateControls;
begin
  lblNumberWidth.Enabled := chkLineNumbering.Checked;
  seNumberWidth.Enabled := chkLineNumbering.Checked;
  lblPadding.Enabled := chkLineNumbering.Checked;
  cbPadding.Enabled := chkLineNumbering.Checked;
end;

end.
