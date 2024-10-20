program getPaths;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Classes,
  IOUtils,
  StrUtils;

procedure GeneratePathsFile(const FolderPath: string);
var
  PathsFile: TextFile;
  Directory: string;
  DirectoriesList: TStringList;
begin
  DirectoriesList := TStringList.Create;
  try
    { Get Paths }
    DirectoriesList.AddStrings(TDirectory.GetDirectories(FolderPath, '*', TSearchOption.soAllDirectories));
    { Create paths.txt file }
    AssignFile(PathsFile, FolderPath + PathDelim + 'paths.txt');
    Rewrite(PathsFile);

    { Paths }
    for Directory in DirectoriesList do
    begin
      { Ignore hidden Paths and .Paths }
      if ((faHidden and FileGetAttr(Directory)) = 0) and (not ContainsText(Directory,'\.')) then
        Writeln(PathsFile, Directory);
    end;
    { Close File }
    CloseFile(PathsFile);
  finally
    DirectoriesList.Free;
  end;
end;

begin
  try
    GeneratePathsFile(ExtractFilePath(ParamStr(0)));
    Writeln('paths.txt generated successfully with directories only.');
  except
    on E: Exception do
      Writeln('An error occurred: ', E.Message);
  end;
  sleep(5*1000);
end.
