Unit SJ3File;


interface

type TFileBaseName = string[8];
     TFileFullName = string[12];
     TFilePath = string;
     TFilePathArray = array of TFilePath;
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

uses Classes, SysUtils;

var ErrorHandler : TErrorHandler;

procedure SetErrorHandler(handler: TErrorHandler);
begin
 ErrorHandler:=handler;
end;

function FindFilesByPattern(pattern: string; paths: TFilePathArray; var FileNames: array of TFileBaseName; excludeTemp: boolean): integer;
var FileNameList: Classes.TStringList;
    FileName: string;
    DirInfo: SysUtils.TSearchRec;
    i, temp, count, maxCount: integer;
begin
 FileNameList:=Classes.TStringList.Create;
 FileNameList.Duplicates:=Classes.dupIgnore;
 FileNameList.Sorted:=true;
 FileNameList.CaseSensitive:=false;

 maxCount:=length(FileNames)-1;
 for temp:=0 to maxCount do FileNames[temp]:='';

 for i:=0 to Length(paths)-1 do
 begin
   if SysUtils.FindFirst(paths[i]+pattern,SysUtils.faAnyFile,DirInfo)=0 then
   begin
     repeat
       begin
         FileName:=SysUtils.ChangeFileExt(DirInfo.Name,'');

         if ((not excludeTemp) or (FileName <> 'TEMP')) then FileNameList.Add(FileName);
       end;
     Until SysUtils.FindNext(DirInfo)<>0;

     SysUtils.FindClose(DirInfo);
   end;
 end;

 count:=maxCount;
 if (FileNameList.Count<count) then count:=FileNameList.Count;

 for temp:=1 to count do FileNames[temp]:=FileNameList[temp-1];
 FileNameList.Free;

 FindFilesByPattern:=count;
end;

function FileExistsByPath(path: TFilePath): boolean;
begin
 FileExistsByPath:=SysUtils.FileExists(path);
end;

function OpenFileByPath(var f: file; path: TFilePath; mode: TFileMode; optional: boolean): boolean;
var result: word;
begin
 Assign(f,path);
 case mode of
   FILEMODE_READ:
     begin
       {$I-} Reset(f,1); {$I+}
       result:=IOResult;
       if ((not optional) and (result<>0)) then ErrorHandler(result,path);
     end;
   FILEMODE_WRITE:
     begin
       if (optional) then begin {$I-} Rewrite(f,1); {$I+} end else Rewrite(f,1);
       result:=IOResult;
     end;
 end;
 OpenFileByPath:=(result=0);
end;

function OpenTextFileByPath(var f: text; path: TFilePath; mode: TFileMode; optional: boolean): boolean;
var result: word;
begin
 Assign(f,path);
 case mode of
   FILEMODE_READ:
     begin
       {$I-} Reset(f); {$I+}
       result:=IOResult;
       if ((not optional) and (result<>0)) then ErrorHandler(result,path);
     end;
   FILEMODE_WRITE:
     begin
       if (optional) then begin {$I-} Rewrite(f); {$I+} end else Rewrite(f);
       result:=IOResult;
     end;
 end;
 OpenTextFileByPath:=(result=0);
end;

function DeleteFileByPath(var f: file; path: TFilePath): boolean;
var deleted: boolean;
begin
 deleted:=false;

 if (OpenFileByPath(f, path, FILEMODE_READ, true)) then
  begin
   Close(f);
   Erase(f);
   deleted:=true; { yep, deleted }
  end;

 DeleteFileByPath:=deleted;
end;

function DeleteTextFileByPath(var f: text; path: TFilePath): boolean;
var deleted: boolean;
begin
 deleted:=false;

 if (OpenTextFileByPath(f, path, FILEMODE_READ, true)) then
  begin
   Close(f);
   Erase(f);
   deleted:=true; { yep, deleted }
  end;

 DeleteTextFileByPath:=deleted;
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

procedure GetSearchPaths(fileType: TFileType; var paths: TFilePathArray);
var i: integer;
begin
  case fileType of
    FILETYPE_RESOURCE: begin; SetLength(paths, 2); paths[1]:='DATA'; end;
    FILETYPE_IMAGE: begin; SetLength(paths, 2); paths[1]:='IMAGES'; end;
    FILETYPE_FRONT, FILETYPE_BACK: begin; SetLength(paths, 3); paths[1]:='EXTRAS'; paths[2]:='IMAGES'; end;
    FILETYPE_CONFIG: begin; SetLength(paths, 2); paths[1]:='CONFIG'; end;
    FILETYPE_NAMES: begin; SetLength(paths, 2); paths[1]:='NAMES'; end;
    FILETYPE_REPLAY: begin; SetLength(paths, 2); paths[1]:='REPLAYS'; end;
    FILETYPE_CUSTOMSET: begin; SetLength(paths, 2); paths[1]:='CUSTOMS'; end;
    FILETYPE_EXTRAHILL: begin; SetLength(paths, 2); paths[1]:='EXTRAS'; end;
    FILETYPE_SENDME: SetLength(paths, 1);
  end;
  paths[0]:=''; { current working dir always first }
  for i:=1 to Length(paths)-1 do paths[i]:=paths[i]+DirectorySeparator;
