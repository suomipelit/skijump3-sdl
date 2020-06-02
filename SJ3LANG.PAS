Unit sj3lang;

Interface

{ procedure ResetLanguage; }
procedure Init;
procedure LoadLanguage(languageindex:byte);
function lrstr(start,stop:integer):string;
function lnstr(index:integer):string;
function lstr(index:integer):string;
function lch(index,num:integer):char;

var numlanguages : byte;
    lnames : array [0..25] of string[20];

Implementation

uses {crt,}sj3help;

const NumStr = 599;

type LangStr = string[59];

var plstr : array [0..NumStr] of ^LangStr;


function lstr(index:integer):string;
begin

 if (index>=0) and (index<=numstr) then lstr:=plstr[index]^;

end;


function lch(index,num:integer):char;
var str1 : string;
begin

 str1:=lstr(index);
 lch:=str1[num];

end;


function lrstr(start,stop:integer):string;
begin

 lrstr:=lstr(start+random(stop-start+1));

end;

function lnstr(index:integer):string;
var temp : integer;
begin

 temp:=index;

 while (lstr(temp)='?') and (temp<index+10) do inc(temp);

 lnstr:=lstr(temp);

end;

procedure ResetLanguage;
var f1 : text;
    temp : integer;
    str1 : string;
    out : boolean;
begin

 assign(f1,'LANGBASE.SKI');
 {$I-}
 reset(f1);
 {$I+}
 FileOK(IOResult,'LANGBASE.SKI');

 numlanguages:=0;

 out:=false;

  repeat

   if (eof(f1)) then out:=true
                else readln(f1,str1);
   if (length(str1) > 0) and (str1[1]='*') then
    begin
     inc(numlanguages);
     readln(f1,str1);
     lnames[numlanguages]:=str1;
    end;

  until (out);

 close(f1);

end;

procedure LoadLanguage(languageindex:byte);
var f1 : text;
    code, index, temp : integer;
    first, out : boolean;
    str1, str2 : string;

begin

 for temp:=0 to NumStr do plstr[temp]^:='?';

 assign(f1,'langbase.ski');
 reset(f1);

 out:=false;
 index:=0;

 repeat

  if (eof(f1)) then out:=true
               else readln(f1,str1);

  if (length(str1) > 0) and (str1[1]='*') and (str1[2] = chr(languageindex+64)) then
   begin { oikea kieli l”ytyi! }
    index:=1;
    out:=true;
   end;

 until (out);

 out:=false;

 if (index>0) then { kunhan oikea kieli on l”ytyynty. }
  repeat

   if (eof(f1)) then out:=true
                else readln(f1,str1);


   if (length(str1) > 0) and (str1[1]='*') then out:=true;  { kiitti, riitt„„ }

   if (not out) then
    begin

     index:=0;
     first:=true;

     for temp:=1 to length(str1) do
      begin

       if (index>0) then plstr[index]^:=plstr[index]^+str1[temp];

       if (str1[temp]=':') and (first) then
        begin
         first:=false;
         val(copy(str1,1,temp-1),index,code);
         if (code<>0) then index:=0;
         if (index>0) then plstr[index]^:=''; { putsaa stringin }
        end;

      end;

   end;

  until (out);

 close(f1);

end;


procedure NewLangs;
var temp : integer;
begin

 for temp:=0 to NumStr do New(plstr[temp]);

end;

procedure Init;
begin
 NewLangs;
 ResetLanguage;
end;

end.
