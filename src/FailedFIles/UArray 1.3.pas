unit UArray;

interface

uses
  Rtti,
  TypInfo,
  Generics.Collections,
  SysUtils,
  UArrayReferences;

var
  xArrayLogs: Boolean = False;

type
  RArray<T> = record
  private
    FValue: TArray<T>;
    function getItem(AIndex: Integer): T;
    procedure setItem(AIndex: Integer; const Value: T);
    function getCount: Integer;

    procedure createMethod;
    procedure updateArray(AIndex: Integer);
  public
    class operator Initialize (out Dest: RArray<T>);
    class operator Finalize (var Dest: RArray<T>);

    property Item[Index: Integer]: T read getItem write setItem; default;
    property Count: Integer read getCount;

    procedure forEach(AProc: TForEachIndex<T>); overload;
  end;

implementation

uses
  StrUtils,
  UGenericUtils,
  UArrayUtils,
  UThreadUtils,
  Classes;

{ RArray<T> }

procedure RArray<T>.createMethod;
begin

end;

class operator RArray<T>.Finalize(var Dest: RArray<T>);
begin
end;

class operator RArray<T>.Initialize(out Dest: RArray<T>);
begin
end;

procedure RArray<T>.forEach(AProc: TForEachIndex<T>);
begin
  TArrayUtils.forEach<T>(@FValue,AProc);
end;

function RArray<T>.getCount: Integer;
begin
  Result := Length(FValue);
end;

function RArray<T>.getItem(AIndex: Integer): T;
begin
  updateArray(AIndex);
  Result := FValue[AIndex]; {Force to keep the same Pointer!}
end;

procedure RArray<T>.setItem(AIndex: Integer; const Value: T);
begin
  updateArray(AIndex);
  FValue[AIndex] := Value;
end;

{ Trying to use another thread to update the current size }
procedure RArray<T>.updateArray(AIndex: Integer);
var
  LSize, LCount: Integer;
  LThreadNumber: String;
begin
  LSize := AIndex+1;
  LCount := Count;
  LThreadNumber := IntToStr(TThread.Current.ThreadID);
  TThreadUtils.onThread<TArray<Pointer>>(LThreadNumber,[@LSize, @LCount, @FValue],
  procedure(AValues: TArray<Pointer>)
  var
    LContext: TRttiContext;
    LRtti: TRttiType;
    LList: TArray<Pointer>;
  begin
    LRtti := TGenericUtils.rttiType<TArray<T>>(LContext);
    if (Integer(AValues[0]^) > Integer(AValues[1]^)) then {Size > Count}
    begin
      SetLength(TArray<T>((AValues[2])^), Integer(AValues[0]^));
    end;
  end);
  with TThreadUtils.getThreadData(LThreadNumber) do
  begin
    while (ExecutionCount <= 0) or (HasThreadRunning) do
      Sleep(1);
  end;
  TThreadUtils.DestroyThread(LThreadNumber);
end;

end.

