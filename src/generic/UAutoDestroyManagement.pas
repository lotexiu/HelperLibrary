unit UAutoDestroyManagement;

interface

uses
  Classes,
  UGenericDictionary,
  UAutoDestroy;

type
  TDataOnThreads<T> = record
  private
    FThreads: TArray<TThreadID>;
    FData: T;
  public
    property Threads: TArray<TThreadID> read FThreads write FThreads;
    property Data: T read FData write FData;
  end;


  TAutoDestroyManagement = class
  protected
    class var dataOnThreads: TGenericDictionary;
  private
  public
//    class procedure linkDataWithThread<T>(Data: RAD<T>);
//    class function canDestroy<T>(AID: String): Boolean;
  end;

implementation

uses
  UArrayUtils,
  UGenericUtils;

{ TAutoDestroyManagement }


initialization
  TAutoDestroyManagement.dataOnThreads := TGenericDictionary.Create;

end.
