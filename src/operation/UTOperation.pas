unit UTOperation;

interface

uses
  UGenericFunctions,
  UGenericDictionary,
  UIOperations;

type
  TOperation<T> = class(TInterfacedObject,
    IAdd<T>,        ISubtract<T>,
    IMultiply<T>,   IDivide<T>,
    INegative<T>,   IPositive<T>,
    IInc<T>,        IDec<T>,
    ILogicalNot<T>, IModulus<T>
  )
  private
    FFAdd:        TFunc2P<T,Double>;
    FFSubtract:   TFunc2P<T,Double>;
    FFMultiply:   TFunc2P<T,Double>;
    FFDivide:     TFunc2P<T,Double>;
    FFIntDivide:  TFunc2P<T,Integer>;
    FFNegative:   TFunc1P<T,T>;
    FFPositive:   TFunc1P<T,T>;
    FFInc:        TFunc1P<T,T>;
    FFDec:        TFunc1P<T,T>;
    FFLogicalNot: TFunc1P<T,Boolean>;
    FFModulus:    TFunc2P<T,T>;
  public
    constructor Create;
    property FuncAdd:        TFunc2P<T,Double > read FFAdd        write FFAdd;
    property FuncSubtract:   TFunc2P<T,Double > read FFSubtract   write FFSubtract;
    property FuncMultiply:   TFunc2P<T,Double > read FFMultiply   write FFMultiply;
    property FuncDivide:     TFunc2P<T,Double > read FFDivide     write FFDivide;
    property FuncIntDivide:  TFunc2P<T,Integer> read FFIntDivide  write FFIntDivide;
    property FuncNegative:   TFunc1P<T,T>       read FFNegative   write FFNegative;
    property FuncPositive:   TFunc1P<T,T>       read FFPositive   write FFPositive;
    property FuncInc:        TFunc1P<T,T>       read FFInc        write FFInc;
    property FuncDec:        TFunc1P<T,T>       read FFDec        write FFDec;
    property FuncLogicalNot: TFunc1P<T,Boolean> read FFLogicalNot write FFLogicalNot;
    property FuncModulus:    TFunc2P<T,T>       read FFModulus    write FFModulus;

    function Add       (const A, B: T): Double ;
    function Subtract  (const A, B: T): Double ;
    function Multiply  (const A, B: T): Double ;
    function Divide    (const A, B: T): Double ;
    function IntDivide (const A, B: T): Integer;
    function Negative  (const A: T):    T      ;
    function Positive  (const A: T):    T      ;
    function Inc       (const A: T):    T      ;
    function Dec       (const A: T):    T      ;
    function LogicalNot(const A: T):    Boolean;
    function Modulus   (const A, B: T): T      ;
  end;

  TOperations = class
  protected
    class var Operations: TGenericDictionary;
  public
    class procedure new<T>(AOperationType: String; AOperation: TOperation<T>);
    class function get<T>(AOperationType: String): TOperation<T>;
  end;

const
  CDoesntExists = 'doesn''t exist on this Operation!';

implementation

uses
  UDefaultOperations,
  UOperationException,
  UEasyImport;

{ TTOperation<T> }

constructor TOperation<T>.Create;
begin
  FFAdd       := nil;
  FFSubtract  := nil;
  FFMultiply  := nil;
  FFDivide    := nil;
end;

function TOperation<T>.Add(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Add ' + CDoesntExists);
  Result := FFAdd(A,B);
end;

function TOperation<T>.Subtract(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Subtract ' + CDoesntExists);
  Result := FFSubtract(A,B);
end;

function TOperation<T>.Multiply(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Multiply ' + CDoesntExists);
  Result := FFMultiply(A,B);
end;

function TOperation<T>.Divide(const A, B: T): Double;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Divide ' + CDoesntExists);
  Result := FFDivide(A,B);
end;

function TOperation<T>.IntDivide(const A, B: T): Integer;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Divide ' + CDoesntExists);
  Result := FFIntDivide(A,B);
end;

function TOperation<T>.Negative(const A: T): T;
begin
  if (@FFNegative = nil) then
    raise TOperationException.Create('Negative ' + CDoesntExists);
  Result := FFNegative(A);
end;

function TOperation<T>.Positive(const A: T): T;
begin
  if (@FFPositive = nil) then
    raise TOperationException.Create('Positive ' + CDoesntExists);
  Result := FFPositive(A);
end;

function TOperation<T>.Inc(const A: T): T;
begin
  if (@FFInc = nil) then
    raise TOperationException.Create('Inc ' + CDoesntExists);
  Result := FFInc(A);
end;

function TOperation<T>.Dec(const A: T): T;
begin
  if (@FFDec = nil) then
    raise TOperationException.Create('Dec ' + CDoesntExists);
  Result := FFDec(A);
end;

function TOperation<T>.LogicalNot(const A: T): Boolean;
begin
  if (@FFLogicalNot = nil) then
    raise TOperationException.Create('LogicalNot ' + CDoesntExists);
  Result := FFLogicalNot(A);
end;

function TOperation<T>.Modulus(const A, B: T): T;
begin
  if (@FFModulus = nil) then
    raise TOperationException.Create('Modulus ' + CDoesntExists);
  Result := FFModulus(A, B);
end;

{ TOperations }

class function TOperations.get<T>(AOperationType: String): TOperation<T>;
begin
  Result := TOperations.Operations.get<TOperation<T>>(TGenU.typeName<T>+AOperationType);
  if (Result = nil) then
  begin
    if TGenU.isObject<T> then
      Result := TGenU.castTo<TOperation<T>, TOperation<TObject>>(
        TOperations.Operations.get<TOperation<TObject>>(TGenU.typeName<T>+AOperationType))
    else
      raise TOperationException.Create(
        AOperationType+'of '+TGenU.typeName<T>+' doesn''t exists. you need to implement that.'+sLineBreak+
        'TOPerations.new<T>('+AOperationType+', TTOperation<T>)'
      );
  end;
end;

class procedure TOperations.new<T>(AOperationType: String;
  AOperation: TOperation<T>);
begin
  TOperations.Operations.add<TOperation<T>>(
    TGenU.typeName<T>+AOperationType,
    AOperation);
end;

initialization
  TOperations.Operations := TGenericDictionary.Create;
  DefaultOperations;

finalization
  TOperations.Operations.FreeValuesOnDestroy := True;
  TGenU.freeAndNil(TOperations.Operations);

end.

