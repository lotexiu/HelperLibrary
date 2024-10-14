unit UArray;

interface

uses
  Rtti,
  Generics.Collections,
  UArrayReferences;

type
  TArrayRecord<T> = record
  private
    FValue: _array<T>;
    function getItem(Index: Integer): T;
    procedure setItem(Index: Integer; const Value: T);
    procedure initializeSubArray(Index: Integer);
  public
    class operator Initialize (out Dest: TArrayRecord<T>);
    class operator Finalize (var Dest: TArrayRecord<T>);
    class function Create: TArrayRecord<T>; static;
    property Item[Index: Integer]: T read getItem write setItem; default;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  UGenericUtils;

{ TArrayRecord<T> }

class function TArrayRecord<T>.Create: TArrayRecord<T>;
begin
  Result.FValue := [Default(T)];
end;

class operator TArrayRecord<T>.Finalize(var Dest: TArrayRecord<T>);
begin

end;

class operator TArrayRecord<T>.Initialize(out Dest: TArrayRecord<T>);
begin
  Dest.FValue := [];
end;


procedure TArrayRecord<T>.initializeSubArray(Index: Integer);
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  ValuePtr: Pointer;
  DynArrayTypeInfo: PTypeInfo;
  LengthVec: NativeInt;
begin
  LengthVec := 1;
  ValuePtr := @FValue[Index];
  RttiType := TGenericUtils.rttiType<T>(RttiContext);
  if RttiType.IsRecord then
  begin
    DynArrayTypeInfo := RttiType.GetField('FValue').FieldType.Handle;
    if TGenericUtils.isArray(DynArrayTypeInfo) then
      DynArraySetLength(PPointer(ValuePtr)^, DynArrayTypeInfo, 1, @LengthVec);
  end;
end;

procedure TArrayRecord<T>.setItem(Index: Integer; const Value: T);
begin
  if Length(FValue) <= Index then
    SetLength(FValue, Index + 1);
  initializeSubArray(Index);
  FValue[Index] := Value;
end;

function TArrayRecord<T>.getItem(Index: Integer): T;
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  ValuePtr: Pointer;
  DynArrayTypeInfo: PTypeInfo;
  LengthVec: NativeInt;
begin
  if Length(FValue) <= Index then
    SetLength(FValue, Index + 1);
  initializeSubArray(Index);
  Result := FValue[Index];
end;

end.
