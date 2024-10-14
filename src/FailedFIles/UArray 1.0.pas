unit UArray;

interface

uses
  Rtti,
  Generics.Collections,
  UArrayReferences;

type
  TArray<T> = record
  private
    FValue: _array<T>;
  public
    constructor Create(AValue: _array<T>); overload;

    class operator Implicit(AValue: T): TArray<T>;
    class operator Implicit(AValue: _array<T>): TArray<T>;
    class operator Implicit(AValue: _array<TValue>): TArray<T>;
    class operator Implicit(AValue: TArray<T>): _array<T>;
    class operator Implicit(AValue: TArray<T>): T;

    class operator Equal(AValue1, AValue2: TArray<T>): Boolean;
    class operator NotEqual(AValue1, AValue2: TArray<T>): Boolean;
    class operator GreaterThan(AValue1, AValue2: TArray<T>): Boolean;
    class operator LessThan(AValue1, AValue2: TArray<T>): Boolean;
    class operator GreaterThanOrEqual(AValue1, AValue2: TArray<T>): Boolean;
    class operator LessThanOrEqual(AValue1, AValue2: TArray<T>): Boolean;

    function Item(AIndex: Integer): T; overload;
    procedure Item(AIndex: Integer; ANewValue: T); overload;

    function Count: Integer;

    function Remove(Index: Integer): T;
    function Add(AValue: T): Integer;
    function valueOf(AIndex: Integer): T;
    function indexOf(AValue: T): Integer;

    procedure Size(ASize: Integer);

    procedure forEach(AProc: TForEach<T>); overload;
    procedure forEach(AProc: TForEachIndex<T>); overload;
    procedure forEach(AProc: TForEachBreak<T>); overload;
    procedure forEach(AProc: TForEachIndexBreak<T>); overload;

    function map(AFunc: TMap<T>): TArray<T>; overload;
    function map(AFunc: TMapIndex<T>): TArray<T>; overload;
    function map<R>(AFunc: TMap<T,R>): TArray<R>; overload;
    function map<R>(AFunc: TMapIndex<T,R>): TArray<R>; overload;

    function filter(AFunc: TFilterIndex<T>): TArray<T>; overload;
    function filter(AFunc: TFilter<T>): TArray<T>; overload;
  end;

function &Array(AList: _array<TValue>): _array<TValue>; overload;
function &Array(AValue: TValue; ARepeat: Integer): _array<TValue>; overload;

implementation

uses
  TypInfo,
  Math,
  SysUtils,
  StrUtils,
  UGenericUtils,
  UArrayException,
  UArrayUtils;

function &Array(AList: _array<TValue>): _array<TValue>;
begin
  Result := AList;
end;

function &Array(AValue: TValue; ARepeat: Integer): _array<TValue>;
var
  FList: TArray<TValue>;
  I: Integer;
begin
  FList := [];
  for I := 0 to ARepeat-1 do
    FList.Add(AValue);
  Result := FList;
end;

{ TArray<T> }

constructor TArray<T>.Create(AValue: _array<T>);
begin
  FValue := AValue;
end;

class operator TArray<T>.Implicit(AValue: T): TArray<T>;
begin
  Result := TArray<T>.Create([AValue]);
end;

class operator TArray<T>.Implicit(AValue: _array<T>): TArray<T>;
begin
  Result := TArray<T>.Create(AValue);
end;

class operator TArray<T>.Implicit(AValue: _array<TValue>): TArray<T>;
begin
  Result := TArray<T>.Create(TArrayUtils.TArrayCast<T>(AValue));
end;

class operator TArray<T>.Implicit(AValue: TArray<T>): T;
begin
  Result := AValue.FValue[0];
end;

class operator TArray<T>.Implicit(AValue: TArray<T>): _array<T>;
begin
  Result := AValue.FValue;
end;

class operator TArray<T>.Equal(AValue1, AValue2: TArray<T>): Boolean;
begin
  Result := AValue1 = AValue2;
end;

class operator TArray<T>.NotEqual(AValue1, AValue2: TArray<T>): Boolean;
begin
  Result := AValue1 <> AValue2;
end;

class operator TArray<T>.GreaterThan(AValue1, AValue2: TArray<T>): Boolean;
begin
  Result := AValue1.Count > AValue2.Count;
