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

  INegative<T> = interface
    ['{CF6FE0E7-A224-4DC9-9E8F-22F0B2317BEE}']
    function Negative(const A: T): T;
  end;

  IPositive<T> = interface
    ['{C6BB704F-4DAA-47A4-894F-46ED913DDA4C}']
    function Positive(const A: T): T;
  end;

  IInc<T> = interface
    ['{4E36AC15-D9A7-4390-95DD-F27B36B5136D}']
    function Inc(const A: T): T;
  end;

  IDec<T> = interface
    ['{226BB709-906A-462F-A3CF-EFE43E95ED2D}']
    function Dec(const A: T): T;
  end;

  ILogicalNot<T> = interface
    ['{BA8197D9-0EB3-4E6A-A92D-19EA2F8A0A0D}']
    function LogicalNot(const A: T): Boolean;
  end;

  IModulus<T> = interface
    ['{FC5FD045-AF07-4B91-B657-4361ECC3F7EB}']
    function Modulus(const A, B: T): T;
  end;

  TTOperation<T> = class(TInterfacedObject,
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

function TTOperation<T>.IntDivide(const A, B: T): Integer;
begin
  if (@FFAdd = nil) then
    raise TOperationException.Create('Divide doens''t exists on this Operation!');
  Result := FFIntDivide(A,B);
end;

function TTOperation<T>.Negative(const A: T): T;
begin
  if (@FFNegative = nil) then
    raise TOperationException.Create('Negative doesn''t exist on this Operation!');
  Result := FFNegative(A);
end;

function TTOperation<T>.Positive(const A: T): T;
begin
  if (@FFPositive = nil) then
    raise TOperationException.Create('Positive doesn''t exist on this Operation!');
  Result := FFPositive(A);
end;

function TTOperation<T>.Inc(const A: T): T;
begin
  if (@FFInc = nil) then
    raise TOperationException.Create('Inc doesn''t exist on this Operation!');
  Result := FFInc(A);
end;

function TTOperation<T>.Dec(const A: T): T;
begin
  if (@FFDec = nil) then
    raise TOperationException.Create('Dec doesn''t exist on this Operation!');
  Result := FFDec(A);
end;

function TTOperation<T>.LogicalNot(const A: T): Boolean;
begin
  if (@FFLogicalNot = nil) then
    raise TOperationException.Create('LogicalNot doesn''t exist on this Operation!');
  Result := FFLogicalNot(A);
end;

function TTOperation<T>.Modulus(const A, B: T): T;
begin
  if (@FFModulus = nil) then
    raise TOperationException.Create('Modulus doesn''t exist on this Operation!');
  Result := FFModulus(A, B);
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
    FuncAdd      := function(A,B: String): Double begin Result := Length(A) + Length(B) end;
    FuncSubtract := function(A,B: String): Double begin Result := Length(A) - Length(B) end;
    FuncMultiply := function(A,B: String): Double begin Result := Length(A) * Length(B) end;
    FuncDivide   := function(A,B: String): Double begin Result := Length(A) / Length(B) end;
    FuncIntDivide:= function(A,B: String): Integer begin Result := Length(A) div Length(B) end;
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
    FuncAdd         := function(A,B: Integer):  Double begin Result := A + B      end;
    FuncSubtract    := function(A,B: Integer):  Double begin Result := A - B      end;
    FuncMultiply    := function(A,B: Integer):  Double begin Result := A * B      end;
    FuncDivide      := function(A,B: Integer):  Double begin Result := A / B      end;
    FuncIntDivide   := function(A,B: Integer): Integer begin Result := A div B    end;
    FuncNegative    := function(A: Integer):   Integer begin Result := -A;        end;
    FuncPositive    := function(A: Integer):   Integer begin Result := Abs(A);    end;
    FuncInc         := function(A: Integer):   Integer begin Result := A + 1;     end;
    FuncDec         := function(A: Integer):   Integer begin Result := A - 1;     end;
    FuncLogicalNot  := function(A: Integer):   Boolean begin Result := A = 0;     end;
    FuncModulus     := function(A, B: Integer): Integer begin Result := A mod B;  end;
  end;

  LDblOp := TTOperation<Double>.Create;
  with LDblOp do
  begin
    FuncAdd         := function(A,B: Double): Double begin Result := A + B        end;
    FuncSubtract    := function(A,B: Double): Double begin Result := A - B        end;
    FuncMultiply    := function(A,B: Double): Double begin Result := A * B        end;
    FuncDivide      := function(A,B: Double): Double begin Result := A / B        end;
    FuncNegative    := function(A: Double):   Double begin Result := -A;          end;
    FuncPositive    := function(A: Double):   Double begin Result := Abs(A);      end;
    FuncInc         := function(A: Double):   Double begin Result := A + 1;       end;
    FuncDec         := function(A: Double):   Double begin Result := A - 1;       end;
    FuncLogicalNot  := function(A: Double):   Boolean begin Result := A = 0;      end;
    FuncModulus     := function(A, B: Double): Double begin Result := A - (Int(A/B) * B); end;
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

