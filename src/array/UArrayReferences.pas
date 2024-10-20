unit UArrayReferences;

interface

uses
  Generics.Collections;

type
  TForEach<T> = reference to procedure(out AValue: T);
  TForEachIndex<T> = reference to procedure(out AValue: T; AIndex: Integer);
  TForEachBreak<T> = reference to procedure(out AValue: T; out ABreak: Boolean);
  TForEachIndexBreak<T> = reference to procedure(out AValue: T; AIndex: Integer; out ABreak: Boolean);

  TMap<T> = reference to function(AValue: T): T;
  TMap<T,R> = reference to function(AValue: T): R;
  TMapIndex<T> = reference to function(AValue: T; AIndex: Integer): T;
  TMapIndex<T,R> = reference to function(AValue: T; AIndex: Integer): R;

  TFind<T> = reference to function(AValue: T): T;
  TFindIndex<T> = reference to function(AValue: T; AIndex: Integer): T;
  TFindBreak<T> = reference to function(AValue: T; out ABreak: Boolean): T;
  TFindIndexBreak<T> = reference to function(AValue: T; AIndex: Integer; out ABreak: Boolean): T;

  TFilter<T> = reference to procedure(out AValue: T);
  TFilterIndex<T> = reference to procedure(out AValue: T; AIndex: Integer);

  TReduce<T> = reference to function(out AAccumulator: T; ACurrentValue: T): T;

  TSort<T> = reference to function(AAValue, ABValue: T): T;

  _array<T> = array of T;

implementation

end.
