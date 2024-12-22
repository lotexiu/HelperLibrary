unit UDefaultOperations;

interface

procedure DefaultOperations;

implementation

uses
  UTOperation;

procedure DefaultOperations;
var
  LDblOp     : TOperation<Double>;
  LExtOp     : TOperation<Extended>;
  LIntOp     : TOperation<Integer>;
  LObjOp     : TOperation<TObject>;
  LStrOp     : TOperation<String>;
  LBoolOp    : TOperation<Boolean>;
  LByteOp    : TOperation<Byte>;
  LCompOp    : TOperation<Comp>;
  LCurrOp    : TOperation<Currency>;
  LDateOp    : TOperation<TDateTime>;
  LRealOp    : TOperation<Real>;
  LWordOp    : TOperation<Word>;
  LInt64Op   : TOperation<Int64>;
  LCardinalOp: TOperation<Cardinal>;
  LSingleOp  : TOperation<Single>;
  LShortIntOp: TOperation<ShortInt>;
  LSmallIntOp: TOperation<SmallInt>;
begin
  LStrOp := TOperation<String>.Create;
  with LStrOp do
  begin { TODO - Try to convert first to Number }
    FuncAdd       := function(A,B: String): Double  begin Result := Length(A) +   Length(B) end;
    FuncSubtract  := function(A,B: String): Double  begin Result := Length(A) -   Length(B) end;
    FuncMultiply  := function(A,B: String): Double  begin Result := Length(A) *   Length(B) end;
    FuncDivide    := function(A,B: String): Double  begin Result := Length(A) /   Length(B) end;
    FuncIntDivide := function(A,B: String): Integer begin Result := Length(A) div Length(B) end;
  end;

  LObjOp := TOperation<TObject>.Create;
  with LObjOp do
  begin
    FuncAdd      := function(A,B: TObject): Double begin Result := NativeInt(A) + NativeInt(B) end;
    FuncSubtract := function(A,B: TObject): Double begin Result := NativeInt(A) - NativeInt(B) end;
    FuncMultiply := function(A,B: TObject): Double begin Result := NativeInt(A) * NativeInt(B) end;
    FuncDivide   := function(A,B: TObject): Double begin Result := NativeInt(A) / NativeInt(B) end;
  end;

  LIntOp := TOperation<Integer>.Create;
  with LIntOp do
  begin
    FuncAdd        := function(A,B : Integer): Double  begin Result :=     A + B    end;
    FuncSubtract   := function(A,B : Integer): Double  begin Result :=     A - B    end;
    FuncMultiply   := function(A,B : Integer): Double  begin Result :=     A * B    end;
    FuncDivide     := function(A,B : Integer): Double  begin Result :=     A / B    end;
    FuncIntDivide  := function(A,B : Integer): Integer begin Result :=     A div B  end;
    FuncNegative   := function(A   : Integer): Integer begin Result :=    -A;       end;
    FuncPositive   := function(A   : Integer): Integer begin Result := Abs(A);      end;
    FuncInc        := function(A   : Integer): Integer begin Result :=     A + 1;   end;
    FuncDec        := function(A   : Integer): Integer begin Result :=     A - 1;   end;
    FuncLogicalNot := function(A   : Integer): Boolean begin Result :=     A = 0;   end;
    FuncModulus    := function(A, B: Integer): Integer begin Result :=     A mod B; end;
  end;

  LDblOp := TOperation<Double>.Create;
  with LDblOp do
  begin
    FuncAdd        := function(A,B : Double): Double  begin Result :=     A + B               end;
    FuncSubtract   := function(A,B : Double): Double  begin Result :=     A - B               end;
    FuncMultiply   := function(A,B : Double): Double  begin Result :=     A * B               end;
    FuncDivide     := function(A,B : Double): Double  begin Result :=     A / B               end;
    FuncNegative   := function(A   : Double): Double  begin Result :=    -A;                  end;
    FuncPositive   := function(A   : Double): Double  begin Result := Abs(A);                 end;
    FuncInc        := function(A   : Double): Double  begin Result :=     A + 1;              end;
    FuncDec        := function(A   : Double): Double  begin Result :=     A - 1;              end;
    FuncLogicalNot := function(A   : Double): Boolean begin Result :=     A = 0;              end;
    FuncModulus    := function(A, B: Double): Double  begin Result :=     A - (Int(A/B) * B); end;
  end;

  LBoolOp := TOperation<Boolean>.Create;
  with LBoolOp do
  begin
    FuncAdd        := function(A,B: Boolean): Double  begin Result := Ord(A) + Ord(B) end;
    FuncMultiply   := function(A,B: Boolean): Double  begin Result := Ord(A) * Ord(B) end;
    FuncLogicalNot := function(A  : Boolean): Boolean begin Result := not A           end;
  end;

  LDateOp := TOperation<TDateTime>.Create;
  with LDateOp do
  begin
    FuncAdd      := function(A,B: TDateTime): Double    begin Result := A + B end;
    FuncSubtract := function(A,B: TDateTime): Double    begin Result := A - B end;
    FuncInc      := function(A  : TDateTime): TDateTime begin Result := A + 1 end;
    FuncDec      := function(A  : TDateTime): TDateTime begin Result := A - 1 end;
  end;

  LCurrOp := TOperation<Currency>.Create;
  with LCurrOp do
  begin
    FuncAdd      := function(A,B: Currency): Double   begin Result :=     A + B end;
    FuncSubtract := function(A,B: Currency): Double   begin Result :=     A - B end;
    FuncMultiply := function(A,B: Currency): Double   begin Result :=     A * B end;
    FuncDivide   := function(A,B: Currency): Double   begin Result :=     A / B end;
    FuncNegative := function(A  : Currency): Currency begin Result :=    -A     end;
    FuncPositive := function(A  : Currency): Currency begin Result := Abs(A)    end;
  end;

  LExtOp := TOperation<Extended>.Create;
  with LExtOp do
  begin
    FuncAdd      := function(A,B: Extended): Double   begin Result :=     A + B              end;
    FuncSubtract := function(A,B: Extended): Double   begin Result :=     A - B              end;
    FuncMultiply := function(A,B: Extended): Double   begin Result :=     A * B              end;
    FuncDivide   := function(A,B: Extended): Double   begin Result :=     A / B              end;
    FuncNegative := function(A  : Extended): Extended begin Result :=    -A                  end;
    FuncPositive := function(A  : Extended): Extended begin Result := Abs(A)                 end;
    FuncModulus  := function(A,B: Extended): Extended begin Result :=     A - (Int(A/B) * B) end;
  end;

  LInt64Op := TOperation<Int64>.Create;
  with LInt64Op do
  begin
    FuncAdd       := function(A,B: Int64): Double  begin Result :=     A + B   end;
    FuncSubtract  := function(A,B: Int64): Double  begin Result :=     A - B   end;
    FuncMultiply  := function(A,B: Int64): Double  begin Result :=     A * B   end;
    FuncDivide    := function(A,B: Int64): Double  begin Result :=     A / B   end;
    FuncIntDivide := function(A,B: Int64): Integer begin Result :=     A div B end;
    FuncNegative  := function(A  : Int64): Int64   begin Result :=    -A       end;
    FuncPositive  := function(A  : Int64): Int64   begin Result := Abs(A)      end;
    FuncInc       := function(A  : Int64): Int64   begin Result :=     A + 1   end;
    FuncDec       := function(A  : Int64): Int64   begin Result :=     A - 1   end;
    FuncModulus   := function(A,B: Int64): Int64   begin Result :=     A mod B end;
  end;

  LWordOp := TOperation<Word>.Create;
  with LWordOp do
  begin
    FuncAdd       := function(A,B: Word): Double  begin Result := A + B   end;
    FuncSubtract  := function(A,B: Word): Double  begin Result := A - B   end;
    FuncMultiply  := function(A,B: Word): Double  begin Result := A * B   end;
    FuncDivide    := function(A,B: Word): Double  begin Result := A / B   end;
    FuncIntDivide := function(A,B: Word): Integer begin Result := A div B end;
    FuncModulus   := function(A,B: Word): Word    begin Result := A mod B end;
    FuncInc       := function(A  : Word): Word    begin Result := A + 1   end;
    FuncDec       := function(A  : Word): Word    begin Result := A - 1   end;
    FuncPositive  := function(A  : Word): Word    begin Result := A       end;
  end;

  LByteOp := TOperation<Byte>.Create;
  with LByteOp do
  begin
    FuncAdd       := function(A,B: Byte): Double  begin Result := A + B   end;
    FuncSubtract  := function(A,B: Byte): Double  begin Result := A - B   end;
    FuncMultiply  := function(A,B: Byte): Double  begin Result := A * B   end;
    FuncDivide    := function(A,B: Byte): Double  begin Result := A / B   end;
    FuncIntDivide := function(A,B: Byte): Integer begin Result := A div B end;
    FuncModulus   := function(A,B: Byte): Byte    begin Result := A mod B end;
    FuncInc       := function(A  : Byte): Byte    begin Result := A + 1   end;
    FuncDec       := function(A  : Byte): Byte    begin Result := A - 1   end;
    FuncPositive  := function(A  : Byte): Byte    begin Result := A       end;
  end;

  LSingleOp := TOperation<Single>.Create;
  with LSingleOp do
  begin
    FuncAdd      := function(A,B: Single): Double begin Result :=     A + B              end;
    FuncSubtract := function(A,B: Single): Double begin Result :=     A - B              end;
    FuncMultiply := function(A,B: Single): Double begin Result :=     A * B              end;
    FuncDivide   := function(A,B: Single): Double begin Result :=     A / B              end;
    FuncNegative := function(A  : Single): Single begin Result :=    -A                  end;
    FuncPositive := function(A  : Single): Single begin Result := Abs(A)                 end;
    FuncInc      := function(A  : Single): Single begin Result :=     A + 1              end;
    FuncDec      := function(A  : Single): Single begin Result :=     A - 1              end;
    FuncModulus  := function(A,B: Single): Single begin Result :=     A - (Int(A/B) * B) end;
  end;

  LRealOp := TOperation<Real>.Create;
  with LRealOp do
  begin
    FuncAdd      := function(A,B: Real): Double begin Result :=     A + B              end;
    FuncSubtract := function(A,B: Real): Double begin Result :=     A - B              end;
    FuncMultiply := function(A,B: Real): Double begin Result :=     A * B              end;
    FuncDivide   := function(A,B: Real): Double begin Result :=     A / B              end;
    FuncNegative := function(A  : Real): Real   begin Result :=    -A                  end;
    FuncPositive := function(A  : Real): Real   begin Result := Abs(A)                 end;
    FuncInc      := function(A  : Real): Real   begin Result :=     A + 1              end;
    FuncDec      := function(A  : Real): Real   begin Result :=     A - 1              end;
    FuncModulus  := function(A,B: Real): Real   begin Result :=     A - (Int(A/B) * B) end;
  end;

  LCompOp := TOperation<Comp>.Create;
  with LCompOp do
  begin
    FuncAdd      := function(A,B: Comp): Double begin Result :=     A + B end;
    FuncSubtract := function(A,B: Comp): Double begin Result :=     A - B end;
    FuncMultiply := function(A,B: Comp): Double begin Result :=     A * B end;
    FuncDivide   := function(A,B: Comp): Double begin Result :=     A / B end;
    FuncNegative := function(A  : Comp): Comp   begin Result :=    -A     end;
    FuncPositive := function(A  : Comp): Comp   begin Result := Abs(A)    end;
  end;

  LShortIntOp := TOperation<ShortInt>.Create;
  with LShortIntOp do
  begin
    FuncAdd       := function(A,B: ShortInt): Double   begin Result :=     A + B   end;
    FuncSubtract  := function(A,B: ShortInt): Double   begin Result :=     A - B   end;
    FuncMultiply  := function(A,B: ShortInt): Double   begin Result :=     A * B   end;
    FuncDivide    := function(A,B: ShortInt): Double   begin Result :=     A / B   end;
    FuncIntDivide := function(A,B: ShortInt): Integer  begin Result :=     A div B end;
    FuncModulus   := function(A,B: ShortInt): ShortInt begin Result :=     A mod B end;
    FuncNegative  := function(A  : ShortInt): ShortInt begin Result :=    -A       end;
    FuncPositive  := function(A  : ShortInt): ShortInt begin Result := Abs(A)      end;
    FuncInc       := function(A  : ShortInt): ShortInt begin Result :=     A + 1   end;
    FuncDec       := function(A  : ShortInt): ShortInt begin Result :=     A - 1   end;
  end;

  LSmallIntOp := TOperation<SmallInt>.Create;
  with LSmallIntOp do
  begin
    FuncAdd       := function(A,B: SmallInt): Double   begin Result :=     A + B   end;
    FuncSubtract  := function(A,B: SmallInt): Double   begin Result :=     A - B   end;
    FuncMultiply  := function(A,B: SmallInt): Double   begin Result :=     A * B   end;
    FuncDivide    := function(A,B: SmallInt): Double   begin Result :=     A / B   end;
    FuncIntDivide := function(A,B: SmallInt): Integer  begin Result :=     A div B end;
    FuncModulus   := function(A,B: SmallInt): SmallInt begin Result :=     A mod B end;
    FuncNegative  := function(A  : SmallInt): SmallInt begin Result :=    -A       end;
    FuncPositive  := function(A  : SmallInt): SmallInt begin Result := Abs(A)      end;
    FuncInc       := function(A  : SmallInt): SmallInt begin Result :=     A + 1   end;
    FuncDec       := function(A  : SmallInt): SmallInt begin Result :=     A - 1   end;
  end;

  LCardinalOp := TOperation<Cardinal>.Create;
  with LCardinalOp do
  begin
    FuncAdd       := function(A,B: Cardinal): Double   begin Result := A + B   end;
    FuncSubtract  := function(A,B: Cardinal): Double   begin Result := A - B   end;
    FuncMultiply  := function(A,B: Cardinal): Double   begin Result := A * B   end;
    FuncDivide    := function(A,B: Cardinal): Double   begin Result := A / B   end;
    FuncIntDivide := function(A,B: Cardinal): Integer  begin Result := A div B end;
    FuncModulus   := function(A,B: Cardinal): Cardinal begin Result := A mod B end;
    FuncInc       := function(A  : Cardinal): Cardinal begin Result := A + 1   end;
    FuncDec       := function(A  : Cardinal): Cardinal begin Result := A - 1   end;
    FuncPositive  := function(A  : Cardinal): Cardinal begin Result := A       end;
  end;

  TOperations.new<TObject  > ('Default', LObjOp     );
  TOperations.new<Integer  > ('Default', LIntOp     );
  TOperations.new<Double   > ('Default', LDblOp     );
  TOperations.new<String   > ('Default', LStrOp     );
  TOperations.new<Boolean  > ('Default', LBoolOp    );
  TOperations.new<TDateTime> ('Default', LDateOp    );
  TOperations.new<Currency > ('Default', LCurrOp    );
  TOperations.new<Extended > ('Default', LExtOp     );
  TOperations.new<Int64    > ('Default', LInt64Op   );
  TOperations.new<Word     > ('Default', LWordOp    );
  TOperations.new<Byte     > ('Default', LByteOp    );
  TOperations.new<Single   > ('Default', LSingleOp  );
  TOperations.new<Real     > ('Default', LRealOp    );
  TOperations.new<Comp     > ('Default', LCompOp    );
  TOperations.new<ShortInt > ('Default', LShortIntOp);
  TOperations.new<SmallInt > ('Default', LSmallIntOp);
  TOperations.new<Cardinal > ('Default', LCardinalOp);
end;

end.
