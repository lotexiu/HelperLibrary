library HelperLibraryDLL;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }

uses
  System.SysUtils,
  System.Classes,
  UGenericUtils in 'src\generic\UGenericUtils.pas',
  UGenericException in 'src\generic\UGenericException.pas',
  UDebugUtils in 'src\debug\UDebugUtils.pas',
  UArray in 'src\array\UArray.pas',
  UArrayUtils in 'src\array\UArrayUtils.pas',
  UArrayReferences in 'src\array\UArrayReferences.pas',
  UArrayException in 'src\array\UArrayException.pas',
  UThreadUtils in 'src\thread\UThreadUtils.pas',
  UThreadData in 'src\thread\UThreadData.pas',
  UGenericDictionary in 'src\generic\UGenericDictionary.pas',
  UWindowsUtils in 'src\windows\UWindowsUtils.pas',
  UNTDLL in 'src\ntdll\UNTDLL.pas',
  UFileUtils in 'src\file\UFileUtils.pas',
  UAttributesUtils in 'src\attributes\UAttributesUtils.pas',
  UConsoleUtils in 'src\console\UConsoleUtils.pas',
  UDateUtils in 'src\date\UDateUtils.pas',
  UEnum in 'src\enum\UEnum.pas',
  UEnumException in 'src\enum\UEnumException.pas',
  UEnumUtils in 'src\enum\UEnumUtils.pas',
  UJSONUtils in 'src\json\UJSONUtils.pas',
  UTimeUtils in 'src\time\UTimeUtils.pas',
  UJSONException in 'src\json\UJSONException.pas',
  UStringUtils in 'src\string\UStringUtils.pas',
  UApp in 'src\rest\UApp.pas',
  UAppAPI in 'src\rest\api\UAppAPI.pas',
  UAppAPIRequest in 'src\rest\api\UAppAPIRequest.pas';

{$R *.res}

begin
end.
