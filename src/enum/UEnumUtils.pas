unit UEnumUtils;

interface

uses
  Rtti,
  TypInfo,
  UEnumException;

type
  TEnumUtils = class
  private
  public
    class function toList<T>: TArray<Variant>;
    class function length<T>: Integer; static;
    class function indexOf<T>(AEnum: T): Integer;
    class function strToValue<T>(AEnum: String): T;
    class function enumOf<T>(AEnum: Integer): T;
  end;

  TEnumDetails = class(TCustomAttribute)
  private
    FTitle: String;
    FNumber: Integer;
  public
    property Title: string read FTitle;
    property Number: Integer read FNumber;
    constructor Create(ATitle: String; ANumber: Integer); overload;
    constructor Create(ATitle: String); overload;
  end;

  [TEnumDetails('Segunda',1)]
  [TEnumDetails('Terca',2)]
  [TEnumDetails('Quarta',3)]
  [TEnumDetails('Quinta',4)]
  [TEnumDetails('Sexta',5)]
  [TEnumDetails('Sabado',6)]
  [TEnumDetails('Domingo',7)]
  TWeekDay = (
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
    Sunday
  );

  [TEnumDetails('Janeiro',1)]
  [TEnumDetails('Fevereiro',2)]
  [TEnumDetails('Marco',3)]
  [TEnumDetails('Abril',4)]
  [TEnumDetails('Maio',5)]
  [TEnumDetails('Junho',6)]
  [TEnumDetails('Julho',7)]
  [TEnumDetails('Agosto',8)]
  [TEnumDetails('Setembro',9)]
  [TEnumDetails('Outubro',10)]
  [TEnumDetails('Novembro',11)]
  [TEnumDetails('Dezembro',12)]
  TMonth = (
    January,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
  );

implementation

uses
  UGenericUtils;

{ TEnumDetails }

constructor TEnumDetails.Create(ATitle: String; ANumber: Integer);
begin
  FTitle := ATitle;
  FNumber := ANumber;
end;

constructor TEnumDetails.Create(ATitle: String);
begin
  FTitle := ATitle;
end;

{ TEnumUtils }

class function TEnumUtils.enumOf<T>(AEnum: Integer): T;
begin
  Result := TValue.FromOrdinal(TypeInfo(T), AEnum).AsType<T>;
end;

class function TEnumUtils.indexOf<T>(AEnum: T): Integer;
var
  I: Integer;
  FEnumVariant, FEnumVariant2: Variant;
begin
  Result := -1;
  for I := 0 to TEnumUtils.length<T> -1  do
  begin
    FEnumVariant := TValue.FromOrdinal(TypeInfo(T), I).AsVariant;
    FEnumVariant2 := TValue.From<T>(AEnum).AsVariant;
    if (FEnumVariant = FEnumVariant2) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

class function TEnumUtils.length<T>: Integer;
var
  FRType: TRttiType;
  FROrdinalType: TRttiOrdinalType;
begin
  FRType := TGenericUtils.rttiType<T>;
  if FRType.TypeKind = tkEnumeration then
  begin
    FROrdinalType := FRType.AsOrdinal;
    Result := FROrdinalType.MaxValue - FROrdinalType.MinValue + 1;
  end
  else
  begin
    raise TEnumException.Create(TGenericUtils.typeName<T>+' isn''t an Enum.');
  end;
end;

class function TEnumUtils.strToValue<T>(AEnum: String): T;
var
  I: Integer;
  FEnum: T;
begin
  Result := Default(T);
  for I := 0 to length<T> -1  do
  begin
    FEnum := TValue.FromOrdinal(TypeInfo(T), I).AsType<T>;
    if GetEnumName(TypeInfo(T), I) = AEnum then
      Result := FEnum;
  end;
end;

class function TEnumUtils.toList<T>: TArray<Variant>;
var
  I: Integer;
begin
  SetLength(Result, length<T>);
  for I := 0 to length<T> -1  do
    Result[I] := (GetEnumName(TypeInfo(T), I));
end;

end.
