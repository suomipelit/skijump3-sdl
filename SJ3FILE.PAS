Unit SJ3File;


interface

type TFileBaseName = string[8];
     TFileFullName = string[12];
     TErrorHandler = procedure(IORes: integer; filename: string);
     TFileMode = (FILEMODE_READ, FILEMODE_WRITE);

procedure SetErrorHandler(handler: TErrorHandler);
function FindFiles(pattern: string; var FileNames: array of TFileBaseName; excludeTemp: boolean): integer;
function FileExists(filename: TFileFullName): boolean;
function OpenFile(var f: file; filename: TFileFullName; mode: TFileMode; optional: boolean): boolean;
function OpenTextFile(var f: text; filename: TFileFullName; mode: TFileMode; optional: boolean): boolean;
function DeleteFile(var f: file; filename: TFileFullName): boolean;
function DeleteTextFile(var f: text; filename: TFileFullName): boolean;


implementation

uses SysUtils;

var ErrorHandler : TErrorHandler;

procedure SetErrorHandler(handler: TErrorHandler);
begin
 ErrorHandler:=handler;
end;

function FindFiles(pattern: string; var FileNames: array of TFileBaseName; excludeTemp: boolean): integer;
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

 FindFiles:=count;
end;

function FileExists(filename: TFileFullName): boolean;
begin
 FileExists:=SysUtils.FileExists(filename);
end;

function OpenFile(var f: file; filename: TFileFullName; mode: TFileMode; optional: boolean): boolean;
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
 OpenFile:=(result=0);
end;

function OpenTextFile(var f: text; filename: TFileFullName; mode: TFileMode; optional: boolean): boolean;
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
 OpenTextFile:=(result=0);
end;

function DeleteFile(var f: file; filename: TFileFullName): boolean;
var deleted: boolean;
begin
 deleted:=false;

 if (OpenFile(f, filename, FILEMODE_READ, true)) then
  begin
   Close(f);
   Erase(f);
   deleted:=true; { yep, deleted }
  end;

 DeleteFile:=deleted;
end;

function DeleteTextFile(var f: text; filename: TFileFullName): boolean;
var deleted: boolean;
begin
 deleted:=false;

 if (OpenTextFile(f, filename, FILEMODE_READ, true)) then
  begin
   Close(f);
   Erase(f);
   deleted:=true; { yep, deleted }
  end;

 DeleteTextFile:=deleted;
end;

end.
