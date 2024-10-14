unit URtti;

interface

uses
  Rtti,
  TypInfo;

type
  RRtti<T> = record
  private
    FContext: TRttiContext;
    FType: TRttiType;
    FTypeInfo: PTypeInfo;
  public
    class operator Initialize (out Dest: RRtti<T>);
    class operator Finalize (var Dest: RRtti<T>);
  end;

implementation

uses
  UGenericUtils;

{ RRtti<T> }

class operator RRtti<T>.Finalize(var Dest: RRtti<T>);
begin
   Dest.FType := TGenericUtils.rttiType<T>(Dest.FContext);
   Dest.FTypeInfo := Dest.FType.Handle;
end;

class operator RRtti<T>.Initialize(out Dest: RRtti<T>);
begin

end;

end.
