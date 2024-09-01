unit UTimeUtils;

interface

type
  TTimeUtils = class
  public
    class function processTime(AAvarageTimeSec, ACount, ATotal: Extended): String;
  end;

implementation

uses
  SysUtils,
  JclStrings,
  Math;

{ TimeUtils }

class function TTimeUtils.processTime(AAvarageTimeSec, ACount, ATotal: Extended): String;
var
  FSec, FMin, FHour: String;
begin
  Result := '??:??:??';
  if (AAvarageTimeSec <> 0) or (ACount <> 0) then
  begin
    FSec := StrPadLeft((Trunc(AAvarageTimeSec*(ATotal - ACount))mod 60).ToString,2,'0');
    FMin := StrPadLeft((Trunc(AAvarageTimeSec*(ATotal - ACount)/60)mod 60).ToString,2,'0');
    FHour := StrPadLeft(Trunc((AAvarageTimeSec*(ATotal - ACount)/60)/60).ToString,2,'0');
    Result := FHour+':'+FMin+':'+FSec;
  end
end;

end.
