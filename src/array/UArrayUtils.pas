unit UArrayUtils;

interface

uses
  Rtti,
  Generics.Collections,
  UArrayReferences;

type
  TArrayUtils = class
//    class function TArrayToTList<T>(AArray: TArray<T>): TList<T>;
//    class function TArrayCast<T,R>(AArray: TArray<T>): TArray<R>; overload;
//    class function TArrayCast<R>(AArray: TArray<TValue>): TArray<R>; overload;
//    class function filter<T>(AList: TArray<T>; AFunc: TFilter<T>): TArray<T>; overload;
//    class function filter<T>(AList: TArray<T>; AFunc: TFilterIndex<T>): TArray<T>; overload;

    { Pointer }
    class procedure forEach<T>(AList: Pointer; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: Pointer; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(AList: Pointer; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: Pointer; AProc: TForEachIndexBreak<T>); overload;

    { TList }
    class procedure forEach<T>(AList: TList<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndexBreak<T>); overload;

    { List - Maybe inst going to work very well. }
    class procedure forEach<T>(out AList: TArray<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(out AList: TArray<T>; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(out AList: TArray<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(out AList: TArray<T>; AProc: TForEachIndexBreak<T>); overload;

    class function map<T>(AList: TArray<T>; AFunc: TMap<T>): TArray<T>; overload;
    class function map<T>(AList: TArray<T>; AFunc: TMapIndex<T>): TArray<T>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TMap<T,R>): TArray<R>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TMapIndex<T,R>): TArray<R>; overload;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  UArrayException,
  UGenericUtils;

{ TArrayUtils }

{ Pointer }

class procedure TArrayUtils.forEach<T>(AList: Pointer;
  AProc: TForEachIndexBreak<T>);
var
  I: Integer;
  LBreak: Boolean;
  LList: TArray<T>;
  LCurrentItem: T;
  LPTypeInfo: PTypeInfo;
  LRealList: TValue;
begin
  LList := TArray<T>(AList^); { Using into the *For }
  LPTypeInfo := TGenericUtils.rttiType<TArray<T>>.Handle;
  TValue.Make(AList,LPTypeInfo,LRealList); { Used to make the update }
  LBreak := False;
  for I := 0 to High(LList) do
  begin
    LCurrentItem := LList[I];
    AProc(LCurrentItem, I, LBreak);
    LRealList.SetArrayElement(I,TValue.From<T>(LCurrentItem));
    if LBreak then
      Break;
  end;
end;

class procedure TArrayUtils.forEach<T>(AList: Pointer; AProc: TForEachIndex<T>);
begin
  forEach<T>(AList,
  procedure(out AItem: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AItem, AIndex);
  end);
end;

class procedure TArrayUtils.forEach<T>(AList: Pointer; AProc: TForEachBreak<T>);
begin
  forEach<T>(AList,
  procedure(out AItem: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AItem, ABreak);
  end);
end;

class procedure TArrayUtils.forEach<T>(AList: Pointer; AProc: TForEach<T>);
begin
  forEach<T>(AList,
  procedure(out AItem: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AItem);
  end);
end;

{ List - TList }

class procedure TArrayUtils.forEach<T>(AList: TList<T>; AProc: TForEach<T>);
var LList: TArray<T>;
begin
  LList := AList.ToArray;
  forEach<T>(LList, AProc);
  AList.Clear;
  AList.AddRange(LList);
end;

class procedure TArrayUtils.forEach<T>(AList: TList<T>;
  AProc: TForEachIndex<T>);
var LList: TArray<T>;
begin
  LList := AList.ToArray;
  forEach<T>(LList, AProc);
  AList.Clear;
  AList.AddRange(LList);
end;

class procedure TArrayUtils.forEach<T>(AList: TList<T>;
  AProc: TForEachBreak<T>);
var LList: TArray<T>;
begin
  LList := AList.ToArray;
  forEach<T>(LList, AProc);
  AList.Clear;
  AList.AddRange(LList);
end;

class procedure TArrayUtils.forEach<T>(AList: TList<T>;
  AProc: TForEachIndexBreak<T>);
var LList: TArray<T>;
begin
  LList := AList.ToArray;
  forEach<T>(LList, AProc);
  AList.Clear;
  AList.AddRange(LList);
end;

{ List - Array }

class procedure TArrayUtils.forEach<T>(out AList: TArray<T>; AProc: TForEach<T>);
begin
  forEach<T>(@AList, AProc);
end;

class procedure TArrayUtils.forEach<T>(out AList: TArray<T>;
  AProc: TForEachBreak<T>);
begin
  forEach<T>(@AList, AProc);
end;

class procedure TArrayUtils.forEach<T>(out AList: TArray<T>;
  AProc: TForEachIndex<T>);
begin
  forEach<T>(@AList, AProc);
end;

class procedure TArrayUtils.forEach<T>(out AList: TArray<T>;
  AProc: TForEachIndexBreak<T>);
begin
  forEach<T>(@AList, AProc);
end;

{ Map }

class function TArrayUtils.map<T, R>(AList: TArray<T>;
  AFunc: TMap<T, R>): TArray<R>;
var LList: TList<R>;
begin
  LList := TList<R>.Create;
  forEach<T>(AList, procedure(out AItem: T)
  begin
    LList.Add(AFunc(AItem));
  end);
  Result := LList.ToArray;
  LList.Free;
end;

class function TArrayUtils.map<T, R>(AList: TArray<T>;
  AFunc: TMapIndex<T, R>): TArray<R>;
var LList: TList<R>;
begin
  LList := TList<R>.Create;
  forEach<T>(AList, procedure(out AItem: T; AIndex: Integer)
  begin
    LList.Add(AFunc(AItem, AIndex));
  end);
  Result := LList.ToArray;
  LList.Free;
end;

class function TArrayUtils.map<T>(AList: TArray<T>; AFunc: TMap<T>): TArray<T>;
var LList: TList<T>;
begin
  LList := TList<T>.Create;
  forEach<T>(AList, procedure(out AItem: T)
  begin
    LList.Add(AFunc(AItem));
  end);
  Result := LList.ToArray;
  LList.Free;
end;

class function TArrayUtils.map<T>(AList: TArray<T>;
  AFunc: TMapIndex<T>): TArray<T>;
var LList: TList<T>;
begin
  LList := TList<T>.Create;
  forEach<T>(AList, procedure(out AItem: T; AIndex: Integer)
  begin
    LList.Add(AFunc(AItem, AIndex));
  end);
  Result := LList.ToArray;
  LList.Free;
end;

end.
