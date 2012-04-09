unit FrOptions.UBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs,

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
