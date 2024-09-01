unit UDebugUtils;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Winapi.Windows,
  Winapi.TlHelp32;

type
  TDataInfo = record
    PID: DWORD;
    ProcessName: String;
    Thread: DWORD;
    FileName: String;
    Line: Integer;
    CallBy: String
  end;

  TDebugUtils = class
    class function getMethodName(ALevel: Integer): String;
    class function getCurrentDataInfo(ALevel: Integer): TDataInfo;
  end;

implementation

uses
  JclDebug;

class function TDebugUtils.getCurrentDataInfo(ALevel: Integer): TDataInfo;
begin
  Result.PID := GetCurrentProcessId;
  Result.ProcessName := extractfilename(paramstr(0));
  Result.Thread := TThread.CurrentThread.ThreadID;
  Result.FileName := FileByLevel(ALevel);
  Result.Line := LineByLevel(ALevel);
  Result.CallBy := getMethodName(ALevel)
end;

class function TDebugUtils.getMethodName(ALevel: Integer): String;
var
  FNomeReal: String;
  FPosInicio, FPosFim: Integer;
begin
  FNomeReal := ProcByLevel(ALevel + 1);
  Result := FNomeReal;
  FPosInicio := Pos('%', FNomeReal) + 1;
  FPosFim := Pos('$', FNomeReal, FPosInicio) - 1;
  if (FPosInicio > 1) or (FPosFim > 0) then
  begin
    if FPosInicio = 1 then
      FPosFim := FPosFim + 1;

    Result := Copy(FNomeReal, FPosInicio, FPosFim - FPosInicio);
  end
end;

end.

