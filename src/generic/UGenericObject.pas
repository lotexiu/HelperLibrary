unit UGenericObject;

interface

uses
  Rtti,
  TypInfo;

type
  TGenericObject = class
  private
  public
    Value: Pointer;
    TypeInfo: PTypeInfo;
    TTValue: TValue;
  end;

implementation

end.