end;

function GetDefaultPath(fileType: TFileType): TFilePath;
var paths: TFilePathArray;
begin
  GetSearchPaths(fileType, paths);
  GetDefaultPath:=paths[Length(paths)-1];
end;

function FindFiles(fileType: TFileType; var FileNames: array of TFileBaseName): integer;
var pattern: string;
    paths: TFilePathArray;
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

  GetSearchPaths(fileType, paths);

  excludeTemp:=(filetype=FILETYPE_CUSTOMSET);

  FindFiles:=FindFilesByPattern(pattern, paths, FileNames, excludeTemp);
end;

function FileExists(fileID: TFileID): boolean;
var name: TFileFullName;
    paths: TFilePathArray;
    path: TFilePath;
    found: boolean;
    i: integer;
begin
 name:=GetFileName(fileID);
 GetSearchPaths(fileID.fileType, paths);
 found:=false;
 for i:=0 to Length(paths)-1 do
 begin
  path:=paths[i]+name;
  found:=FileExistsByPath(path);
  if (found) then break;
 end;
 FileExists:=found;
end;

function OpenFile(var f: file; fileID: TFileID; mode: TFileMode; optional: boolean): boolean;
var name: TFileFullName;
    paths: TFilePathArray;
    path: TFilePath;
    success, found: boolean;
    i: integer;
begin
 name:=GetFileName(fileID);
 GetSearchPaths(fileID.fileType, paths);
 success:=false;
 found:=false;
 for i:=0 to Length(paths)-1 do
 begin
  path:=paths[i]+name;
  if (FileExistsByPath(path)) then
  begin
   found:=true;
   success:=OpenFileByPath(f,path,mode,optional);
   break;
  end;
 end;
 if (not found) then
 begin
  path:=GetDefaultPath(fileID.fileType)+name;
  success:=OpenFileByPath(f,path,mode,optional); { trigger read error or save to default location }
 end;
 OpenFile:=success;
end;

function OpenTextFile(var f: text; fileID: TFileID; mode: TFileMode; optional: boolean): boolean;
var name: TFileFullName;
    paths: TFilePathArray;
    path: TFilePath;
    success, found: boolean;
    i: integer;
begin
 name:=GetFileName(fileID);
 GetSearchPaths(fileID.fileType, paths);
 success:=false;
 found:=false;
 for i:=0 to Length(paths)-1 do
 begin
  path:=paths[i]+name;
  if (FileExistsByPath(path)) then
  begin
   found:=true;
   success:=OpenTextFileByPath(f,path,mode,optional);
   break;
  end;
 end;
 if (not found) then
 begin
  path:=GetDefaultPath(fileID.fileType)+name;
  success:=OpenTextFileByPath(f,path,mode,optional); { trigger read error or save to default location }
 end;
 OpenTextFile:=success;
end;

function DeleteFile(var f: file; fileID: TFileID): boolean;
var name: TFileFullName;
    paths: TFilePathArray;
    path: TFilePath;
    success: boolean;
    i: integer;
begin
 name:=GetFileName(fileID);
 GetSearchPaths(fileID.fileType, paths);
 success:=false;
 for i:=0 to Length(paths)-1 do
 begin
  path:=paths[i]+name;
  if (FileExistsByPath(path)) then
  begin
   success:=DeleteFileByPath(f,path);
   break;
  end;
 end;
 DeleteFile:=success;
end;

function DeleteTextFile(var f: text; fileID: TFileID): boolean;
var name: TFileFullName;
    paths: TFilePathArray;
    path: TFilePath;
    success: boolean;
    i: integer;
begin
 name:=GetFileName(fileID);
 GetSearchPaths(fileID.fileType, paths);
 success:=false;
 for i:=0 to Length(paths)-1 do
 begin
  path:=paths[i]+name;
  if (FileExistsByPath(path)) then
  begin
   success:=DeleteTextFileByPath(f,path);
   break;
  end;
 end;
 DeleteTextFile:=success;
end;

end.
