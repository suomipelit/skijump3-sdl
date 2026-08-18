Unit SJ3File;


interface

type TFileBaseName = string[8];
     TFileFullName = string[12];
     TErrorHandler = procedure(IORes: integer; filename: string);
     TFileMode = (FILEMODE_READ, FILEMODE_WRITE);

     TImageIndex = string[3];
     TNameNumber = char;
     TFileType = (FILETYPE_RESOURCE, FILETYPE_IMAGE, FILETYPE_FRONT, FILETYPE_BACK, FILETYPE_CONFIG, FILETYPE_NAMES,
                  FILETYPE_REPLAY, FILETYPE_CUSTOMSET, FILETYPE_EXTRAHILL, FILETYPE_SENDME);
     TFileResourceID = (FILERESOURCE_ANIM, FILERESOURCE_LANGUAGES, FILERESOURCE_HILLBASE);
     TFileImageID = (FILEIMAGE_MAIN, FILEIMAGE_LOAD);
     TFileConfigID = (FILECONFIG_CONFIG, FILECONFIG_RECORDS, FILECONFIG_GOALS, FILECONFIG_PROFILES, FILECONFIG_MOREHILL);
     TFileSendmeID = (FILESENDME_SENDME, FILESENDME_CUSTOMS, FILESENDME_EXTRAS);
     TFileID = record
       case fileType: TFileType of
         FILETYPE_RESOURCE: ( resourceId: TFileResourceID; );
         FILETYPE_IMAGE: ( imageId: TFileImageID; );
         FILETYPE_FRONT, FILETYPE_BACK: ( imageIndex: TImageIndex; );
         FILETYPE_CONFIG: ( configId: TFileConfigID; );
         FILETYPE_NAMES: ( nameNumber: TNameNumber; );
         FILETYPE_REPLAY, FILETYPE_CUSTOMSET, FILETYPE_EXTRAHILL: ( fileName: TFileBaseName; );
         FILETYPE_SENDME: ( sendmeId: TFileSendmeID; );
     end;

procedure SetErrorHandler(handler: TErrorHandler);
function GetFileName(fileID: TFileID): TFileFullName;
function FindFiles(fileType: TFileType; var FileNames: array of TFileBaseName): integer;
function FileExists(fileID: TFileID): boolean;
function OpenFile(var f: file; fileID: TFileID; mode: TFileMode; optional: boolean): boolean;
function OpenTextFile(var f: text; fileID: TFileID; mode: TFileMode; optional: boolean): boolean;
function DeleteFile(var f: file; fileID: TFileID): boolean;
function DeleteTextFile(var f: text; fileID: TFileID): boolean;


implementation

uses SysUtils;

var ErrorHandler : TErrorHandler;

procedure SetErrorHandler(handler: TErrorHandler);
begin
 ErrorHandler:=handler;
end;

function FindFilesByPattern(pattern: string; var FileNames: array of TFileBaseName; excludeTemp: boolean): integer;
var DirInfo: SysUtils.TSearchRec;
    temp, count, maxCount: integer;
begin
 count:=0;
 maxCount:=length(FileNames)-1;
 for temp:=0 to maxCount do FileNames[temp]:='';

 if SysUtils.FindFirst(pattern,SysUtils.faAnyFile,DirInfo)=0 then
 begin
   repeat
     if (count < maxCount) then
     begin
       inc(count);

       FileNames[count]:=SysUtils.ChangeFileExt(DirInfo.Name,'');

       if ((excludeTemp) and (FileNames[count] = 'TEMP')) then
       begin
         FileNames[count]:='';
         dec(count);
       end;
     end;
   Until SysUtils.FindNext(DirInfo)<>0;

   SysUtils.FindClose(DirInfo);
 end;

 FindFilesByPattern:=count;
end;

function FileExistsByName(filename: TFileFullName): boolean;
begin
 FileExistsByName:=SysUtils.FileExists(filename);
end;

function OpenFileByName(var f: file; filename: TFileFullName; mode: TFileMode; optional: boolean): boolean;
var result: word;
begin
 Assign(f,filename);
 case mode of
   FILEMODE_READ:
     begin
       {$I-} Reset(f,1); {$I+}
       result:=IOResult;
       if ((not optional) and (result<>0)) then ErrorHandler(result,filename);
     end;
   FILEMODE_WRITE:
     begin
       if (optional) then begin {$I-} Rewrite(f,1); {$I+} end else Rewrite(f,1);
       result:=IOResult;
     end;
 end;
 OpenFileByName:=(result=0);
end;

function OpenTextFileByName(var f: text; filename: TFileFullName; mode: TFileMode; optional: boolean): boolean;
var result: word;
begin
 Assign(f,filename);
 case mode of
   FILEMODE_READ:
     begin
       {$I-} Reset(f); {$I+}
       result:=IOResult;
       if ((not optional) and (result<>0)) then ErrorHandler(result,filename);
     end;
   FILEMODE_WRITE:
     begin
       if (optional) then begin {$I-} Rewrite(f); {$I+} end else Rewrite(f);
       result:=IOResult;
     end;
 end;
 OpenTextFileByName:=(result=0);
