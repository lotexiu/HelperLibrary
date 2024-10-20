unit UThreadUtils;

interface

uses
  Diagnostics,
  Generics.Collections,
  Classes,
  SysUtils,
  SyncObjs,
  UGenericDictionary,
  UThreadData;

type
  TThreadUtils = class
  private
    class var FDictionary: TGenericDictionary;
    class procedure _Create;
    class procedure _Destroy;

    class procedure _onThread<T>(AThreadData: TThreadData; AData: T; AProc: TProc<T>); overload;
    class procedure _onThread(AThreadData: TThreadData; AProc: TProc); overload;
  public
    class procedure addThreadData(AThreadData: TThreadData); overload;
    class function getThreadData(AKey: String): TThreadData; overload;
    class procedure DestroyThread(AKey: String);

    { Data Share }
    class procedure onThread<T>(AData: T; AProc: TProc<T>); overload;
    class procedure onThread<T>(AInterval: Integer; AData: T; AProc: TProc<T>); overload;
    class procedure onThread<T>(AThreadType: String; AData: T; AProc: TProc<T>); overload;
    class procedure onThread<T>(AThreadType: String; AData: T; AMaxThreadsRunning: Integer; AProc: TProc<T>); overload;
    class procedure onThread<T>(AThreadType: String; AData: T; AMaxThreadsRunning, AInterval: Integer; AProc: TProc<T>); overload;

    { Without Data Share}
    class procedure onThread(AProc: TProc); overload;
    class procedure onThread(AInterval: Integer; AProc: TProc); overload;
    class procedure onThread(AThreadType: String; AProc: TProc); overload;
    class procedure onThread(AThreadType: String; AMaxThreadsRunning: Integer; AProc: TProc); overload;
    class procedure onThread(AThreadType: String; AMaxThreadsRunning, AInterval: Integer; AProc: TProc); overload;

  end;

implementation

uses
  UWindowsUtils,
  UGenericUtils,
  UArrayUtils,
  UFileUtils;

{ TThreadUtils }

class procedure TThreadUtils._Create;
begin
  if TGenericUtils.isEmptyOrNull(FDictionary) Then
    FDictionary := TGenericDictionary.Create;
end;

class procedure TThreadUtils._Destroy;
var
  LList: TArray<TThreadData>;
begin
  LList := TThreadUtils.FDictionary.Values<TThreadData>;
  {Waiting for closing all threads}
  TArrayUtils.forEach<TThreadData>(LList,
  procedure(out AValue: TThreadData; out ABreak: Boolean)
  begin
    AValue.Loop := False; {Disable Loop}
    AValue.MaxThreadsRunning := 0; {Max Threads to 0}
    while AValue.ThreadRunningCount > 0 do
      Sleep(50);
  end);
  FDictionary.FreeValuesOnDestroy := True;
  TGenericUtils.freeAndNil(FDictionary);
end;

class procedure TThreadUtils._onThread(AThreadData: TThreadData; AProc: TProc);
begin
  _onThread<TObject>(AThreadData, nil,
  procedure(AValue: TObject)
  begin
    AProc;
  end);
end;

class procedure TThreadUtils._onThread<T>(AThreadData: TThreadData; AData: T; AProc: TProc<T>);
begin
  AThreadData.Enter; {Prevent data shuffle}
  AThreadData.WaitToOpen; {Waiting a closed thread}
  AThreadData.addThread; {Adding Thread}
  TThread.CreateAnonymousThread( {Opening thread}
  procedure
    var FWatch: TStopwatch;
    var FThData: TThreadData;
    var FData: T;
  begin
    FThData := AThreadData;
    FData := AData;
    FWatch := TStopwatch.StartNew; {Watching}
    try
      AProc(FData); {Execute received procedure}
    except
      on E:Exception do
      begin
        FThData.addFail; {Add fail on procedure exception}
      end;
    end;
    FWatch.Stop; {Stop Watching}
    FThData.removeThread; {Removing Thread}
    FThData.addExecutionTime(FWatch.ElapsedMilliseconds); {Add for Avarage}
    TWindowsUtils.cleanAppMemoryFromLeak; {CleanMemory}
    TThread.CurrentThread.Terminate; {Closing Thread}
    if FThData.Loop then begin {Is Loop Thread}
      sleep(FThData.Interval); {Wait Interval}
      _onThread(FThData, AData, AProc); {Open new Thread}
    end
    else if FThData.ThreadType = 'global' then
      TGenericUtils.freeAndNil(FThData);
  end).Start;
  AThreadData.Release;
