unit UGenericUtils;

interface

uses
  Rtti,
  SysUtils,
  TypInfo,
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
  public
    Value: T;
    constructor Create(AValue: T);
    class operator Initialize(out Dest: TGenericValue<T>);
    class operator Finalize(var Dest: TGenericValue<T>);
  end;

  TGenericUtils = class
    class function castTo<R,T>(AValue: T): R; overload;
    class function castTo<R>(Avalue: Pointer): R; overload;

    class function callMethod<T>(AObj: T; AFunctionName: String): TValue; overload;
    class function callMethod<T>(AObj: T; AFunctionName: String; const Args: Array of TValue): TValue; overload;
    class function callMethod<T>(AObj: Pointer; AFuncName: String; const Args: Array of TValue): TValue; overload;
    class function callMethod(ARtti: TRttiType; AObj: Pointer; AFuncName: String; const Args: Array of TValue): TValue; overload;
    class function getMethod<T>(AMethod: String): TRttiMethod;

    class function defaultFunc<T>: TFunc<T>;
    class function defaultProc: TProc;

    class function equals<T>(AValue, AValue2: T): Boolean; overload;
    class function equals<T>(AValue: T): Boolean; overload;

    class procedure freeAndNil<T>(AValue: T);

    class function isEmptyOrNull<T>(AValue: T): Boolean; overload;
    class function isEmptyOrNull(AValue: TValue): Boolean; overload;

    class function isObject<T>: Boolean; overload;
    class function isObject<T>(AValue: T): Boolean; overload;
    class function isObject(AValue: TValue): Boolean; overload;
    class function isArrayOfObject(AValue: TValue): Boolean; overload;
    class function isArrayOfObject<T>: Boolean; overload;
    class function isArray<T>: Boolean; overload;
    class function isArray(ATValue: TValue): Boolean; overload;
    class function isArray(APTypeInfo: PTypeInfo): Boolean; overload;

    class function isSubClass<T1,T2>: Boolean; overload;
    class function isSubClass(AClass, AFromClass: TClass): Boolean; overload;

    class function newInstance<T: class>: T; overload;
    class function newInstance(AClass: TClass): TObject; overload;

    class function rttiType<T>: TRttiType; overload;
    class function rttiType<T>(out ARttiContext: TRttiContext): TRttiType; overload;
    class function rttiType(ATypeName: String): TRttiType; overload;
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


    class function getFieldValue<T>(AObj: T; AField: String): TValue; overload;
    class function getFieldValue<T, V>(AObj: T; AField: String): V; overload;
    class procedure setFieldValue<T, V>(AObj: Pointer; AField: String; AValue: V); static;
  end;

implementation

uses
  StrUtils,
  REST.JSON,
  Generics.Defaults,
  RegularExpressions,
  UGenericException,
  UDebugUtils;

{ TGenericValue<T> }

constructor TGenericValue<T>.Create(AValue: T);
begin
  Value := AValue;
end;

class operator TGenericValue<T>.Finalize(var Dest: TGenericValue<T>);
begin
  TGenericUtils.freeAndNil<T>(Dest.Value);
end;

class operator TGenericValue<T>.Initialize(out Dest: TGenericValue<T>);
begin
  Dest.Value := Default(T);
end;

class function TGenericUtils.castTo<R,T>(AValue: T): R;
begin
  Result := R(TValue.From<T>(AValue).GetReferenceToRawData^);
end;

class function TGenericUtils.castTo<R>(Avalue: Pointer): R;
begin
  Result := R(AValue^);
end;

class function TGenericUtils.callMethod(ARtti: TRttiType; AObj: Pointer;
  AFuncName: String; const Args: array of TValue): TValue;
var
  LRMethod: TRttiMethod;
  LBaseLog, LLog: String;
  LObj: TValue;
begin
  LBaseLog := 'The function '+AFuncName+' ';
  TValue.Make(AObj,ARtti.Handle,LObj);
  LRMethod := ARtti.GetMethod(AFuncName);
  if Assigned(LRMethod) then
    Result := LRMethod.Invoke(LObj, Args)
  else
    LLog := LBaseLog+'was not being found!';
  if LLog <> '' then
    raise TGenericException.Create(LLog);
end;

class function TGenericUtils.callMethod<T>(AObj: Pointer;
  AFuncName: String; const Args: array of TValue): TValue;
var
  LRContext: TRttiContext;
begin
  Result := callMethod(rttiType<T>(LRContext),AObj,AFuncName,Args);
  LRContext.Free;
end;

class function TGenericUtils.callMethod<T>(AObj: T; AFunctionName: String): TValue;
begin
  Result := callMethod<T>(@AObj, AFunctionName, []);
