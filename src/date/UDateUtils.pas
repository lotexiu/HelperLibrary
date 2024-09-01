unit UDateUtils;

interface

type
  TDateUtils = class
  private
  public
    class function format(
      ADate: TDateTime;
      AFormat: String = 'dd/mm/yyyy hh:nn:ss';
      AIncList: TArray<Integer> = []): String; overload;
    class function format(
      ADate: TDateTime;
      AIncList: TArray<Integer>): String; overload;
    class function inc(
      ADate: TDateTime;
      AYear: Integer = 0; AMonth: Integer = 0; AWeek: Integer = 0;
      ADay: Integer = 0; AHour: Integer = 0; AMinute: Integer = 0;
      ASecond: Integer = 0; AMilliSecond: Integer = 0): TDateTime;
  end;

implementation

uses
  SysUtils,
  DateUtils,
  UGenericUtils;

{ TDateUtils }
class function TDateUtils.format(ADate: TDateTime; AFormat: String;
  AIncList: TArray<Integer>): String;
var
  FYear, FMonth, FWeek, FDay,
  FHour, FMinute, FSecond, FMilliSecond: Integer;
begin
  SetLength(AIncList, 8);
  FYear := AIncList[0];
  FMonth := AIncList[1];
  FWeek := AIncList[2];
  FDay := AIncList[3];
  FHour := AIncList[4];
  FMinute := AIncList[5];
  FSecond := AIncList[6];
  FMilliSecond := AIncList[7];
  Result := FormatDateTime(AFormat, inc(ADate,FYear,FMonth,FWeek,FDay,FHour,FMinute,FSecond,FMilliSecond));
end;

class function TDateUtils.format(ADate: TDateTime;
  AIncList: TArray<Integer>): String;
begin
  Result := format(ADate, 'dd/mm/yyyy hh:nn:ss', AIncList);
end;

class function TDateUtils.inc(ADate: TDateTime;
      AYear: Integer = 0; AMonth: Integer = 0; AWeek: Integer = 0;
      ADay: Integer = 0; AHour: Integer = 0; AMinute: Integer = 0;
      ASecond: Integer = 0; AMilliSecond: Integer = 0): TDateTime;
begin
  Result := IncMonth
    (IncMilliSecond(IncSecond(IncMinute(IncHour(IncDay(IncWeek(IncYear(ADate,
    AYear), AWeek), ADay), AHour), AMinute), ASecond), AMilliSecond), AMonth)
end;

end.
