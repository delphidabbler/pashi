{
 * Change log
 *
 * 04 Jun 2005 - Original version
 * 30 May 2009 - Changed $MESSAGE compiler directive message type from WARN to
 *               FATAL
}

unit Test;

{$MESSAGE FATAL 'Unit to test syntax highlighter - do not compile'}


interface


uses
  Dialogs, Messages,
  Windows, Classes;


{This is a curly comment}procedure Fred(const Str: string);{surrounding some code}
procedure Bert; stdcall;(* this is  a old style comment*)
// single line comment
//another single line comment
{$R+}            {<= directive}
(*$WARNINGS OFF*)// <= directive
//$not a directive
{.$WARNINGS ON}  // <= commented out directive
(* This is a
multi-line old
style comment *)
{
  And this is a three line curly comment
}


exports Bert index 4 name 'bert1';

function Beeper(Kind: UINT): Bool;


type
  TMyClass = class(TObject)
  private
    fNumbers: array[0..1] of Integer;
    fList: TStringList;
    function GetItem(I: Integer): string;
    function GetNumber(const Index: Integer): Integer;
    procedure SetNumber(const Index, Value: Integer);
    procedure WMUser(var Msg: TMessage); message WM_USER;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const S: string); overload;
    procedure Add(const Index: Integer); overload;
    property Items[Index: Integer]: string read GetItem; default;
    property Number1: Integer index 0 read GetNumber write SetNumber default 4;
    property Number2: Integer index 1 read GetNumber write SetNumber nodefault;
  end;


implementation


uses
  SysUtils;


function Beeper(Kind: UINT): Bool; external 'user32.dll' name 'MessageBeep';

procedure Bert;
  {Bert proc here}
const
  cBert = 'Bert was here';
  cSSet = (.'a'..'z'.);
  cNSet = (.7..12.) + (. 8, 12..14 .);
  cXSet = [23..23];
  Override =  'harry';
var
  S, T: string;
  C1, C2, C3: Char;
  N1, N2, N3: Integer;
  F1, F2, F3, F4: Double;
  A: set of Char;
  H: Integer;
begin
  (*.12.*)
  OutputDebugString(cBert);
  OutputDebugString('This is bert''s own routine');
  A := cSSet;
  S := '''A quoted string''';
  H := $2aF9 ;
  C1 := #32;
  C2 := #$FF;
  C3 := 'a';
  N1 := 12345 div 46;
  N2 := -12345 mod 47;
  N3 := +1 shl $4;
  F1 := 0.23 * 10.e+45 + 0e3;
  F2 := 0.34567e-78;
  F3 := 124e72 / -34E-42;F4 := 1.
  ;
  T := 'String ending with EOL containing floats %f, %f, %f'#13#$0A
    + 'and numbers %d, %d, %d';
  T := Format(T, [F1, F2+0.2, F3+F4, N1-4, N2+5, Round(N3 * 10.5678) - $34]);
  Fred(S);
  Fred(IntToStr(H));
  Fred(T + C1 + C2 + C3 + Override);
  (* This is an {embedded} comment *)
  {Another (*$Embedded comment*)}
  //(* a third{embedded} comment *)
  (* a final { // }embedded comment *)
end;

procedure Fred(const Str: string);
  {Fred here}
var
  My: TMyClass;
  Message: string;
begin
  My := TMyClass.Create;
  try
    My.Add(Str);
    My.Add(Length(Str));
    My.Number1 := 10;
    My.Number2 := My.Number1 * 20;
    Message := My[0];
    ShowMessage(Message);
  finally
    My.Free;
  end;
end;

{ TMyClass }

procedure TMyClass.Add(const S: string);
begin
  fList.Add(S);
end;

procedure TMyClass.Add(const Index: Integer);
begin
  fList.Add(IntToStr(Index));
end;

constructor TMyClass.Create;
begin
  inherited Create;
  fNumbers[0] := 4;
  fNumbers[1] := 0;
  fList := TStringList.Create;
end;

destructor TMyClass.Destroy;
begin
  fList.Free;
  inherited;
end;

function TMyClass.GetItem(I: Integer): string;
begin
  Result := fList[I];
end;

function TMyClass.GetNumber(const Index: Integer): Integer;
begin
  Result := fNumbers[Index];
end;

procedure TMyClass.SetNumber(const Index, Value: Integer);
begin
  fNumbers[Index] := Value;
end;

procedure TMyClass.WMUser(var Msg: TMessage);
var
  Number: Integer;
begin
  // ASM test code
  Number := 0;
  asm
    MOV EAX,1234H       // ASM comment here
    {$IFNDEF FRED}
    MOV Number,EAX      (* old comment here *)
    CMP     BH,'-'
    CMP     EAX,'cfe'
    CMP     BH,$12
    CMP     BH,12.3
    CMP     BH,12+2
    {$ENDIF}
  end;
  ShowMessageFmt('%d', [Number]);
end;


end. // of sample progam (single line comment with no EOL after)