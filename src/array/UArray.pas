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

    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    property Items[Index: Integer]: T read GetItem write SetItem; default;
    function Count: Integer;

    function Remove(Index: Integer): T;
    function Add(AValue: T): Integer;
    function valueOf(AIndex: Integer): T;
    function indexOf(AValue: T): Integer;

    procedure Size(ASize: Integer);

    procedure forEach<T>(AProc: TForEach<T>); overload;
    procedure forEach<T>(AProc: TForEachIndex<T>); overload;
    procedure forEach<T>(AProc: TForEachBreak<T>); overload;
    procedure forEach<T>(AProc: TForEachIndexBreak<T>); overload;

    function map<T>(AFunc: TMap<T>): TArray<T>; overload;
    function map<T>(AFunc: TMapIndex<T>): TArray<T>; overload;
    function map<T,R>(AFunc: TMap<T,R>): TArray<R>; overload;
    function map<T,R>(AFunc: TMapIndex<T,R>): TArray<R>; overload;

    function filter<T>(AFunc: TFilterIndex<T>): TArray<T>; overload;
    function filter<T>(AFunc: TFilter<T>): TArray<T>; overload;
  end;

function &Array(AList: _array<TValue>): _array<TValue>; overload;
function &Array(AValue: TValue; ARepeat: Integer): _array<TValue>; overload;

implementation

uses
  TypInfo,
  Math,
  UGenericUtils,
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

procedure TArray<T>.SetItem(Index: Integer; const Value: T);
begin
  if Length(FValue) < Index+1 then
    SetLength(FValue, Index+1);
  FValue[Index] := Value;
end;

function TArray<T>.GetItem(Index: Integer): T;
begin
  Result := FValue[Index];
end;

function TArray<T>.Count: Integer;
begin
  Result := Length(FValue);
end;

function TArray<T>.Remove(Index: Integer): T;
var
  FResult: T;
begin
  FValue := filter<T>(
  function(AValue: T; AIndex: Integer): T
  begin
    if AIndex <> Index then
      Result := AValue
    else
      FResult := AValue;
  end);
  Result := FResult;
end;

function TArray<T>.Add(AValue: T): Integer;
var
  FNewSize: Integer;
begin
  FNewSize := Length(FValue)+1;
  SetLength(FValue, FNewSize);
  FValue[FNewSize-1] := AValue;
  Result := FNewSize - 1;
end;

function TArray<T>.valueOf(AIndex: Integer): T;
var
  FResult: T;
begin
  FResult := Default(T);
  forEach<T>(
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
  forEach<T>(
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

procedure TArray<T>.Size(ASize: Integer);
begin
  while Count < ASize do
    Add(Default(T));
  while Count > ASize do
    Remove(Count-1);
end;

procedure TArray<T>.forEach<T>(AProc: TForEach<T>);
begin
  TArrayUtils.forEach<T>(System.TArray<T>(FValue), AProc);
end;

procedure TArray<T>.forEach<T>(AProc: TForEachIndex<T>);
begin
  TArrayUtils.forEach<T>(System.TArray<T>(FValue), AProc);
end;

procedure TArray<T>.forEach<T>(AProc: TForEachBreak<T>);
begin
  TArrayUtils.forEach<T>(System.TArray<T>(FValue), AProc);
end;

procedure TArray<T>.forEach<T>(AProc: TForEachIndexBreak<T>);
begin
  TArrayUtils.forEach<T>(System.TArray<T>(FValue), AProc);
end;

function TArray<T>.map<T>( AFunc: TMap<T>): TArray<T>;
begin
  Result := TArrayUtils.map<T>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.map<T>(AFunc: TMapIndex<T>): TArray<T>;
begin
  Result := TArrayUtils.map<T>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.map<T, R>(AFunc: TMapIndex<T, R>): TArray<R>;
begin
  Result := TArrayUtils.map<T,R>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.map<T, R>(AFunc: TMap<T, R>): TArray<R>;
begin
  Result := TArrayUtils.map<T,R>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.filter<T>(AFunc: TFilter<T>): TArray<T>;
begin
  Result := TArrayUtils.filter<T>(System.TArray<T>(FValue), AFunc);
end;

function TArray<T>.filter<T>(AFunc: TFilterIndex<T>): TArray<T>;
begin
  Result := TArrayUtils.filter<T>(System.TArray<T>(FValue), AFunc);
end;

end.

