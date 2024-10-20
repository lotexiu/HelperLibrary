unit UArray;

interface

uses
  Rtti,
  TypInfo,
  Generics.Collections,
  SysUtils,
  UArrayReferences;

type

  ESortBy = (
    E_OriginalOrder,
    E_Reverse,
    E_Pointer,
    E_Alphabet,
    E_CreationDate,
    E_AddtionDate,
    E_Custom
  );

  TArray<T> = class
  private
    FAvarage: Double;
    FEnableRegistry: Boolean;
    FDestroyItems: Boolean;
    FFirstAddedValue: T;
    FRegistry: TArray<String>;
    FArray: _array<T>;
    FLastAddedValue: T;
    function doPagination(ASize, APage: Integer): TArray<T>;
    function getCount: Integer;
    function getItem(AIndex: Integer): T;
    procedure setItem(AIndex: Integer; const Value: T);
//    function doPages(ASize: Integer): TArray<TArray<T>>;
  public

    property Item[AIndex: Integer]: T read getItem write setItem; default;
    property Count: Integer read getCount;
    property DestroyItems: Boolean read FDestroyItems write FDestroyItems;
    property &Array: _array<T> read FArray;
    property LastAddedValue: T read FLastAddedValue;
    property FirstAddedValue: T read FFirstAddedValue;

    property Pagination[ASize, APage: Integer]: TArray<T> read doPagination;

    property SizeAvarage: Double read FAvarage;
    {FAvarage := CurrentSize / TotalChanges}

    property Registry: TArray<String> read FRegistry;
    property EnableRegistry: Boolean read FEnableRegistry;



  end;

implementation

uses
  StrUtils,
  UGenericUtils,
  UArrayUtils,
  UThreadUtils,
  Classes;

{ TArray<T> }

function TArray<T>.doPagination(ASize, APage: Integer): TArray<T>;
begin

end;

function TArray<T>.getCount: Integer;
begin
  Result := Length(FArray);
end;

function TArray<T>.getItem(AIndex: Integer): T;
begin
  Result := FArray[AIndex];
end;

procedure TArray<T>.setItem(AIndex: Integer; const Value: T);
begin
  FArray[AIndex] := Value;
end;

end.

