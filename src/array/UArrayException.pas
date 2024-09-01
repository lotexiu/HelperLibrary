unit UArrayException;

interface

uses
  SysUtils;

type
  TArrayException = class(Exception)
  public
    constructor Create(const Msg: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
  end;

implementation

constructor TArrayException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

constructor TArrayException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
end;

end.

