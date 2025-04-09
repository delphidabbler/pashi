{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2006-2025, Peter Johnson (www.delphidabbler.com).
 *
 * Class that encapsulates and executes a command line application and
 * optionally redirects the application's standard input, output and error.
}


unit UConsoleApp;


interface


uses
  // Delphi
  System.Classes,
  Winapi.Windows;


const
  // Constants for working in milliseconds
  cOneSecInMS = 1000;               // one second in milliseconds
  cOneMinInMS = 60 * cOneSecInMS;   // one minute in milliseconds
  // Default values for some TConsoleApp properties
  cDefTimeSlice = 50;               // default time slice allocated to app
  cDefMaxExecTime = cOneMinInMS;    // maximum execution time of app


type

  ///  <summary>Class that encapsulates and executes a command line application.
  ///  </summary>
  ///  <remarks>The class optionally redirects the application's standard input,
  ///  output and error. The application is excuted in time slices and the class
  ///  triggers an event between time slices.</remarks>
  TConsoleApp = class(TObject)
  private
    fOnWork: TNotifyEvent;
    fStdIn: THandle;
    fStdOut: THandle;
    fStdErr: THandle;
    fExitCode: LongWord;
    fMaxExecTime: LongWord;
    fProcessHandle: THandle;
    fErrorMessage: string;
    fErrorCode: LongWord;
    fVisible: Boolean;
    fTimeSlice: Integer;
    function MonitorProcess: Boolean;
    function SetExitCode: Boolean;
    procedure TriggerWorkEvent;
    procedure SetMaxExecTime(const Value: LongWord);
    procedure SetTimeSlice(const Value: Integer);
  protected
    function StartProcess(const CmdLine, CurrentDir: string;
      out ProcessInfo: TProcessInformation): Boolean;
    procedure DoWork; virtual;
    procedure RecordAppError(const Code: LongWord; const Msg: string);
    procedure RecordWin32Error;
    procedure ResetError;
  public
    constructor Create;
    function Execute(const CmdLine, CurrentDir: string): Boolean;
    property StdIn: THandle read fStdIn write fStdIn default 0;
    property StdOut: THandle read fStdOut write fStdOut default 0;
    property StdErr: THandle read fStdErr write fStdErr default 0;
    property Visible: Boolean read fVisible write fVisible default False;
    property MaxExecTime: LongWord read fMaxExecTime write SetMaxExecTime
      default cDefMaxExecTime;
    property TimeSlice: Integer read fTimeSlice write SetTimeSlice
      default cDefTimeSlice;
    property ProcessHandle: THandle read fProcessHandle;
    property ExitCode: LongWord read fExitCode;
    property ErrorCode: DWORD read fErrorCode;
    property ErrorMessage: string read fErrorMessage;
    property OnWork: TNotifyEvent read fOnWork write fOnWork;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Vcl.Forms;


const
  // Mask that is ORd with application error codes: according to Windows API
  // docs, error codes with bit 29 set are reserved for application use.
  cAppErrorMask = 1 shl 29;


resourcestring
  // Error message
  sErrTimeout = 'Application timed out';


{ TConsoleApp }

constructor TConsoleApp.Create;
begin
  inherited Create;
  // Set default property values
  fMaxExecTime := cDefMaxExecTime;
  fTimeSlice := cDefTimeSlice;
  fVisible := False;
  fStdIn := 0;
  fStdOut := 0;
  fStdErr := 0;
end;

procedure TConsoleApp.DoWork;
begin
  TriggerWorkEvent;
end;

function TConsoleApp.Execute(const CmdLine, CurrentDir: string): Boolean;
var
  ProcessInfo: TProcessInformation; // information about process
begin
  fExitCode := 0;
  ResetError;
  Result := StartProcess(CmdLine, CurrentDir, ProcessInfo);
  if Result then
  begin
    // Process started: monitor its progress
    try
      fProcessHandle := ProcessInfo.hProcess;
      Result := MonitorProcess and SetExitCode;
    finally
      // Process ended: tidy up
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      fProcessHandle := 0;
    end;
  end
  else
  begin
    // Couldn't start process: error
    RecordWin32Error;
    fProcessHandle := 0;
  end;
end;

function TConsoleApp.MonitorProcess: Boolean;
var
  TimeToLive: Integer;  // Milliseconds app has left before timing out
  AppState: DWORD;      // State of app after last wait
begin
  Result := True;
  TimeToLive := fMaxExecTime;
  repeat
    // Pause and wait for app - length determined by TimeSlice property
    AppState := WaitForSingleObject(fProcessHandle, fTimeSlice);
    Application.ProcessMessages;
    Dec(TimeToLive, fTimeSlice);
    if AppState = WAIT_FAILED then
    begin
      RecordWin32Error;
      Result := False;
    end
    else
      // All OK: do inter-timeslice processing
      DoWork;
  until (AppState <> WAIT_TIMEOUT) or (TimeToLive <= 0);
  // App halted or timed out: check which
  if AppState = WAIT_TIMEOUT then
  begin
    RecordAppError(1, sErrTimeout);
    Result := False;
  end;
end;

procedure TConsoleApp.RecordAppError(const Code: LongWord;
  const Msg: string);
begin
  fErrorMessage := Msg;
  fErrorCode := Code or cAppErrorMask;
end;

procedure TConsoleApp.RecordWin32Error;
begin
  fErrorCode := GetLastError;
  fErrorMessage := SysErrorMessage(fErrorCode);
end;

procedure TConsoleApp.ResetError;
begin
  fErrorCode := 0;
  fErrorMessage := '';
end;

function TConsoleApp.SetExitCode: Boolean;
begin
  Result := GetExitCodeProcess(fProcessHandle, fExitCode);
  if not Result then
    RecordWin32Error;
end;

procedure TConsoleApp.SetMaxExecTime(const Value: LongWord);
begin
  if Value = 0 then
    fMaxExecTime := cDefMaxExecTime
  else
    fMaxExecTime := Value;
end;

procedure TConsoleApp.SetTimeSlice(const Value: Integer);
begin
  if Value > 0 then
    fTimeSlice := Value
  else
    fTimeSlice := cDefTimeSlice;
end;

function TConsoleApp.StartProcess(const CmdLine, CurrentDir: string;
  out ProcessInfo: TProcessInformation): Boolean;
const
  // Maps Visible property to required wondows flags
  cShowFlags: array[Boolean] of Integer = (SW_HIDE, SW_SHOW);
var
  StartInfo: TStartupInfo;  // Information about process from OS
  PCurrentDir: PChar;       // Pointer to current directory
begin
  // Set up startup information structure
  FillChar(StartInfo, Sizeof(StartInfo),#0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    if (fStdIn <> 0) or (fStdOut <> 0) or (fStdErr <> 0) then
      dwFlags := dwFlags or STARTF_USESTDHANDLES; // we are redirecting
    hStdInput := fStdIn;                  // std handles (non-zero => redirect)
    hStdOutput := fStdOut;
    hStdError := fStdErr;
    wShowWindow := cShowFlags[fVisible];  // show or hide window
  end;
  // We set current directory to nil if CurrentDir is ''
  if CurrentDir <> '' then
    PCurrentDir := PChar(CurrentDir)
  else
    PCurrentDir := nil;
  // Try to create the process
  Result := CreateProcess(
    nil,
    PChar(CmdLine),
    nil,
    nil,
    True,
    0,
    nil,
    PCurrentDir,
    StartInfo,
    ProcessInfo
  );
end;

procedure TConsoleApp.TriggerWorkEvent;
begin
  if Assigned(fOnWork) then
    fOnWork(Self);
end;

end.