end;

class function TGenericUtils.callMethod<T>(AObj: T; AFunctionName: String; const Args: Array of TValue): TValue;
begin
  Result := callMethod<T>(@AObj, AFunctionName, Args);
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
  LCompare: IEqualityComparer<T>;
begin
  Result := False;
  try
    LCompare := TEqualityComparer<T>.Default;
    Result := LCompare.Equals(AValue, AValue2);
  except
    raise TGenericException.Create('Fail on generic compare '+typeName<T>+'.');
  end;
end;

class function TGenericUtils.equals<T>(AValue: T): Boolean;
begin
  Result := equals<T>(AValue, Default(T));
end;

class procedure TGenericUtils.freeAndNil<T>(AValue: T);
var
  LObject: TObject;
  LDataInfo: TDataInfo;
  LValue: TClass;
begin
  if (not isEmptyOrNull(AValue)) and isObject(AValue) then
  begin
    try
      LValue := tclassOf(castTo<TObject, T>(AValue));
      LObject := TValue.From<T>(AValue).AsObject;
      LObject.Free;
    except
      LDataInfo := TDebugUtils.getCurrentDataInfo(2);
      writeln('The value from '+typeName<T>+' has already been free from the memory!');
      writeln('File: '+LDataInfo.FileName+' Function: '+LDataInfo.CallBy);
    end;
  end;
  setNil(AValue);
  AValue := Default (T);
end;

class function TGenericUtils.getFieldValue<T, V>(AObj: T; AField: String): V;
begin
  Result := getFieldValue<T>(AObj, AField).AsType<V>;
end;

class function TGenericUtils.getFieldValue<T>(AObj: T; AField: String): TValue;
var
  LRttiContext: TRttiContext;
  LRtti: TRttiType;
begin
  LRtti := rttiType<T>(LRttiContext);
  if (not isEmptyOrNull(LRtti.GetField(AField))) then
  begin
    Result := LRtti.GetField(AField).GetValue(@AObj);
  end;
  LRttiContext.Free;
end;

class function TGenericUtils.getMethod<T>(AMethod: String): TRttiMethod;
var
  LRttiContext: TRttiContext;
  LRtti: TRttiType;
begin
  LRtti := rttiType<T>(LRttiContext);
  Result := LRtti.GetMethod(AMethod);
  LRttiContext.Free;
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
  LValue: TValue;
  LClass: TClass;
