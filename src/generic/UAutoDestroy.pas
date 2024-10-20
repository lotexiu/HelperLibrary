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
    filled, {Shouldn't be used}
    empty,  {Shouldn't be used}
    nill    {Shouldn't be used}
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
    FContext: TRttiContext;
    function getValue: T;
    procedure setValue(const Value: T);
    procedure updateRtti;
  public
    class operator Implicit(AValue: IAD<Variant>): RAD<T>;
    class operator Implicit(AValue: EValueState): RAD<T>;
    class operator Implicit(AValue: T): RAD<T>;
    class operator Implicit(AValue: RAD<T>): IAD<Variant>;
    class operator Implicit(AValue: RAD<T>): T;

    class operator Equal(AAValue, ABValue: RAD<T>): Boolean;
    class operator NotEqual(AAValue, ABValue: RAD<T>): Boolean;
    class operator GreaterThan(AAValue, ABValue: RAD<T>): Boolean;
    class operator LessThan(AAValue, ABValue: RAD<T>): Boolean;
    class operator GreaterThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;
    class operator LessThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;

    property Rtti: TRttiType read FRtti;
    property I: T read getValue write setValue;
  end;

function AD(AValue:Variant): IAD<Variant>;

implementation

uses
  SysUtils,
  Generics.Defaults,
  UGenericUtils,
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
  TGenericUtils.freeAndNil<T>(T(FPValue^));
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
  FPValue := @AValue;
end;

procedure TAutoDestroy<T>.setValue(const Value: T);
var LDefault: Boolean;
begin
  LDefault := TGenericUtils.isEmptyOrNull<T>(Value);
  if LDefault then
  begin
    FTValue := Default(T);
    if TGenericUtils.isObject<T> then
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



{ RAD<T> }

function RAD<T>.getValue: T;
begin
  Result := FValue.getValue;
end;

procedure RAD<T>.setValue(const Value: T);
begin
  FValue.setValue(Value);
end;

procedure RAD<T>.updateRtti;
begin
  FContext.Free;
  FRtti := TGenericUtils.rttiType<T>(FContext);
end;

{ Implicit }
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

class operator RAD<T>.Implicit(AValue: IAD<Variant>): RAD<T>;
begin
  Result.FValue := AValue as IAD<T>;
//  Result.updateRtti;
end;

class operator RAD<T>.Implicit(AValue: T): RAD<T>;
begin
  Result.FValue := TAutoDestroy<T>.Create(AValue);
//  Result.updateRtti;
end;

class operator RAD<T>.Implicit(AValue: RAD<T>): IAD<Variant>;
begin
  Result := AValue.FValue as IAD<Variant>;
end;

class operator RAD<T>.Implicit(AValue: RAD<T>): T;
begin
  Result := AValue.FValue.getValue;
end;
{ Implicit }

{ Compare }
class operator RAD<T>.Equal(AAValue, ABValue: RAD<T>): Boolean;
var LANil,LANil2: EValueState;
begin
  LANil := AAValue.FValue.getState;
  LANil2 := ABValue.FValue.getState;
  Result := (LANil = LANil2);
  if Result and (LANil = filled) then  
    Result := TGenericUtils.compare<T>(AAValue.I, ABValue.I) = 0;
end;

class operator RAD<T>.NotEqual(AAValue, ABValue: RAD<T>): Boolean;
begin
  Result := not (AAValue = ABValue);
end;

class operator RAD<T>.GreaterThan(AAValue, ABValue: RAD<T>): Boolean;
var LANil,LANil2: Integer;
begin
  LANil := TEnum<EValueState>(AAValue.FValue.getState).Index;
  LANil2 := TEnum<EValueState>(ABValue.FValue.getState).Index;
  Result := (LANil > LANil2);
  if (not Result) and (LANil = LANil2) and (LANil = 1) then   
    Result := TGenericUtils.compare<T>(AAValue.I, ABValue.I) = 1;
end;

class operator RAD<T>.LessThan(AAValue, ABValue: RAD<T>): Boolean;
var LANil,LANil2: Integer;
begin
  LANil := TEnum<EValueState>(AAValue.FValue.getState).Index;
  LANil2 := TEnum<EValueState>(ABValue.FValue.getState).Index;
  Result := (LANil < LANil2);
  if (not Result) and (LANil = LANil2) and (LANil = 1) then   
    Result := TGenericUtils.compare<T>(AAValue.I, ABValue.I) = -1;
end;

class operator RAD<T>.GreaterThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;
begin
  Result := (AAValue = ABValue) and (AAValue > ABValue);
end;

class operator RAD<T>.LessThanOrEqual(AAValue, ABValue: RAD<T>): Boolean;
begin
  Result := (AAValue = ABValue) and (AAValue < ABValue);
end;
{ Compare }

end.
