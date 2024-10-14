unit UArray;

interface

uses
  Rtti,
  TypInfo,
  Generics.Collections,
  SysUtils,
  UArrayReferences;

var
  xArrayLogs: Boolean = False;

type
  RArray<T> = record
  private
    { son fields }
    FIndex: Integer;
    FFather: Pointer;
    FFatherMethod: TProc<Integer, Integer, Pointer>;
    FRArraySon: Boolean;
    { fields }
    FValue: _array<T>;
    FRttiContext: TRttiContext;
    FRtti: TRttiType;
    FMethod: TProc<Integer, Integer, Pointer>;
    function getItem(AIndex: Integer): T;
    procedure setItem(AIndex: Integer; const Value: T);
    function getCount: Integer;
    procedure updateChildrens(AIndex: Integer);

    procedure createMethod;
  public
    class operator Initialize (out Dest: RArray<T>);
    class operator Finalize (var Dest: RArray<T>);

    property &Index: Integer read FIndex;
    property Item[Index: Integer]: T read getItem write setItem; default;
    property Count: Integer read getCount;

    procedure forEach(AProc: TForEachIndex<T>); overload;
  end;

implementation

uses
  StrUtils,
  UGenericUtils,
  UArrayUtils;

{ RArray<T> }

procedure RArray<T>.createMethod;
var
  LSelf: Pointer;
begin
  LSelf := @Self;
  FMethod := procedure(AIndex, AIndex2: Integer; ASon: Pointer)
  var
    LRContext: TRttiContext;
    LField: TRttiField;
    LValue: TValue;
    LSelf2: RArray<T>;
    LArrayPointer: Pointer;
  begin
    LSelf2 := RArray<T>((LSelf)^);
    LField := TGenericUtils.rttiType<T>(LRContext).GetField('FValue');
    LValue := LField.GetValue(ASon);
    LArrayPointer := LValue.GetReferenceToRawData;
    DynArraySetLength(LArrayPointer,LField.FieldType.Handle,1,@AIndex2);
    LRContext.Free;
  end;
end;

class operator RArray<T>.Finalize(var Dest: RArray<T>);
begin
  Dest.FRttiContext.Free;
end;

class operator RArray<T>.Initialize(out Dest: RArray<T>);
var
  LRtti: TRttiType;
begin
  Dest.FFather := nil;
  Dest.FFatherMethod := nil;
  Dest.FIndex := -1;
  Dest.FRtti := TGenericUtils.rttiType<RArray<T>>(Dest.FRttiContext);
  Dest.createMethod;
  LRtti := TGenericUtils.rttiType<T>;
  if (LRtti.IsRecord) and (ContainsText(TGenericUtils.typeName<T>, 'RArray')) then
    Dest.FRArraySon := True;
end;

procedure RArray<T>.forEach(AProc: TForEachIndex<T>);
begin
  TArrayUtils.forEach<T>(@FValue,AProc);
end;

function RArray<T>.getCount: Integer;
begin
  Result := Length(FValue);
end;

function RArray<T>.getItem(AIndex: Integer): T;
begin
  updateChildrens(AIndex);
  Result := FValue[AIndex];
end;

procedure RArray<T>.setItem(AIndex: Integer; const Value: T);
begin
  updateChildrens(AIndex);
  FValue[AIndex] := Value;
end;

procedure RArray<T>.updateChildrens(AIndex: Integer);
var
  LCurrentSize: Integer;
  LPSelf: Pointer;
  LMethod: TProc<Integer, Integer, Pointer>;
  LRtti: TRttiType;
  LValue: TValue;
begin
  LCurrentSize := Count;
  LPSelf := @Self;
  LMethod := FMethod;

  if (LCurrentSize <= AIndex) then { Preventing Error }
  begin
    if (FFather <> nil) and (Index <> -1) then
    begin
      FFatherMethod(Index,AIndex, LPSelf);
    end
    else
      SetLength(FValue, AIndex+1);

    if (FRArraySon) then { Its a RArray? }
    begin
      forEach(procedure(out AItem: T; AItemIndex: Integer)
      begin
        { Make the childrens recognize the father and your positions }
        TGenericUtils.setFieldValue<T,Pointer>(@AItem,'FFather', LPSelf);
        TGenericUtils.setFieldValue<T,TProc<Integer, Integer, Pointer>>(@AItem, 'FFatherMethod', LMethod);
        TGenericUtils.setFieldValue<T,Integer>(@AItem,'FIndex', AItemIndex);
      end);
    end;
  end;
end;

end.
