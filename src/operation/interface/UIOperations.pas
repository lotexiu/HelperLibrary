unit UIOperations;

interface

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

implementation

end.
