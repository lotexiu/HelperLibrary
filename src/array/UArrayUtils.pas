unit UArrayUtils;

interface

uses
  Rtti,
  Generics.Collections,
  UArrayReferences,
  UDirection;

type
  _TArrValue<T> = record
    Index: Integer;
    Value: T;
    IntValue: Integer;
    FinalPos: Integer;
  end;

  TArrayUtils = class
//    class function TArrayToTList<T>(AArray: TArray<T>): TList<T>;
//    class function TArrayCast<T,R>(AArray: TArray<T>): TArray<R>; overload;
//    class function TArrayCast<R>(AArray: TArray<TValue>): TArray<R>; overload;

    { Pointer }
    class procedure forEach<T>(AList: Pointer; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: Pointer; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(AList: Pointer; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: Pointer; AProc: TForEachIndexBreak<T>); overload;

    { List - Maybe inst going to work very well without "out". }

    class procedure forEach<T>(AList: TArray<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachIndexBreak<T>); overload;

    class function map<T>(AList: TArray<T>; AFunc: TMap<T>): TArray<T>; overload;
    class function map<T>(AList: TArray<T>; AFunc: TMapIndex<T>): TArray<T>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TMap<T,R>): TArray<R>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TMapIndex<T,R>): TArray<R>; overload;

    class function sort<T>(AList: TArray<T>; AFunc:TSort<T>): TArray<T>;

    class function filter<T>(AList: TArray<T>; AFunc:TFilter<T>): TArray<T>; overload;
    class function filter<T>(AList: TArray<T>; AFunc:TFilterIndex<T>): TArray<T>; overload;

    class function reduce<T>(AList: TArray<T>; AFunc:TReduce<T>): TArray<T>;

    class function add<T>(var AList: TArray<T>; ANewValue: T): TArray<T>; overload;
    class function remove<T>(var AList: TArray<T>; AValue:T): Boolean;

    class function pop<T>(var AList: TArray<T>; AValue:T): Boolean;
    class function shift<T>(var AList: TArray<T>; AValue:T): Boolean;
    class function unshift<T>(var AList: TArray<T>; AValue:T): Boolean;

    class function concat<T>(var AList: TArray<T>; ANewValues:TArray<T>): TArray<T>; overload;

    class function find<T>(AList: TArray<T>; AFunc: TFind<T>): T;

    class function includes<T>(AList: TArray<T>; AValue:T): Boolean;

    class function indexOf<T>(AList: TArray<T>; AValue:T): Integer;

    class function copy<T>(AList: TArray<T>; AStart, AEnd: Integer): Boolean;
    class function deepCopy<T>(AList: TArray<T>; AStart, AEnd: Integer): Boolean;

    { TList }
    class procedure forEach<T>(AList: TList<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachBreak<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndexBreak<T>); overload;
  end;

implementation

uses
  Math,
  SysUtils,
  TypInfo,
  UArrayException,
  UGenericUtils,
//  UAutoDestroy,
  UArrayImports;

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
  procedure(var AItem: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AItem, AIndex);
  end);
end;

class procedure TArrayUtils.forEach<T>(AList: Pointer; AProc: TForEachBreak<T>);
begin
  forEach<T>(AList,
  procedure(var AItem: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AItem, ABreak);
  end);
end;

class procedure TArrayUtils.forEach<T>(AList: Pointer; AProc: TForEach<T>);
begin
  forEach<T>(AList,
  procedure(var AItem: T; AIndex: Integer; out ABreak: Boolean)
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

class procedure TArrayUtils.forEach<T>(AList: TArray<T>; AProc: TForEach<T>);
begin
  forEach<T>(@AList, AProc);
end;

class procedure TArrayUtils.forEach<T>(AList: TArray<T>;
  AProc: TForEachBreak<T>);
begin
  forEach<T>(@AList, AProc);
end;

class procedure TArrayUtils.forEach<T>(AList: TArray<T>;
  AProc: TForEachIndex<T>);
begin
  forEach<T>(@AList, AProc);
end;

class procedure TArrayUtils.forEach<T>(AList: TArray<T>;
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
  forEach<T>(AList, procedure(var AItem: T)
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
  forEach<T>(AList, procedure(var AItem: T; AIndex: Integer)
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
  forEach<T>(AList, procedure(var AItem: T)
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
  forEach<T>(AList, procedure(var AItem: T; AIndex: Integer)
  begin
    LList.Add(AFunc(AItem, AIndex));
  end);
  Result := LList.ToArray;
  LList.Free;
end;

class function TArrayUtils.sort<T>(AList: TArray<T>; AFunc: TSort<T>): TArray<T>;
//var
//  LNumberList: TArray<Integer>;
//  LNewListR: TArray<RAD<T>>;
//  LNewList: TArray<T>;
//  LSize, LLow, LHigh: RAD<Integer>;
begin
//  LLow := null;
//  LHigh := null;
//  LSize := Length(AList);
//  SetLength(LNumberList, LSize);
//  SetLength(LNewList, LSize);
//
//  forEach<T>(AList,procedure(var AItem: T; AIndex: Integer)
//  var LValue: Integer;
//  begin
//    LValue := AFunc(AItem); {Value converted into Integer}
//    LNumberList[AIndex] := LValue; {Adding Integer Value into NumberList}
//    LLow  := TGenU.ifThen<Integer>((LLow = null ) or (LLow > LValue ), LValue, LLow);
//    LHigh := TGenU.ifThen<Integer>((LHigh = null) or (LHigh < LValue), LValue, LHigh);
//  end);
//
//  forEach<Integer>(LNumberList,procedure(var AValue: Integer; AIndex: Integer)
//  var LPos: Integer;
//  begin
////    LPos := Ceil(((AValue-LLow)*(LSize-1))/(LHigh-LLow));
////    while LNewList[LPos] <> null do
////      Dec(LPos);
//    LNewList[LPos] := AList[AIndex];
//  end);
end;

class function TArrayUtils.filter<T>(AList: TArray<T>; AFunc:TFilter<T>): TArray<T>;
begin

end;

class function TArrayUtils.filter<T>(AList: TArray<T>; AFunc:TFilterIndex<T>): TArray<T>;
begin

end;

class function TArrayUtils.reduce<T>(AList: TArray<T>; AFunc:TReduce<T>): TArray<T>;
begin

end;

class function TArrayUtils.add<T>(var AList: TArray<T>; ANewValue: T): TArray<T>;
begin

end;

class function TArrayUtils.remove<T>(var AList: TArray<T>; AValue:T): Boolean;
begin

end;

class function TArrayUtils.pop<T>(var AList: TArray<T>; AValue:T): Boolean;
begin

end;

class function TArrayUtils.shift<T>(var AList: TArray<T>; AValue:T): Boolean;
begin

end;

class function TArrayUtils.unshift<T>(var AList: TArray<T>; AValue:T): Boolean;
begin

end;

class function TArrayUtils.concat<T>(var AList: TArray<T>; ANewValues:TArray<T>): TArray<T>;
begin

end;

class function TArrayUtils.find<T>(AList: TArray<T>; AFunc: TFind<T>): T;
begin

end;

class function TArrayUtils.includes<T>(AList: TArray<T>; AValue:T): Boolean;
begin

end;

class function TArrayUtils.indexOf<T>(AList: TArray<T>; AValue:T): Integer;
begin

end;

class function TArrayUtils.copy<T>(AList: TArray<T>; AStart, AEnd: Integer): Boolean;
begin

end;

class function TArrayUtils.deepCopy<T>(AList: TArray<T>; AStart, AEnd: Integer): Boolean;
begin

end;


end.

