program Launch64bitApponWow6432bitApp;
{$APPTYPE GUI} {$R *.res}
uses
  System.SysUtils, Winapi.Windows;

function Wow64DisableWow64FsRedirection(out OldValue: Pointer): Bool; stdcall;  external kernel32 name 'Wow64DisableWow64FsRedirection';
function Wow64RevertWow64FsRedirection(OldValue: Pointer): Bool; stdcall; external kernel32 name 'Wow64RevertWow64FsRedirection';
function Is32BitProcessRunningOnWow64: Boolean;
begin
{$IF DEFINED(WIN32)}
  var LWow64Process: BOOL := False;
  IsWow64Process(GetCurrentProcess, LWow64Process);
  Result := LWow64Process;
{$ELSEIF DEFINED(WIN64)}
  Result := False;
{$ENDIF}
end;

procedure Main;
var
  LStartupInfo: TStartupInfo;
  LProcessInfo: TProcessInformation;
  Wow64RedirectionEnabled: Pointer;
  LDisabledSuccessful: Boolean;
  LAppName: string;
begin
  LAppName := 'C:\Windows\System32\conhost.exe';
  UniqueString(LAppName);
  FillChar(LStartupInfo, SizeOf(LStartupInfo), 0); LStartupInfo.cb := SizeOf(LStartupInfo);
  LStartupInfo.dwFlags := STARTF_USESHOWWINDOW; LStartupInfo.wShowWindow := SW_HIDE;
  Wow64RedirectionEnabled := Pointer(-1);
  LDisabledSuccessful := Is32BitProcessRunningOnWow64 and Wow64DisableWow64FsRedirection(Wow64RedirectionEnabled);

  if CreateProcess(PChar(LAppName), nil, nil, nil, True, 0, nil, nil, LStartupInfo, LProcessInfo) then
    begin
      OutputDebugString('SUCCEEDED'); // WriteLn('SUCCEEDED');
      WaitForInputIdle(LProcessInfo.hProcess, INFINITE);
      CloseHandle(LProcessInfo.hThread);
      CloseHandle(LProcessInfo.hProcess);
      TerminateProcess(LProcessInfo.hProcess, 0);
    end else
    begin
      OutputDebugString('FAILED'); // WriteLn('FAILED');
    end;
  if LDisabledSuccessful then
    Wow64RevertWow64FsRedirection(Wow64RedirectionEnabled);
  OutputDebugString(PChar(Format('Name: %s, %d.%d Build: %d', [TOSVersion.Name, TOSVersion.Major, TOSVersion.Minor, TOSVersion.Build])));
end;

begin
  Main;
end.
