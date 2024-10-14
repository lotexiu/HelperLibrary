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

  TFilter<T> = reference to function(AValue: T): T;
  TFilterIndex<T> = reference to function(AValue: T; AIndex: Integer): T;

  _array<T> = array of T;

implementation

end.
