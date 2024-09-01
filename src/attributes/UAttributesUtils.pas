unit UAttributesUtils;

interface

uses
  Rtti,
  SysUtils;

type
  TAttributesUtils = class

    class function attributes<T>: TArray<TCustomAttribute>; overload;
    class function attributes<T>(
      AAttributeType: TClass;
      AFrom: TClass = nil;
      AName: String = '';
      AParamsTypeList: TArray<String> = []
    ): TArray<TCustomAttribute>; overload;

    class function attributes<T; AttributeType: class>: TArray<AttributeType>; overload;
    class function attributes<T; AttributeType: class>(
      AFrom: TClass;
      AName: String = '';
      AParamsTypeList: TArray<String> = []
    ): TArray<AttributeType>; overload;

    class function getAttributes(
      ARType: TRttiType;
      AAttributeType: TClass = nil;
      AFrom: TClass = nil;
      AName: String = '';
      AParamsTypeList: TArray<String> = []
    ): TArray<TCustomAttribute>; overload;

    class function attributesFromAMethod(
      ARType: TRttiType;
      AFrom: TClass;
      AName: String = '';
      AType: String = ''
    ): TArray<TCustomAttribute>;
  end;

implementation

uses
  UGenericUtils,
  UArrayUtils;

{ TAttributesUtils }

class function TAttributesUtils.attributes<T, AttributeType>: TArray<AttributeType>;
begin
  Result := TArray<AttributeType>(attributes<T>(
    TGenericUtils.tclassOf<AttributeType>
  ));
end;

class function TAttributesUtils.attributes<T, AttributeType>(AFrom: TClass;
  AName: String; AParamsTypeList: TArray<String>): TArray<AttributeType>;
begin
  Result := TArray<AttributeType>(attributes<T>(
    TGenericUtils.tclassOf<AttributeType>,
    AFrom, AName, AParamsTypeList
  ));
end;

class function TAttributesUtils.attributes<T>: TArray<TCustomAttribute>;
begin
  Result := attributes<T>(nil);
end;

class function TAttributesUtils.attributes<T>(AAttributeType, AFrom: TClass;
  AName: String; AParamsTypeList: TArray<String>): TArray<TCustomAttribute>;
var
  FTRttiType: TRttiType;
begin
  FTRttiType := TGenericUtils.rttiType<T>;
  Result := getAttributes(FTRttiType,AAttributeType,AFrom,AName,AParamsTypeList);
end;

class function TAttributesUtils.attributesFromAMethod(ARType: TRttiType; AFrom: TClass; AName: String = '';
  AType: String = ''): TArray<TCustomAttribute>;
var
  FRMethod: TRttiMethod;
  FRParameter: TRttiParameter;
begin
  for FRMethod in ARType.GetMethods(AName) do
  begin
    if AFrom = TRttiMethod then
      Result := FRMethod.getAttributes
    else if AFrom = TRttiParameter then
    begin
      if (AName = '') or (AType = '') then
        raise Exception.Create
          ('Campo AName e AType é necessário para buscar attributos de parâmetro.')
      else
        for FRParameter in FRMethod.GetParameters do
        begin
          if (FRParameter.Name = AName) and (FRParameter.ParamType.Name = AType)
          then
            Result := FRParameter.getAttributes;
        end;
    end;
  end;
end;

class function TAttributesUtils.getAttributes(ARType: TRttiType; AAttributeType,
  AFrom: TClass; AName: String;
  AParamsTypeList: TArray<String>): TArray<TCustomAttribute>;
var
  FTRttiType: TRttiType;
  FResult: TArray<TCustomAttribute>;
  FRMethod: TRttiMethod;
  FStringList: TArray<String>;
begin
  FTRttiType := ARType;

  FResult := FTRttiType.GetAttributes;
  if (not TGenericUtils.isEmptyOrNull(AFrom)) then
  begin
    FResult := nil;
    if AFrom = TRttiMethod then
    begin
      if (Length(FTRttiType.GetMethods(AName)) > 1) then
      begin
        for FRMethod in FTRttiType.GetMethods(AName) do
        begin
          if Length(FRMethod.GetParameters) = Length(AParamsTypeList) then
          begin
            FStringList := TArrayUtils.map<TRttiParameter, String>(FRMethod.GetParameters,
              function(AValue: TRttiParameter): String
              begin
                Result := AValue.ParamType.Name;
              end);
            if String.Join(',', FStringList) = String.Join(',', AParamsTypeList)
            then
            begin
              FResult := FRMethod.getAttributes;
              Break;
            end;
          end;
        end;
        if FResult = nil then
          raise Exception.Create('Fail to find '+AName+' method with the specified parameters!');
      end
      else
        FResult := FTRttiType.GetMethod(AName).getAttributes;
    end
    else if AFrom = TRttiField then
      FResult := FTRttiType.GetField(AName).getAttributes
    else if AFrom = TRttiProperty then
      FResult := FTRttiType.GetProperty(AName).getAttributes
    else if AFrom = TRttiIndexedProperty then
      FResult := FTRttiType.GetIndexedProperty(AName).getAttributes
    else
      raise Exception.Create(
        AFrom.ClassName+' not supported! Use another attributes function.'
      );
  end;

  Result := FResult;
  if Assigned(AAttributeType) then
  begin
    Result := TArrayUtils.map<TCustomAttribute>(FResult,
      function(AValue: TCustomAttribute): TCustomAttribute
      begin
        if AValue is AAttributeType then
          Result := AValue
        else
          Result := nil;
      end);
  end
end;

end.
