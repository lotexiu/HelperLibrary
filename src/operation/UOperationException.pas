unit UOperationException;

interface

uses
  SysUtils;

type
  TOperationException = class(Exception)
  public
    constructor Create(const Msg: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
  end;

implementation

constructor TOperationException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

constructor TOperationException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
end;

end.

