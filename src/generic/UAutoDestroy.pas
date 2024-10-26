unit UAutoDestroy;

interface

uses
  Rtti;

type
  {
    This Enum will be used as "Variable states" and will actually simulate
    the "null" for any type recived on the RAD.
    Normally the Primitive types do not have a null beacuse the null of the
    primitives types its your default value. (Ex: 0 = nil, '' = nil)
    You can literally test this by performing validations and with a pointer.
    The enum will only guarantee whether the value is null/filled/empty or not.
  }
  EValueState = (
    null,   {You can use normally}
    empty,  {Shouldn't be used}
    filled {Shouldn't be used}
  );

  {Just an interface}
  IAncestor = interface
  end;

  {IAutoDestroy}
  {
    With an interface, its possible to make an Auto Destroy into an object.
  }
  IAD<T> = interface(IAncestor)
    ['{83E191C5-7136-4CEB-8A9B-6C4508A2CCCB}']
    function getState: EValueState;
    function getValue: T;
    procedure setValue(const AValue: T); overload;
    procedure setValue(const AValue: EValueState); overload;
  end;

  {
    The object that extends the interface and will recive our data.
  }
  TAutoDestroy<T> = class(TInterfacedObject, IAD<T>)
  private
    FTValue: T;
    FEValue: EValueState;
    FPValue: Pointer;
    function getValue: T;
    function getState: EValueState;
    procedure setValue(const Value: T); overload;
    procedure setValue(const AValue: EValueState); overload;
  public
    constructor Create(AValue: T); overload;
    constructor Create(AValue: EValueState); overload;
    destructor Destroy; override;
    property I: T read getValue write setValue;
  end;

  {RecordAutoDestroy}
  {
    With this record, it will be possible to work with the variable very
    easily and it will prevent/avoid the "Memory Leak". This record will link
    the data with the threads that have it.
  }
  { - TODO -
    Link the data with the threads and make a register of all data.
    Look for some way to prevent problems with a shared Data on threads.
  }
  RAD<T> = record
  private
    FValue: IAD<T>;
    FRtti: TRttiType;
    FContext: IAD<TRttiContext>;
    function getRtti: TRttiType;
  public
    class operator Implicit(AValue: IAD<Variant>): RAD<T>;
    class operator Implicit(AValue: EValueState): RAD<T>;
    class operator Implicit(AValue: T): RAD<T>;
    class operator Implicit(AValue: RAD<T>): IAD<Variant>;
    class operator Implicit(AValue: RAD<T>): T;

    {Assign}
    class operator Assign(var Dest: RAD<T>; const [ref] Src: RAD<T>);
    {Assign}

    {Operations}
    class operator Add(a: RAD<T>; b: RAD<T>): Double;
    class operator Subtract(a: RAD<T>; b: RAD<T>) : Double;
    class operator Multiply(a: RAD<T>; b: RAD<T>) : Double;
    class operator Divide(a: RAD<T>; b: RAD<T>) : Double;
    {Operations}

    {Compare}
    class operator Equal(AAValue, ABValue: RAD<T>): Boolean;
    class operator NotEqual(AAValue, ABValue: RAD<T>): Boolean;
    class operator GreaterThan(AAValue, ABValue: RAD<T>): Boolean;
    class operator LessThan(AAValue, ABValue: RAD<T>): Boolean;
    class operator GreaterThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;
    class operator LessThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;
    {Compare}

    property RttiType: TRttiType read getRtti;
    function  I: T; overload;
    procedure I(AValue: T); overload;
    procedure I(AValue: EValueState); overload;

    procedure setValue<T2>(AProperty: String; AValue: T2);
    function  getValue<T2>(AProperty: String): T2;
  end;

function AD(AValue:Variant): IAD<Variant>;

implementation

uses
  SysUtils,
  Generics.Defaults,
  UEasyImport,
  UTOperation,
  UEnum;

{ TAutoDestroy<T> }

function AD(AValue:Variant): IAD<Variant>;
begin
  Result := TAutoDestroy<Variant>.Create(AValue);
end;

constructor TAutoDestroy<T>.Create(AValue: T);
begin
  setValue(AValue);
end;

constructor TAutoDestroy<T>.Create(AValue: EValueState);
begin
  setValue(AValue);
end;

destructor TAutoDestroy<T>.Destroy;
begin
  TGenU.freeAndNil<T>(T(FPValue^));
  inherited;
end;

function TAutoDestroy<T>.getState: EValueState;
begin
  Result := FEValue;
end;

function TAutoDestroy<T>.getValue: T;
begin
  Result := T(FPValue^);
end;

procedure TAutoDestroy<T>.setValue(const AValue: EValueState);
begin
  FTValue := Default(T);
  FEValue := AValue;
  FPValue := @FTValue;
end;

procedure TAutoDestroy<T>.setValue(const Value: T);
var LDefault: Boolean;
begin
  LDefault := TGenU.isEmptyOrNull<T>(Value);
  if LDefault then
  begin
    FTValue := Default(T);
    if TGenU.isObject<T> then
      FEValue := null
    else
      FEValue := empty
  end
  else
  begin
    FTValue := Value;
    FEValue := filled;
  end;
  FPValue := @FTValue;
end;
{ TAutoDestroy<T> }
{
  //////
  //////
  //////
  //////
  //////
}
{ RAD<T> }
function RAD<T>.getRtti: TRttiType;
var
  LContext: TRttiContext;
  LIsObject: Boolean;
  LType, LType2: String;
  LObj: TObject;
begin
  LIsObject := TGenU.isObject<T>;

  if LIsObject then
  begin
    if (FRtti = nil) then
    begin
      if FValue.getState = null then
        FRtti := TGenU.rttiType<T>(LContext)
      else
      begin
        LObj := TObject((@FValue.getValue)^);
        FRtti := TGenU.rttiType(LObj.ClassType, LContext);
      end;
      FContext := TAutoDestroy<TRttiContext>.Create(LContext);
    end
    else
    begin
      LType := FRtti.AsInstance.MetaclassType.ClassName;
      if FValue.getState = null then
        LType2 := TGenU.tclassOf<T>.ClassName
      else
      begin
        LObj := TObject((@FValue.getValue)^);
        LType2 := LObj.ClassName;
      end;
      if LType <> LType2 then
      begin
        FRtti := nil;
        FRtti := getRtti;
      end;
    end;
  end
  else if (FRtti = nil) then
  begin
    FRtti := TGenU.rttiType<T>(LContext);
    FContext := TAutoDestroy<TRttiContext>.Create(LContext);
  end;
  Result := FRtti;
end;

function RAD<T>.getValue<T2>(AProperty: String): T2;
var
  LValue: Pointer;
begin
  LValue := TGenU.castTo<Pointer, T>(FValue.getValue);
  if (FValue.getState <> null) then
    Result := RttiType.GetProperty(AProperty)
      .GetValue(LValue).AsType<T2>;
end;

procedure RAD<T>.setValue<T2>(AProperty: String; AValue: T2);
var
  LNewValue: TValue;
  LValue: Pointer;
begin
  LNewValue := TValue.From<T2>(AValue);
  LValue := TGenU.castTo<Pointer, T>(FValue.getValue);
  RttiType.GetProperty(AProperty).SetValue(LValue, LNewValue);
end;

  { Implicit }
    { EValueState -> RAD<T> }
class operator RAD<T>.Implicit(AValue: EValueState): RAD<T>;
var LEnum: TEnum<EValueState>;
begin
  LEnum := AValue;
  case AValue of
    filled, empty: raise Exception.Create(
      LEnum.toString+' shouldn''t be used here. you can just use "null".'
    );
  end;
  Result.FValue := TAutoDestroy<T>.Create(AValue);
end;
    { IAD<Variant> -> RAD<T> }
class operator RAD<T>.Implicit(AValue: IAD<Variant>): RAD<T>;
begin
  Result.FValue := AValue as IAD<T>;
end;
    { T -> RAD<T> }
class operator RAD<T>.Implicit(AValue: T): RAD<T>;
begin
  Result.FValue := TAutoDestroy<T>.Create(AValue);
end;
    { RAD<T> -> IAD<Variant> }
class operator RAD<T>.Implicit(AValue: RAD<T>): IAD<Variant>;
begin
  Result := AValue.FValue as IAD<Variant>;
end;
    { RAD<T> -> RAD<T> }
class operator RAD<T>.Implicit(AValue: RAD<T>): T;
begin
  Result := AValue.FValue.getValue;
end;
  { Implicit }

  { I }
function RAD<T>.I: T;
begin
  Result := FValue.getValue;
end;
procedure RAD<T>.I(AValue: T);
begin
  if (FValue = nil) then
    FValue := TAutoDestroy<T>.Create(AValue)
  else
    FValue.setValue(AValue);
end;
procedure RAD<T>.I(AValue: EValueState);
begin
  if (FValue = nil) then
    FValue := TAutoDestroy<T>.Create(AValue)
  else
    FValue.setValue(AValue);
end;
  { I }

  { Assign }
  class operator RAD<T>.Assign(var Dest: RAD<T>; const [ref] Src: RAD<T>);
begin
  if Src.FValue.getState = null then
    Dest.I(null)
  else
    Dest.I(Src.I);
end;
  { Assign }

  { Operations }
class operator RAD<T>.Add(a, b: RAD<T>): Double;
begin
  Result := TOperations.get<T>('Default').Add(A,B);
end;
class operator RAD<T>.Subtract(a, b: RAD<T>): Double;
begin
  Result := TOperations.get<T>('Default').Subtract(A,B);
end;
class operator RAD<T>.Multiply(a, b: RAD<T>): Double;
begin
  Result := TOperations.get<T>('Default').Multiply(A,B);
end;
class operator RAD<T>.Divide(a, b: RAD<T>): Double;
begin
  Result := TOperations.get<T>('Default').Divide(A,B);
end;
  { Operations}

  { Compare }
    { Equal }
class operator RAD<T>.Equal(AAValue, ABValue: RAD<T>): Boolean;
var LANil,LANil2: EValueState;
begin
  LANil := AAValue.FValue.getState;
  LANil2 := ABValue.FValue.getState;
  Result := (LANil = LANil2);
  if Result and (LANil = filled) then
    Result := TGenU.compare<T>(AAValue.I, ABValue.I) = 0;
end;
    { NotEqual }
class operator RAD<T>.NotEqual(AAValue, ABValue: RAD<T>): Boolean;
begin
  Result := not (AAValue = ABValue);
end;
    { GreaterThan }
class operator RAD<T>.GreaterThan(AAValue, ABValue: RAD<T>): Boolean;
var LANil,LANil2: Integer;
begin
  LANil := TEnum<EValueState>(AAValue.FValue.getState).Index;
  LANil2 := TEnum<EValueState>(ABValue.FValue.getState).Index;
  Result := (LANil > LANil2);
  if (not Result) and (LANil = LANil2) and (LANil = 2) then
    Result := TGenU.compare<T>(AAValue.I, ABValue.I) = 1;
end;
    { LessThan }
class operator RAD<T>.LessThan(AAValue, ABValue: RAD<T>): Boolean;
var LANil,LANil2: Integer;
begin
  LANil := TEnum<EValueState>(AAValue.FValue.getState).Index;
  LANil2 := TEnum<EValueState>(ABValue.FValue.getState).Index;
  Result := (LANil < LANil2);
  if (not Result) and (LANil = LANil2) and (LANil = 2) then
    Result := TGenU.compare<T>(AAValue.I, ABValue.I) = -1;
end;
    { GreaterThanOrEqual }
class operator RAD<T>.GreaterThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;
begin
  Result := (AAValue = ABValue) and (AAValue > ABValue);
end;
    { LessThanOrEqual }
class operator RAD<T>.LessThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;
begin
  Result := (AAValue = ABValue) and (AAValue < ABValue);
end;
  { Compare }
{ RAD<T> }


end.
