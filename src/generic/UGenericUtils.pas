unit UGenericUtils;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections;

type
  TFunc<T> = reference to function: T;
  TFunc1P<T> = reference to function(AValue: T): T;
  TFunc1P<T,R> = reference to function(AValue: T): R;
  TFunc2P<T,R> = reference to function(AValue, AValue2: T): R;
  TFunc2P<T,T2,R> = reference to function(AValue: T; AValue2: T2): R;

  TProcObj = procedure of object;

  TGenericArray = TArray<TValue>;
  TGenericRange = 0 .. 255;

  TValue = Rtti.TValue;

  _TOneFieldObject<T> = class
    Value: T;
  end;

  TGenericValue<T> = record
  private
    FValue: T;
  public
    constructor Create(AValue: T);

    property Value: T read FValue write FValue;

    class operator Initialize(out Dest: TGenericValue<T>);
    class operator Finalize(var Dest: TGenericValue<T>);
  end;

  TGenericUtils = class
    class function castTo<R,T>(AValue: T): R; overload;
    class function castTo<R>(Avalue: Pointer): R; overload;

    class function callFunc<T>(AObject: T; AFunctionName: String): TValue; overload;
    class function callFunc<T>(AObject: T; AFunctionName: String; const Args: Array of TValue): TValue; overload;

    class function defaultFunc<T>: TFunc<T>;
    class function defaultProc: TProc;

    class function equals<T>(AValue, AValue2: T): Boolean; overload;
    class function equals<T>(AValue: T): Boolean; overload;

    class procedure freeAndNil<T>(out AValue: T);

    class function isEmptyOrNull<T>(AValue: T): Boolean; overload;
    class function isEmptyOrNull(AValue: TValue): Boolean; overload;

    class function isObject<T>: Boolean; overload;
    class function isObject<T>(AValue: T): Boolean; overload;
    class function isObject(AValue: TValue): Boolean; overload;
    class function isArrayOfObject(AValue: TValue): Boolean; overload;
    class function isArrayOfObject<T>: Boolean; overload;
    class function isArray<T>: Boolean;

    class function isSubClass<T1,T2>: Boolean; overload;
    class function isSubClass(AClass, AFromClass: TClass): Boolean; overload;

    class function newInstance<T: class>: T; overload;
    class function newInstance(AClass: TClass): TObject; overload;

    class function rttiType<T>: TRttiType; overload;
    class function rttiType(AClass: TClass): TRttiType; overload;
    class function rttiType(APointer: Pointer): TRttiType; overload;

    class function sameType<T1,T2>: Boolean; overload;
    class function sameType<T1,T2>(AValue1: T1; AValue2:T2): Boolean; overload;

    class procedure setNil<T>(out AValue: T);

    class function tclassOf<T>: TClass; overload;
    class function tclassOf(AQualifiedName: String): TClass; overload;
    class function tclassOf<T:class>(AObject: T): TClass; overload;
    class function tclassOf(APointer: Pointer): TClass; overload;

    class function typeName<T>: String; overload;
    class function typeName<T>(AValue: T): String; overload;

    class function ifThen<T>(AResult: Boolean; ATrue: T; AFalse: T): T; overload;
    class function ifThen<T>(AResult: Boolean; ATrue: TFunc<T>; AFalse: TFunc<T>): T; overload;

    class function size<T>(AValue: T): Integer;
  end;

implementation

uses
  TypInfo,
  StrUtils,
  REST.JSON,
  Generics.Defaults,
  RegularExpressions,
  UGenericException,
  UDebugUtils;

{ TGenericValue<T> }

constructor TGenericValue<T>.Create(AValue: T);
begin
  FValue := AValue;
end;

class operator TGenericValue<T>.Finalize(var Dest: TGenericValue<T>);
begin
  TGenericUtils.freeAndNil(Dest.FValue);
end;

class operator TGenericValue<T>.Initialize(out Dest: TGenericValue<T>);
begin
  Dest.FValue := Default(T);
end;

class function TGenericUtils.castTo<R,T>(AValue: T): R;
begin
  Result := R(TValue.From<T>(AValue).GetReferenceToRawData^);
end;

class function TGenericUtils.castTo<R>(Avalue: Pointer): R;
begin
  Result := R(AValue^);
end;

class function TGenericUtils.callFunc<T>(AObject: T; AFunctionName: String): TValue;
begin
  Result := callFunc<T>(AObject, AFunctionName, []);
end;

class function TGenericUtils.callFunc<T>(AObject: T; AFunctionName: String; const Args: Array of TValue): TValue;
var
  FRType: TRttiType;
  FMethod: TRttiMethod;
  FLog: String;
