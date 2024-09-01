unit UArrayUtils;

interface

uses
  Rtti,
  Generics.Collections,
  UArrayReferences;

type
  TArrayUtils = class
    class function TArrayToTList<T>(AArray: TArray<T>): TList<T>;
    class function TArrayCast<T,R>(AArray: TArray<T>): TArray<R>; overload;
    class function TArrayCast<R>(AArray: TArray<TValue>): TArray<R>; overload;

    class procedure forEach<T>(AList: TList<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndexBreak<T>); overload;

    class procedure forEach<T>(AList: TArray<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachIndexBreak<T>); overload;

    class function map<T>(AList: TArray<T>; AFunc: TMap<T>): TArray<T>; overload;
    class function map<T>(AList: TArray<T>; AFunc: TMapIndex<T>): TArray<T>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TMap<T,R>): TArray<R>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TMapIndex<T,R>): TArray<R>; overload;

    class function filter<T>(AList: TArray<T>; AFunc: TFilter<T>): TArray<T>; overload;
    class function filter<T>(AList: TArray<T>; AFunc: TFilterIndex<T>): TArray<T>; overload;
  end;

implementation

uses
  UArrayException,
  UGenericUtils;

{ TArrayUtils }

class function TArrayUtils.TArrayCast<R>(AArray: TArray<TValue>): TArray<R>;
begin
  try
    Result := map<TValue, R>(AArray,
    function(AValue: TValue): R
    begin
      Result := AValue.AsType<R>;
    end);
  except
    raise TArrayException.Create('Impossible cast.');
  end;
end;

class function TArrayUtils.TArrayCast<T, R>(AArray: TArray<T>): TArray<R>;
begin
  try
    Result := map<T, R>(AArray,
    function(AValue: T): R
    begin
      Result := TValue.From<T>(AValue).AsType<R>;
    end);
  except
    raise TArrayException.Create('Impossible cast.');
  end;
end;

class function TArrayUtils.TArrayToTList<T>(AArray: TArray<T>): TList<T>;
var
  I: Integer;
begin
  Result := TList<T>.Create;
  for I := 0 to High(AArray) do
    Result.Add(AArray[I]);
end;

class procedure TArrayUtils.forEach<T>(AList: TList<T>; AProc: TForEach<T>);
begin
  if (not TGenericUtils.isEmptyOrNull(AList)) then
    ForEach<T>(AList.ToArray, AProc);
end;

class procedure TArrayUtils.forEach<T>(AList: TList<T>;
  AProc: TForEachIndex<T>);
begin
  if (not TGenericUtils.isEmptyOrNull(AList)) then
    ForEach<T>(AList.ToArray, AProc);
end;

class procedure TArrayUtils.forEach<T>(AList: TList<T>;
  AProc: TForEachBreak<T>);
begin
  if (not TGenericUtils.isEmptyOrNull(AList)) then
    ForEach<T>(AList.ToArray, AProc);
end;

class procedure TArrayUtils.forEach<T>(AList: TList<T>;
  AProc: TForEachIndexBreak<T>);
begin
  if (not TGenericUtils.isEmptyOrNull(AList)) then
    ForEach<T>(AList.ToArray, AProc);
end;

class procedure TArrayUtils.forEach<T>(AList: TArray<T>; AProc: TForEach<T>);
begin
  forEach<T>(AList,
  procedure(AValue: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AValue);
  end);
end;

class procedure TArrayUtils.forEach<T>(AList: TArray<T>;
  AProc: TForEachIndex<T>);
begin
  forEach<T>(AList,
  procedure(AValue: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AValue, AIndex);
  end);
end;

class procedure TArrayUtils.forEach<T>(AList: TArray<T>;
  AProc: TForEachBreak<T>);
begin
  forEach<T>(AList,
  procedure(AValue: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AValue, ABreak);
  end);
end;

class procedure TArrayUtils.forEach<T>(AList: TArray<T>;
  AProc: TForEachIndexBreak<T>);
var
  I: Integer;
  FBreak: Boolean;
begin
  FBreak := False;
  if (not TGenericUtils.isEmptyOrNull(AList)) and (Length(AList) > 0) then
  begin
    for I := 0 to High(AList) do
    begin
      AProc(AList[I], I, FBreak);
      if FBreak then
        Break;
    end;
  end;
end;

class function TArrayUtils.map<T>(AList: TArray<T>; AFunc: TMap<T>): TArray<T>;
begin
  Result := map<T>(AList,
  function(AValue: T; AIndex: Integer): T
  begin
    Result := AFunc(AValue);
  end)
end;

class function TArrayUtils.map<T>(AList: TArray<T>;
  AFunc: TMapIndex<T>): TArray<T>;
begin
  Result := map<T,T>(AList,
  function(AValue: T; AIndex: Integer): T
  begin
    Result := AFunc(AValue, AIndex);
  end)
end;

class function TArrayUtils.map<T, R>(AList: TArray<T>;
  AFunc: TMapIndex<T, R>): TArray<R>;
var
  FResult: TArray<R>;
begin
  SetLength(FResult, Length(AList));
  forEach<T>(AList,
  procedure(AValue: T; AIndex: Integer)
  begin
    FResult[AIndex] := AFunc(AValue, AIndex);
  end);
  Result := FResult;
end;

class function TArrayUtils.map<T, R>(AList: TArray<T>;
  AFunc: TMap<T, R>): TArray<R>;
begin
  Result := map<T, R>(AList,
  function(AValue: T; AIndex: Integer): R
  begin
    Result := AFunc(AValue);
  end)
end;

class function TArrayUtils.filter<T>(AList: TArray<T>;
  AFunc: TFilter<T>): TArray<T>;
begin
  Result := filter<T>(AList,
  function(AValue: T; AIndex: Integer): T
  begin
    Result := AFunc(AValue);
  end);
end;

class function TArrayUtils.filter<T>(AList: TArray<T>;
  AFunc: TFilterIndex<T>): TArray<T>;
var
  FResult: TArray<T>;
begin
  FResult := [];
  forEach<T>(AList,
  procedure(AValue: T; AIndex: Integer)
  var
    FFuncResult: T;
  begin
    FFuncResult := AFunc(AValue, AIndex);
    if TGenericUtils.isEmptyOrNull<T>(FFuncResult) then
    begin
      SetLength(FResult, Length(FResult)+1);
      FResult[Length(FResult)-1] := AValue;
    end;
  end);
end;

end.
