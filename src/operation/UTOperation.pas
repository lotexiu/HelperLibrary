unit UTOperation;

interface

uses
  UGenericFunctions,
  UGenericDictionary;

type
  IAdd<T> = interface
    ['{909130CF-3B0D-415F-A495-0F7EA091A689}']
    function Add(const A, B: T): Double;
  end;

  ISubtract<T> = interface
    ['{48CD5981-6309-4E22-BF07-19AD2CB22304}']
    function Subtract(const A, B: T): Double;
  end;

  IMultiply<T> = interface
    ['{48CD5981-6309-4E22-BF07-19AD2CB22304}']
    function Multiply(const A, B: T): Double;
  end;

  IDivide<T> = interface
    ['{48CD5981-6309-4E22-BF07-19AD2CB22304}']
    function Divide(const A, B: T): Double;
  end;

  TTOperation<T> = class(TInterfacedObject,
    IAdd<T>,      ISubtract<T>,
    IMultiply<T>, IDivide<T>
  )
  private
    FFAdd:      TFunc2P<T,Double>;
    FFSubtract: TFunc2P<T,Double>;
    FFMultiply: TFunc2P<T,Double>;
    FFDivide:   TFunc2P<T,Double>;
  public
    constructor Create;
    property FuncAdd     : TFunc2P<T,Double> read FFAdd      write FFAdd     ;
    property FuncSubtract: TFunc2P<T,Double> read FFSubtract write FFSubtract;
    property FuncMultiply: TFunc2P<T,Double> read FFMultiply write FFMultiply;
    property FuncDivide  : TFunc2P<T,Double> read FFDivide   write FFDivide  ;

    function Add     (const A, B: T): Double;
    function Subtract(const A, B: T): Double;
    function Multiply(const A, B: T): Double;
    function Divide  (const A, B: T): Double;
  end;

  TOperations = class
  protected
    class var Operations: TGenericDictionary;
  public
    class procedure new<T>(AOperationType: String; AOperation: TTOperation<T>);
    class function get<T>(AOperationType: String): TTOperation<T>;
  end;

procedure DefaultOperations;

implementation

uses
  UOperationException,
  UEasyImport;

{ TTOperation<T> }

constructor TTOperation<T>.Create;
begin
  FFAdd       := nil;
  FFSubtract  := nil;
  FFMultiply  := nil;
  FFDivide    := nil;
end;

function TTOperation<T>.Add(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Add doens''t exists on this Operation!');
  Result := FFAdd(A,B);
end;

function TTOperation<T>.Subtract(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Subtract doens''t exists on this Operation!');
  Result := FFSubtract(A,B);
end;

function TTOperation<T>.Multiply(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Multiply doens''t exists on this Operation!');
  Result := FFMultiply(A,B);
end;

function TTOperation<T>.Divide(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Divide doens''t exists on this Operation!');
  Result := FFDivide(A,B);
end;

{ TOperations }

class function TOperations.get<T>(AOperationType: String): TTOperation<T>;
begin
  Result := TOperations.Operations.get<TTOperation<T>>(TGenU.typeName<T>+AOperationType);
  if (Result = nil) then
  begin
    if TGenU.isObject<T> then
      Result := TGenU.castTo<TTOperation<T>, TTOperation<TObject>>(
        TOperations.Operations.get<TTOperation<TObject>>(TGenU.typeName<T>+AOperationType))
    else
      raise TOperationException.Create(
        AOperationType+'of '+TGenU.typeName<T>+' doens''t exists. you need to implement that.'+sLineBreak+
        'TOPerations.new<T>('+AOperationType+', TTOperation<T>)'
      );
  end;
end;

class procedure TOperations.new<T>(AOperationType: String;
  AOperation: TTOperation<T>);
begin
  TOperations.Operations.add<TTOperation<T>>(
    TGenU.typeName<T>+AOperationType,
    AOperation);
end;

procedure DefaultOperations;
var
  LObjOp: TTOperation<TObject>;
  LIntOp: TTOperation<Integer>;
  LDblOp: TTOperation<Double>;
  LStrOp: TTOperation<String>;
begin
  LStrOp := TTOperation<String>.Create;
  with LStrOp do
  begin { TODO - Try to convert first to Number }
    FuncAdd      := function(A,B: String): Double begin
      Result := Length(A) + Length(B)
    end;
    FuncSubtract := function(A,B: String): Double begin
      Result := Length(A) - Length(B)
    end;
    FuncMultiply := function(A,B: String): Double begin
      Result := Length(A) * Length(B)
    end;
    FuncDivide   := function(A,B: String): Double begin
      Result := Length(A) / Length(B)
    end;
  end;

  LObjOp := TTOperation<TObject>.Create;
  with LObjOp do
  begin
    FuncAdd      := function(A,B: TObject): Double begin Result := NativeInt(A) + NativeInt(B) end;
    FuncSubtract := function(A,B: TObject): Double begin Result := NativeInt(A) - NativeInt(B) end;
    FuncMultiply := function(A,B: TObject): Double begin Result := NativeInt(A) * NativeInt(B) end;
    FuncDivide   := function(A,B: TObject): Double begin Result := NativeInt(A) / NativeInt(B) end;
  end;
  LIntOp := TTOperation<Integer>.Create;
  with LIntOp do
  begin
    FuncAdd      := function(A,B: Integer): Double begin Result := A + B end;
    FuncSubtract := function(A,B: Integer): Double begin Result := A - B end;
    FuncMultiply := function(A,B: Integer): Double begin Result := A * B end;
    FuncDivide   := function(A,B: Integer): Double begin Result := A / B end;
  end;
  LDblOp := TTOperation<Double>.Create;
  with LDblOp do
  begin
    FuncAdd      := function(A,B: Double): Double begin Result := A + B end;
    FuncSubtract := function(A,B: Double): Double begin Result := A - B end;
    FuncMultiply := function(A,B: Double): Double begin Result := A * B end;
    FuncDivide   := function(A,B: Double): Double begin Result := A / B end;
  end;

  TOperations.new<TObject>('Default',LObjOp);
  TOperations.new<Integer>('Default',LIntOp);
  TOperations.new<Double> ('Default',LDblOp);
  TOperations.new<String> ('Default',LStrOp);
end;

initialization
  TOperations.Operations := TGenericDictionary.Create;
  DefaultOperations;

finalization
  TOperations.Operations.FreeValuesOnDestroy := True;
  TGenU.freeAndNil(TOperations.Operations);

end.