end;

class operator TArray<T>.LessThan(AValue1, AValue2: TArray<T>): Boolean;
begin
  Result := AValue1.Count < AValue2.Count;
end;

class operator TArray<T>.GreaterThanOrEqual(AValue1,
  AValue2: TArray<T>): Boolean;
begin
  Result := (AValue1 > AValue2) or (AValue1 = AValue2);
end;

class operator TArray<T>.LessThanOrEqual(AValue1, AValue2: TArray<T>): Boolean;
begin
  Result := (AValue1 < AValue2) or (AValue1 = AValue2);
end;

function TArray<T>.Count: Integer;
begin
  Result := Length(FValue);
end;

function TArray<T>.Remove(Index: Integer): T;
var
  FResult: T;
begin
//  FArrayValue := filter(
//  function(AValue: T; AIndex: Integer): T
//  begin
//    if AIndex <> Index then
//      Result := AValue
//    else
//      FResult := AValue;
//  end);
//  FValue := TValue.From<_array<T>>(FArrayValue);
//  Result := FResult;
end;

function TArray<T>.Add(AValue: T): Integer;
var
  FNewSize: Integer;
begin
//  FNewSize := FValue.GetArrayLength+1;
//  DynArraySetLength(PPointer(FValue.GetReferenceToRawData)^)
//  FValue[FNewSize-1] := AValue;
//  Result := FNewSize - 1;
end;

function TArray<T>.valueOf(AIndex: Integer): T;
var
  FResult: T;
begin
  FResult := Default(T);
  forEach(
  procedure(AValue: T; AIndex2: Integer; out ABreak: Boolean)
  begin
    if (AIndex = AIndex2) then
    begin
      FResult := AValue;
      ABreak := True;
    end;
  end);
  Result := FResult;
end;

function TArray<T>.indexOf(AValue: T): Integer;
var
  FResult: Integer;
begin
  FResult := -1;
  forEach(
  procedure(AValue2: T; AIndex2: Integer; out ABreak: Boolean)
  begin
    if TGenericUtils.equals<T>(AValue2,AValue) then
    begin
      FResult := AIndex2;
      ABreak := True;
    end;
  end);
  Result := FResult;
end;

procedure TArray<T>.Item(AIndex: Integer; ANewValue: T);
begin
  if (Count <= AIndex+1) then
    Size(Count+1);
  FValue[AIndex] := ANewValue;
end;

function TArray<T>.Item(AIndex: Integer): T;
begin
  if (Count <= AIndex+1) then
    Size(Count+1);
  Result := FValue[AIndex];
end;

procedure TArray<T>.Size(ASize: Integer);
begin
  SetLength(FValue,ASize);
  FValue[ASize-1] := Default(T);
end;

procedure TArray<T>.forEach(AProc: TForEach<T>);
begin
  TArrayUtils.forEach<T>(FValue, AProc);
end;

procedure TArray<T>.forEach(AProc: TForEachIndex<T>);
begin
  TArrayUtils.forEach<T>(FValue, AProc);
end;

procedure TArray<T>.forEach(AProc: TForEachBreak<T>);
begin
  TArrayUtils.forEach<T>(FValue, AProc);
end;

procedure TArray<T>.forEach(AProc: TForEachIndexBreak<T>);
begin
  TArrayUtils.forEach<T>(FValue, AProc);
end;

function TArray<T>.map(AFunc: TMap<T>): TArray<T>;
begin
//  Result := TArrayUtils.map<T>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.map(AFunc: TMapIndex<T>): TArray<T>;
begin
//  Result := TArrayUtils.map<T>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.map<R>(AFunc: TMapIndex<T, R>): TArray<R>;
begin
//  Result := TArrayUtils.map<T,R>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.map<R>(AFunc: TMap<T, R>): TArray<R>;
begin
//  Result := TArrayUtils.map<T,R>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.filter(AFunc: TFilter<T>): TArray<T>;
begin
//  Result := TArrayUtils.filter<T>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.filter(AFunc: TFilterIndex<T>): TArray<T>;
begin
//  Result := TArrayUtils.filter<T>(System.TArray<T>(FValue), AFunc);
end;

end.