begin
  FLog := 'The function '+AFunctionName+' ';
  FRType := rttiType<T>;
  FMethod := FRType.GetMethod(AFunctionName);
  if Assigned(FMethod) then
  begin
    if FMethod.ReturnType <> nil then
    begin
      Result := FMethod.Invoke(TValue.From(AObject), Args);
    end
    else
      raise TGenericException.Create(FLog+'doesnt has a return!');
  end
  else
    raise TGenericException.Create(FLog+'was not being found!');
end;

class function TGenericUtils.defaultFunc<T>: TFunc<T>;
begin
  Result := function: T
  begin
    Result := Default(T)
  end;
end;

class function TGenericUtils.defaultProc: TProc;
begin
  Result := procedure
  begin
  end;
end;

class function TGenericUtils.equals<T>(AValue, AValue2: T): Boolean;
var
  FCompare: IEqualityComparer<T>;
begin
  Result := False;
  try
    FCompare := TEqualityComparer<T>.Default;
    Result := FCompare.Equals(AValue, AValue2);
  except
    raise TGenericException.Create('Fail on generic compare '+typeName<T>+'.');
  end;
end;

class function TGenericUtils.equals<T>(AValue: T): Boolean;
begin
  Result := equals<T>(AValue, Default(T));
end;

class procedure TGenericUtils.freeAndNil<T>(out AValue: T);
var
  FObject: TObject;
  FDataInfo: TDataInfo;
  FValue: TClass;
begin
  if (not isEmptyOrNull(AValue)) and isObject(AValue) then
  begin
    try
      FValue := tclassOf(castTo<TObject, T>(AValue));
      FObject := TValue.From<T>(AValue).AsObject;
      FObject.Free;
    except
      FDataInfo := TDebugUtils.getCurrentDataInfo(2);
      writeln('The value from '+typeName<T>+' has already been free from the memory!');
      writeln('File: '+FDataInfo.FileName+' Function: '+FDataInfo.CallBy);
    end;
  end;
  setNil(AValue);
  AValue := Default (T);
end;

class function TGenericUtils.isEmptyOrNull(AValue: TValue): Boolean;
begin
  try
    if (not Result) then
      Result := AValue.IsEmpty;
    if (not Result) then
      Result := AValue.TypeInfo = nil;
    if (not Result) then
      AValue.ToString;
  except
    Result := True;
  end;
end;

class function TGenericUtils.isEmptyOrNull<T>(AValue: T): Boolean;
var
  FValue: TValue;
  FClass: TClass;
