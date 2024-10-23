unit UThreadData;

interface

uses
  SyncObjs,
  SysUtils,
  Math;

type
  TThreadData = class
  private
    {Settings}
    FLoop: Boolean;
    FInterval: Integer;
    {Time}
    FExecutionCount: Integer;
    FExecutionFailCount: Integer;
    FAvarage: Extended;
    {Thread Type Settings}
    FThreadType: String;
    FMaxThreadsRunning: Integer;
    FThreadRunningCount: Integer;
    FCriticalSection: TCriticalSection;

    function getAvarage: Extended;
    procedure setThreadCount(const Value: Integer);
    procedure setThreadMax(const Value: Integer);

    procedure initValues;
    function getHasThreadRunning: Boolean;
  public
    constructor Create; overload;
    constructor Create(AThreadType: String); overload;
    constructor Create(AInterval: Integer); overload;
    constructor Create(AThreadType: String; AMaxThreadsRunning: Integer); overload;
    constructor Create(AInterval: Integer; AThreadType: String; AMaxThreadsRunning: Integer); overload;
    destructor Destroy; override;

    property Loop: Boolean read FLoop write FLoop;
    property Interval: Integer read FInterval write FInterval;
    property ExecutionCount: Integer read FExecutionCount;
    property ExecutionFailCount: Integer read FExecutionFailCount write FExecutionFailCount;
    property Avarage: Extended read getAvarage;
    property ThreadType: String read FThreadType write FThreadType;
    property MaxThreadsRunning: Integer read FMaxThreadsRunning write setThreadMax;
    property ThreadRunningCount: Integer read FThreadRunningCount write setThreadCount;
    property HasThreadRunning: Boolean read getHasThreadRunning;

    procedure ContinueOnAllClosed;
    procedure WaitToOpen;
    procedure StopCurrentThread(ATime: Integer);
    procedure Enter;
    procedure Release;
    procedure Clear;

    procedure addFail;
    procedure addExecutionTime(ATime: Integer);
    procedure addThread;
    procedure removeThread;

    function toString: String;
  end;

implementation

uses
  Classes;

{ TThreadData }

constructor TThreadData.Create;
begin
  initValues;
end;

constructor TThreadData.Create(AThreadType: String);
begin
  initValues;
  FThreadType := AThreadType;
end;

constructor TThreadData.Create(AInterval: Integer);
begin
  initValues;
  FInterval := AInterval;
  FLoop := True;
end;

constructor TThreadData.Create(AThreadType: String; AMaxThreadsRunning: Integer);
begin
  initValues;
  FThreadType := AThreadType;
  FMaxThreadsRunning := AMaxThreadsRunning;
end;

constructor TThreadData.Create(AInterval: Integer; AThreadType: String; AMaxThreadsRunning: Integer);
begin
  initValues;
  FInterval := AInterval;
  FLoop := True;
  FThreadType := AThreadType;
  FMaxThreadsRunning := AMaxThreadsRunning;
end;

destructor TThreadData.Destroy;
begin
  FreeAndNil(FCriticalSection);
  inherited;
end;

procedure TThreadData.enter;
begin
  FCriticalSection.Enter;
end;

procedure TThreadData.addExecutionTime(ATime: Integer);
begin
  Inc(FExecutionCount);
  FAvarage := ((FAvarage * (FExecutionCount-1)) + ATime) / FExecutionCount;
end;

procedure TThreadData.addFail;
begin
  Inc(FExecutionFailCount);
end;

procedure TThreadData.addThread;
begin
  ThreadRunningCount := ThreadRunningCount + 1;
end;

procedure TThreadData.Clear;
begin
  FExecutionCount := 0;
  FExecutionFailCount := 0;
  FAvarage := 0;
end;

procedure TThreadData.continueOnAllClosed;
begin
  while hasThreadRunning do
    sleep(100);
end;

function TThreadData.getAvarage: Extended;
begin
  Result := Math.Max(Math.RoundTo(FAvarage/1000, -2),0);
end;

function TThreadData.getHasThreadRunning: Boolean;
begin
  Result := ThreadRunningCount > 0
end;

procedure TThreadData.WaitToOpen;
var
  FResult: Boolean;
begin
  repeat
    FResult :=  (FMaxThreadsRunning > 0) and
                (ThreadRunningCount >= MaxThreadsRunning);
    sleep(50);
  until not FResult;
end;

procedure TThreadData.StopCurrentThread(ATime: Integer);
begin
  addExecutionTime(ATime);          { Add for Avarage }
  TThread.CurrentThread.Terminate;  { Closing Thread  }
  if ((MaxThreadsRunning <> -1) and Loop) then
  begin
    sleep(Interval);  { Wait Interval   }
    removeThread;     { Removing Thread }
  end
  else
    removeThread; {Removing Thread}
end;

procedure TThreadData.setThreadCount(const Value: Integer);
begin
  FThreadRunningCount := Value;
end;

procedure TThreadData.setThreadMax(const Value: Integer);
begin
  FMaxThreadsRunning := Value;
end;

function TThreadData.toString: String;
begin
  Result :=
    'Name       '+ThreadType+sLineBreak+
    'Running    '+ThreadRunningCount.ToString+sLineBreak+
    'Avarage    '+Avarage.ToString+sLineBreak+
    'Executions '+ExecutionCount.ToString+sLineBreak+
    'Fails      '+ExecutionFailCount.ToString+sLineBreak+
    'Max        '+MaxThreadsRunning.ToString+sLineBreak+
    'Interval   '+Interval.ToString;
end;

procedure TThreadData.initValues;
begin
  {Settings}
  FLoop := False;
  FInterval := 0;
  {Time}
  FExecutionCount := 0;
  FExecutionFailCount := 0;
  FAvarage := 0;
  {Threa Type Settings}
  FThreadType := 'global';
  FMaxThreadsRunning := 0;
  FThreadRunningCount := 0;
  FCriticalSection := TCriticalSection.Create;
end;

procedure TThreadData.release;
begin
  FCriticalSection.Release;
end;

procedure TThreadData.removeThread;
begin
  ThreadRunningCount := ThreadRunningCount - 1;
end;

end.