end;

function DeleteFileByName(var f: file; filename: TFileFullName): boolean;
var deleted: boolean;
begin
 deleted:=false;

 if (OpenFileByName(f, filename, FILEMODE_READ, true)) then
  begin
   Close(f);
   Erase(f);
   deleted:=true; { yep, deleted }
  end;

 DeleteFileByName:=deleted;
end;

function DeleteTextFileByName(var f: text; filename: TFileFullName): boolean;
var deleted: boolean;
begin
 deleted:=false;

 if (OpenTextFileByName(f, filename, FILEMODE_READ, true)) then
  begin
   Close(f);
   Erase(f);
   deleted:=true; { yep, deleted }
  end;

 DeleteTextFileByName:=deleted;
end;

function GetFileName(fileID: TFileID): TFileFullName;
begin
  case fileID.fileType of
    FILETYPE_RESOURCE:
      case fileID.resourceId of
        FILERESOURCE_ANIM: GetFileName := 'ANIM.SKI';
        FILERESOURCE_LANGUAGES: GetFileName := 'LANGBASE.SKI';
        FILERESOURCE_HILLBASE: GetFileName := 'HILLBASE.SKI';
      end;
    FILETYPE_IMAGE:
      case fileID.imageId of
        FILEIMAGE_MAIN: GetFileName := 'MAIN.PCX';
        FILEIMAGE_LOAD: GetFileName := 'LOAD.PCX';
      end;
    FILETYPE_FRONT:
      GetFileName := 'FRONT'+fileID.imageIndex+'.PCX';
    FILETYPE_BACK:
      GetFileName := 'BACK'+fileID.imageIndex+'.PCX';
    FILETYPE_CONFIG:
      case fileID.configId of
        FILECONFIG_CONFIG: GetFileName := 'CONFIG.SKI';
        FILECONFIG_RECORDS: GetFileName := 'HISCORE.SKI';
        FILECONFIG_GOALS: GetFileName := 'GOALS.SKI';
        FILECONFIG_PROFILES: GetFileName := 'PLAYERS.SKI';
        FILECONFIG_MOREHILL: GetFileName := 'MOREHILL.SKI';
      end;
    FILETYPE_NAMES:
      GetFileName := 'NAMES'+fileID.nameNumber+'.SKI';
    FILETYPE_REPLAY:
      GetFileName := fileID.fileName+'.SJR';
    FILETYPE_CUSTOMSET:
      GetFileName := fileID.fileName+'.SJC';
    FILETYPE_EXTRAHILL:
      GetFileName := fileID.fileName+'.SJH';
    FILETYPE_SENDME:
      case fileID.sendmeId of
        FILESENDME_SENDME: GetFileName := 'SENDME.TXT';
        FILESENDME_CUSTOMS: GetFileName := 'CUSTOMS.TXT';
        FILESENDME_EXTRAS: GetFileName := 'EXTRAS.TXT';
      end;
  end;
end;

function FindFiles(fileType: TFileType; var FileNames: array of TFileBaseName): integer;
var pattern: string;
    excludeTemp: boolean;
begin
  case fileType of
    FILETYPE_FRONT: pattern:='FRONT*.PCX';
    FILETYPE_BACK: pattern:='BACK*.PCX';
    FILETYPE_NAMES: pattern:='NAMES?.SKI';
    FILETYPE_REPLAY: pattern:='*.SJR';
    FILETYPE_CUSTOMSET: pattern:='*.SJC';
    FILETYPE_EXTRAHILL: pattern:='*.SJH';
  end;

  excludeTemp:=(filetype=FILETYPE_CUSTOMSET);

  FindFiles:=FindFilesByPattern(pattern, FileNames, excludeTemp);
end;

function FileExists(fileID: TFileID): boolean;
begin
 FileExists:=FileExistsByName(GetFileName(fileID));
end;

function OpenFile(var f: file; fileID: TFileID; mode: TFileMode; optional: boolean): boolean;
begin
 OpenFile:=OpenFileByName(f,GetFileName(fileID),mode,optional);
end;

function OpenTextFile(var f: text; fileID: TFileID; mode: TFileMode; optional: boolean): boolean;
begin
 OpenTextFile:=OpenTextFileByName(f,GetFileName(fileID),mode,optional);
end;

function DeleteFile(var f: file; fileID: TFileID): boolean;
begin
 DeleteFile:=DeleteFileByName(f,GetFileName(fileID));
end;

function DeleteTextFile(var f: text; fileID: TFileID): boolean;
begin
 DeleteTextFile:=DeleteTextFileByName(f,GetFileName(fileID));
end;

end.