end;



class procedure TThreadUtils.addThreadData(AThreadData: TThreadData);
begin
  FDictionary.add<TThreadData>(AThreadData.ThreadType, AThreadData);
end;

class procedure TThreadUtils.DestroyThread(AKey: String);
begin
  FDictionary.remove<TThreadData>(AKey).Free;
end;

class function TThreadUtils.getThreadData(AKey: String): TThreadData;
begin
  Result := FDictionary.get<TThreadData>(AKey);
  if TGenericUtils.isEmptyOrNull(Result) then
  begin
    Result := TThreadData.Create(AKey);
    FDictionary.add(AKey,Result);
  end;
end;

{ Data Share }
class procedure TThreadUtils.onThread<T>(AData: T; AProc: TProc<T>);
var
  FThread: TThreadData;
begin
  FThread := TThreadData.Create;
  _onThread<T>(FThread, TValue.From<T>(AData).AsType<T>, AProc);
end;

class procedure TThreadUtils.onThread<T>(AInterval: Integer; AData: T; AProc: TProc<T>);
var
  FThread: TThreadData;
begin
  FThread := TThreadData.Create(AInterval);
  _onThread<T>(FThread, AData, AProc);
end;

class procedure TThreadUtils.onThread<T>(AThreadType: String; AData: T; AProc: TProc<T>);
var
  FThread: TThreadData;
begin
  if FDictionary.containsKey(AThreadType) then
    FThread := FDictionary.get<TThreadData>(AThreadType)
  else
  begin
    FThread := TThreadData.Create(AThreadType);
    FDictionary.add<TThreadData>(AThreadType, FThread);
  end;
  _onThread<T>(FThread, AData, AProc);
end;

class procedure TThreadUtils.onThread<T>(AThreadType: String; AData: T; AMaxThreadsRunning: Integer; AProc: TProc<T>);
var
  FThread: TThreadData;
begin
  if FDictionary.containsKey(AThreadType) then
  begin
    FThread := FDictionary.get<TThreadData>(AThreadType);
    FThread.MaxThreadsRunning := AMaxThreadsRunning;
    FThread.Loop := False;
  end
  else
  begin
    FThread := TThreadData.Create(AThreadType,AMaxThreadsRunning);
    FDictionary.add<TThreadData>(AThreadType, FThread);
  end;
  _onThread<T>(FThread, AData, AProc);
end;

class procedure TThreadUtils.onThread<T>(AThreadType: String; AData: T; AMaxThreadsRunning, AInterval: Integer; AProc: TProc<T>);
var
  FThread: TThreadData;
begin
  if FDictionary.containsKey(AThreadType) then
  begin
    FThread := FDictionary.get<TThreadData>(AThreadType);
    FThread.MaxThreadsRunning := AMaxThreadsRunning;
    FThread.Interval := AInterval;
    FThread.Loop := True;
  end else
  begin
    FThread := TThreadData.Create(Ainterval,AThreadType,AMaxThreadsRunning);
    FDictionary.add<TThreadData>(AThreadType, FThread);
  end;
  _onThread<T>(FThread, AData, AProc);
end;


{ Without Data Share}
class procedure TThreadUtils.onThread(AProc: TProc);
begin
  onThread<TObject>(nil,
    procedure(AValue: TObject) begin AProc end);
end;

class procedure TThreadUtils.onThread(AInterval: Integer; AProc: TProc);
begin
  onThread<TObject>(AInterval, nil,
    procedure(AValue: TObject) begin AProc end);
end;

class procedure TThreadUtils.onThread(AThreadType: String; AProc: TProc);
begin
  onThread<TObject>(AThreadType, nil,
    procedure(AValue: TObject) begin AProc end);
end;

class procedure TThreadUtils.onThread(AThreadType: String; AMaxThreadsRunning: Integer; AProc: TProc);
begin
  onThread<TObject>(AThreadType, nil, AMaxThreadsRunning,
    procedure(AValue: TObject) begin AProc end);
end;

class procedure TThreadUtils.onThread(AThreadType: String; AMaxThreadsRunning, AInterval: Integer; AProc: TProc);
begin
  onThread<TObject>(AThreadType, nil, AMaxThreadsRunning, AInterval,
    procedure(AValue: TObject) begin AProc end);
end;


initialization
  TThreadUtils._Create;

finalization
  TThreadUtils._Destroy;

end.