begin
  Result := False;
  try
    LValue := TValue.From(AValue);
    {Empty}
    if (not Result) then
      Result := LValue.IsEmpty;
    {Null Type}
    if (not Result) then
      Result := LValue.TypeInfo = nil;

    {T, Value isn't both same thing}
    if (not Result) then
      Result := not (isObject<T> = isObject(LValue));

    {not Valid Class}
    if (not Result) then
    begin
      if LValue.IsObject then
      begin
        LClass := LValue.AsObject.ClassType;
        {Is Empty or Null}
        Result := TGenericUtils.isEmptyOrNull(LClass);
        {Not T or SubClass of T}
        if not Result then
          Result := not ((LClass = tclassOf<T>) or (LClass.InheritsFrom(tclassOf<T>)));
      end;
    end;
    {Equals Default}
    if (not Result) and (not sameType<T, Boolean>) then
      Result := equals<T>(AValue);
    {Try it to use}
    if (not Result)  then
      LValue.ToString;
  except
    setNil(AValue);
    Result := True;
  end;
end;

class function TGenericUtils.isObject(AValue: TValue): Boolean;
var
  LType: PTypeInfo;
  LTypeData: PTypeData;
begin
  LType := AValue.TypeInfo;
  Result := (LType.Kind in [tkClass, tkInterface, tkVariant]);
end;

class function TGenericUtils.isObject<T>: Boolean;
begin
  Result := isObject(TValue.From<T>(Default(T)));
end;

class function TGenericUtils.isObject<T>(AValue: T): Boolean;
begin
  Result := isObject<T>;
end;

class function TGenericUtils.isArrayOfObject(AValue: TValue): Boolean;
var
  LType: PTypeInfo;
  LTypeData: PTypeData;
begin
  Result := False;
  LType := AValue.TypeInfo;
  if (LType.Kind = tkDynArray) or (LType.Kind = tkArray) then
  begin
    LTypeData := GetTypeData(LType);
    if LTypeData.elType <> nil then
      Result := rttiType(LTypeData.elType^).TypeKind = tkClass
    else
      Result := rttiType(LTypeData.elType2^).TypeKind = tkClass;
  end
end;

class function TGenericUtils.isArrayOfObject<T>: Boolean;
begin
  isArrayOfObject(TValue.From<T>(Default(T)));
end;

class function TGenericUtils.isArray(ATValue: TValue): Boolean;
begin
  Result := (ATValue.TypeInfo^).Kind in [tkArray, tkDynArray];
end;

class function TGenericUtils.isArray(APTypeInfo: PTypeInfo): Boolean;
begin
  Result := APTypeInfo.Kind in [tkArray, tkDynArray];
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
  LRTypeInfo: TRttiType;
  LRConstructorMethod: TRttiMethod;
  LArray: TArray<TValue>;
  LLog: String;
begin
  LLog := 'The type '+AClass.ClassName+' ';
  LRTypeInfo := rttiType(AClass);
  if (isEmptyOrNull(LRTypeInfo)) then
    raise TGenericException.Create(LLog+'was not being found!');
  LRConstructorMethod := LRTypeInfo.GetMethod('Create');
  if (isEmptyOrNull(LRConstructorMethod)) then
    raise TGenericException.Create(LLog+'doesnt have a constructor!');
  LArray := [];
  if (Length(LRConstructorMethod.GetParameters) > 0) then
    LArray := [nil];
  try
    Result := LRConstructorMethod.Invoke(LRTypeInfo.AsInstance.MetaclassType, LArray).AsObject;
  except
    raise TGenericException.Create('Fail to make a new instance of '+AClass.ClassName);
  end;
end;

class function TGenericUtils.rttiType<T>: TRttiType;
var
  LRContext: TRttiContext;
begin
  try
    LRContext := TRttiContext.Create;
    Result := LRContext.GetType(TypeInfo(T));
  except
    LRContext.Free;
    if (not isEmptyOrNull(Result)) then
      freeAndNil(LRContext);
    raise TGenericException.Create('Fail to obtain RttiType from '+typeName<T>);
  end;
end;

class function TGenericUtils.rttiType(AClass: TClass): TRttiType;
var
  LRContext: TRttiContext;
begin
  LRContext := TRttiContext.Create;
  try
    Result := LRContext.GetType(AClass);
  finally
    LRContext.Free;
  end;
end;

class function TGenericUtils.rttiType(APointer: Pointer): TRttiType;
var
  LRContext: TRttiContext;
begin
  LRContext := TRttiContext.Create;
  try
    Result := LRContext.GetType(APointer);
  finally
    LRContext.Free;
  end;
end;

class function TGenericUtils.rttiType(ATypeName: String): TRttiType;
var
  LRContext: TRttiContext;
  LType: PTypeInfo;
begin
  LRContext := TRttiContext.Create;
  try
    Result := LRContext.FindType(ATypeName);
    if Result <> nil then
      raise TGenericException.Create('Type "' + ATypeName + '" not found.');
  finally
    LRContext.Free;
  end;
end;

class function TGenericUtils.rttiType<T>(
  out ARttiContext: TRttiContext): TRttiType;
begin
  ARttiContext := TRttiContext.Create;
  try
    Result := ARttiContext.GetType(TypeInfo(T));
  except
    if (not isEmptyOrNull(Result)) then
      freeAndNil(ARttiContext);
    raise TGenericException.Create('Fail to obtain RttiType from '+typeName<T>);
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

class procedure TGenericUtils.setFieldValue<T, V>(AObj: Pointer; AField: String; AValue: V);
var
  LRttiContext: TRttiContext;
  LRtti: TRttiType;
  LT:T;
begin
  LRtti := rttiType<T>(LRttiContext);
  if (not isEmptyOrNull(LRtti.GetField(AField))) then
  begin
    LRtti.GetField(AField).SetValue(AObj, TValue.From<V>(AValue));
  end;
  LRttiContext.Free;
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
  LRContext: TRttiContext;
  LRType: TRttiType;
begin
  Result := nil;
  LRContext := TRttiContext.Create;
  LRType := LRContext.FindType(AQualifiedName);
  if LRType.IsInstance then
    Result := LRType.AsInstance.MetaclassType;
  LRContext.Free;
end;

class function TGenericUtils.tclassOf(APointer: Pointer): TClass;
var
  LRContext: TRttiContext;
  LRType: TRttiType;
begin
  LRContext := TRttiContext.Create;
  LRType := LRContext.GetType(APointer);
  Result := LRType.AsInstance.MetaclassType;
  LRContext.Free;
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
  LValue: _TOneFieldObject<T>;
begin
  LValue := _TOneFieldObject<T>.Create;
  LValue.Value := AValue;
  Result := Length(TJson.ObjectToJsonString(LValue));
  LValue.Free;
end;

end.
