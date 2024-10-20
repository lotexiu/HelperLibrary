unit UGenericFunctions;

interface

uses
  Rtti;

type
  TFunc<T> = reference to function: T;
  TFunc1P<T> = reference to function(AValue: T): T;
  TFunc1P<T,R> = reference to function(AValue: T): R;
  TFunc2P<T,R> = reference to function(AValue, AValue2: T): R;
  TFunc2P<T,T2,R> = reference to function(AValue: T; AValue2: T2): R;
  TFuncArgs<T> = reference to function(AArgs: TArray<T>): T;
  TFuncArgs<T,R> = reference to function(AArgs: TArray<T>): R;
  TFuncAnyArgs<T> = reference to function(AArgs: TArray<TValue>): T;

  TProcObj = procedure of object;

implementation

end.

