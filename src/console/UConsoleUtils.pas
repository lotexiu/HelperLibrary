unit UConsoleUtils;

interface

type
  TConsoleUtils = class
  public
    class procedure resize(AWidth: Integer; AOnlyBuffer: Boolean = False); overload;
    class procedure resize(AWidth, AHeight: Integer; AOnlyBuffer: Boolean = False); overload;
  end;

implementation

uses
  Windows,
  Classes,
  Math;

{ TConsoleUtils }

class procedure TConsoleUtils.resize(AWidth, AHeight: Integer; AOnlyBuffer: Boolean = False);
var
  Rect: TSmallRect;
  Coord: TCoord;
begin
  Rect.Left := 1;
  Rect.Top := 1;
  Rect.Right := Math.Max(AWidth,80);
  Rect.Bottom := Math.Max(AHeight,25);
  Coord.X := Rect.Right + 1 - Rect.Left;
  Coord.y := Rect.Bottom + 1 - Rect.Top;
  SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
  if (not AOnlyBuffer) then
    SetConsoleWindowInfo(GetStdHandle(STD_OUTPUT_HANDLE), True, Rect);
  writeln('');
end;

class procedure TConsoleUtils.resize(AWidth: Integer; AOnlyBuffer: Boolean = False);
begin
  resize(AWidth, 28);
  resize(AWidth, 50, True);
end;

end.
