unit UConsoleUtils;

interface

type

  TConsoleView = (Show, Hide);

  TConsoleUtils = class
  public
    class procedure resize(AWidth: Integer; AOnlyBuffer: Boolean = False); overload;
    class procedure resize(AWidth, AHeight: Integer; AOnlyBuffer: Boolean = False); overload;
    class procedure console(AOption: TConsoleView);
    class procedure cleanScreen;
  end;

implementation

uses
  Winapi.Windows,
  SysUtils,
  Classes,
  Math;

{ TConsoleUtils }

class procedure TConsoleUtils.cleanScreen;
const
  FMaxBlankLines = 10;  { Maximum number of blank lines to consider for cleanup }
  FMaxLines = 10;      { Maximum number of lines to process in a block }
var
  FHConsole: THandle;
  FScreenBuffer: TConsoleScreenBufferInfo;
  FSize, FDefaultSize, FDifference: Integer;
  FParts, FPart: Integer;
  FOrigin: TCoord;
  NumWritten: DWORD;
  LineBuffer: array of Char;
  FLastChar, FChar: Integer;
begin
  { Get the console handle }
  FHConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(FHConsole <> INVALID_HANDLE_VALUE);
  { Get information about the console screen buffer }
  Win32Check(GetConsoleScreenBufferInfo(FHConsole, FScreenBuffer));
  { Initialize variables }
  FOrigin.X := 0;
  FDifference := FScreenBuffer.dwSize.Y mod FMaxLines;  { Calculate the difference for final adjustment }
  FDefaultSize := FScreenBuffer.dwSize.X * FMaxLines;  { Default size of the read buffer }
  FParts := (FScreenBuffer.dwSize.Y - FDifference) div FMaxLines; { Number of line blocks }
  { Loop to process each block of lines }
  for FPart := 0 to FParts - 1 do
  begin
    FSize := FDefaultSize;
    { Adjust size for the last block }
    if FPart = (FParts - 1) then
      FSize := FSize + FDifference;
    { Prepare the line buffer }
    SetLength(LineBuffer, FSize);
    FOrigin.Y := FPart * FMaxLines;
    { Read the console output }
    Win32Check(ReadConsoleOutputCharacter(
      FHConsole, @LineBuffer[0], FSize, FOrigin, NumWritten));
    { Find the last non-blank character }
    FLastChar := 0;
    for FChar := 0 to FSize - 1 do
    begin
      if LineBuffer[FChar] <> ' ' then
        FLastChar := FChar;
    end;
    { Check if there are enough blank lines to stop the loop }
    if (FMaxLines - (FLastChar div FScreenBuffer.dwSize.X) >= FMaxBlankLines) then
      Break;
  end;
  { Set the origin position for cleanup }
  FOrigin.Y := 0;
  FSize := FScreenBuffer.dwSize.X * ((FPart+1) * FMaxLines);
  { Adjust size if no non-blank characters were found }
  if FLastChar = 0 then
    FSize := FScreenBuffer.dwSize.X * (FPart * FMaxLines);
  { Fill the console with spaces }
  Win32Check(FillConsoleOutputCharacter(
    FHConsole,
    ' ',
    FSize,
    FOrigin,
    NumWritten));
  { Fill the console with the current text attribute }
  Win32Check(FillConsoleOutputAttribute(
    FHConsole,
    FScreenBuffer.wAttributes,
    FSize,
    FOrigin,
    NumWritten));
  { Set the cursor position to the beginning }
  Win32Check(SetConsoleCursorPosition(FHConsole, FOrigin));
end;

class procedure TConsoleUtils.console(AOption: TConsoleView);
begin
  case AOption of
    Show: ShowWindow(GetConsoleWindow, SW_HIDE);
    Hide: ShowWindow(GetConsoleWindow, SW_SHOW);
  end;
end;

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
