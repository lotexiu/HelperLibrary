unit UGenericValue;

interface

type
  TGenericValue<T> = record
  private
  public
    Value: T;
    constructor Create(AValue: T);
    class operator Initialize(out Dest: TGenericValue<T>);
    class operator Finalize(var Dest: TGenericValue<T>);
  end;

implementation

uses
  UGenericUtils;

{ TGenericValue<T> }

constructor TGenericValue<T>.Create(AValue: T);
begin
  Value := AValue;
end;

class operator TGenericValue<T>.Finalize(var Dest: TGenericValue<T>);
begin
  TGenericUtils.freeAndNil<T>(Dest.Value);
end;

class operator TGenericValue<T>.Initialize(out Dest: TGenericValue<T>);
begin
  Dest.Value := Default(T);
end;

end.