begin
  Result := False;
  try
    FValue := TValue.From(AValue);
    {Empty}
    if (not Result) then
      Result := FValue.IsEmpty;
    {Null Type}
    if (not Result) then
      Result := FValue.TypeInfo = nil;

    {T, Value isn't both same thing}
    if (not Result) then
      Result := not (isObject<T> = isObject(FValue));

    {not Valid Class}
    if (not Result) then
    begin
      if FValue.IsObject then
      begin
        FClass := FValue.AsObject.ClassType;
        {Is Empty or Null}
        Result := TGenericUtils.isEmptyOrNull(FClass);
        {Not T or SubClass of T}
        if not Result then
          Result := not ((FClass = tclassOf<T>) or (FClass.InheritsFrom(tclassOf<T>)));
      end;
    end;
    {Equals Default}
    if (not Result) and (not sameType<T, Boolean>) then
      Result := equals<T>(AValue);
    {Try it to use}
    if (not Result)  then
      FValue.ToString;
  except
    setNil(AValue);
    Result := True;
  end;
end;

class function TGenericUtils.isObject(AValue: TValue): Boolean;
var
  FType: PTypeInfo;
  FTypeData: PTypeData;
begin
  FType := AValue.TypeInfo;
  Result := (FType.Kind in [tkClass, tkInterface, tkVariant]);
end;

class function TGenericUtils.isObject<T>: Boolean;
var
  FValue: TValue;
begin
  Result := isObject(TValue.From<T>(Default(T)));
end;

class function TGenericUtils.isObject<T>(AValue: T): Boolean;
begin
  Result := isObject<T>;
end;

class function TGenericUtils.isArrayOfObject(AValue: TValue): Boolean;
var
  FType: PTypeInfo;
  FTypeData: PTypeData;
begin
  Result := False;
  FType := AValue.TypeInfo;
  if (FType.Kind = tkDynArray) or (FType.Kind = tkArray) then
  begin
    FTypeData := GetTypeData(FType);
    if FTypeData.elType <> nil then
      Result := rttiType(FTypeData.elType^).TypeKind = tkClass
    else
      Result := rttiType(FTypeData.elType2^).TypeKind = tkClass;
  end
end;

class function TGenericUtils.isArrayOfObject<T>: Boolean;
begin
  isArrayOfObject(TValue.From<T>(Default(T)));
end;

class function TGenericUtils.isArray<T>: Boolean;
begin
  Result := (PTypeInfo(TypeInfo(T))^.Kind in [tkArray, tkDynArray]);
end;

class function TGenericUtils.isSubClass<T1,T2>: Boolean;
begin
  Result := tclassOf<T1>.InheritsFrom(tclassOf<T2>);
end;

class function TGenericUtils.isSubClass(AClass, AFromClass: TClass): Boolean;
begin
  Result := AClass.InheritsFrom(AFromClass);
end;

class function TGenericUtils.newInstance<T>: T;
begin
  Result := newInstance(T) as T;
end;

class function TGenericUtils.newInstance(AClass: TClass): TObject;
var
  FRTypeInfo: TRttiType;
  FRConstructorMethod: TRttiMethod;
  FArray: TArray<TValue>;
  FLog: String;
begin
  FLog := 'The type '+AClass.ClassName+' ';
  FRTypeInfo := rttiType(AClass);
  if (isEmptyOrNull(FRTypeInfo)) then
    raise TGenericException.Create(FLog+'was not being found!');
  FRConstructorMethod := FRTypeInfo.GetMethod('Create');
  if (isEmptyOrNull(FRConstructorMethod)) then
    raise TGenericException.Create(FLog+'doesnt have a constructor!');
  FArray := [];
  if (Length(FRConstructorMethod.GetParameters) > 0) then
    FArray := [nil];
  try
    Result := FRConstructorMethod.Invoke(FRTypeInfo.AsInstance.MetaclassType, FArray).AsObject;
  except
    raise TGenericException.Create('Fail to make a new instance of '+AClass.ClassName);
  end;
end;

class function TGenericUtils.rttiType<T>: TRttiType;
var
  FRContext: TRttiContext;
begin
  try
    FRContext := TRttiContext.Create;
    Result := FRContext.GetType(TypeInfo(T));
  except
    FRContext.Free;
    if (not isEmptyOrNull(Result)) then
      freeAndNil(Result);
    raise TGenericException.Create('Fail to obtain RttiType from '+typeName<T>);
  end;
end;

class function TGenericUtils.rttiType(AClass: TClass): TRttiType;
var
  FRContext: TRttiContext;
begin
  FRContext := TRttiContext.Create;
  try
    Result := FRContext.GetType(AClass);
  finally
    FRContext.Free;
  end;
end;

class function TGenericUtils.rttiType(APointer: Pointer): TRttiType;
var
  FRContext: TRttiContext;
begin
  FRContext := TRttiContext.Create;
  try
    Result := FRContext.GetType(APointer);
  finally
    FRContext.Free;
  end;
end;

class function TGenericUtils.sameType<T1,T2>: Boolean;
begin
  Result := TypeInfo(T1) = TypeInfo(T2);
end;

class function TGenericUtils.sameType<T1,T2>(AValue1: T1; AValue2:T2): Boolean;
begin
  Result := sameType<T1, T2>;
end;

class procedure TGenericUtils.setNil<T>(out AValue: T);
begin
  PPointer(@AValue)^ := nil;
end;

class function TGenericUtils.tclassOf<T>: TClass;
begin
  Result := tclassOf(TypeInfo(T));
end;

class function TGenericUtils.tclassOf(AQualifiedName: String): TClass;
var
  FRContext: TRttiContext;
  FRType: TRttiType;
begin
  Result := nil;
  FRContext := TRttiContext.Create;
  FRType := FRContext.FindType(AQualifiedName);
  if FRType.IsInstance then
    Result := FRType.AsInstance.MetaclassType;
  FRContext.Free;
end;

class function TGenericUtils.tclassOf(APointer: Pointer): TClass;
var
  FRContext: TRttiContext;
  FRType: TRttiType;
begin
  FRContext := TRttiContext.Create;
  FRType := FRContext.GetType(APointer);
  Result := FRType.AsInstance.MetaclassType;
  FRContext.Free;
end;

class function TGenericUtils.tclassOf<T>(AObject: T): TClass;
begin
  Result := TValue.From<T>(AObject).AsObject.ClassType;
end;

class function TGenericUtils.typeName<T>: String;
begin
  Result := PTypeInfo(TypeInfo(T))^.Name;
end;

class function TGenericUtils.typeName<T>(AValue: T): String;
begin
  Result := typeName<T>;
  if isObject<T> then
    Result := TValue.From(AValue).AsObject.ClassName;
end;

class function TGenericUtils.ifThen<T>(AResult: Boolean; ATrue: T; AFalse: T): T;
begin
  Result := AFalse;
  if AResult then
    Result := ATrue;
end;

class function TGenericUtils.ifThen<T>(AResult: Boolean; ATrue: TFunc<T>; AFalse: TFunc<T>): T;
begin
  Result := AFalse;
  if AResult then
    Result := ATrue;
end;

class function TGenericUtils.size<T>(AValue: T): Integer;
var
  FValue: _TOneFieldObject<T>;
begin
  FValue := _TOneFieldObject<T>.Create;
  FValue.Value := AValue;
  Result := Length(TJson.ObjectToJsonString(FValue));
  FValue.Free;
end;

end.
