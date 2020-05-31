Unit SJ3HELP; { SJ3:n apufunktioita, ei graafisia }

interface

var ch, ch2 : char; { nÑppisglobaalit }

procedure beep(beeptapa:byte);
function round(r:single):longint;

function nsqrt(x:single):single;
procedure putsaa;
procedure clearchs;
procedure waitforkey;
function waitforkey2:boolean;

procedure cwrite(col:byte;str1:string);
procedure cwriteln(col:byte;str1:string);

procedure dowindow(x1,y1,x2,y2,col:integer);

procedure Fileok(IORes:integer;filename:string);

function pcomp(score,sij:longint):longint;

function sh(str1:string;maxpituus:byte):string;
function nsh(str1:string;maxpituus:integer):string;

function paraletter(str1:string):char;

function txtp(jokuluku:longint):string;
function txt(jokuluku:longint):string;
function num(jokustr:string):longint;
function upstr(str1:string):string;
function nmstr(str1:string):string;
function toansi(str1:string):string;

implementation

uses maki, sj3unit, crt, dos, sj3graph;

procedure Wait(C : integer) ;
   var   T : byte ;
       Tkr : byte absolute $40:$6C ;
   begin
    repeat
     T := Tkr;
     repeat until T<>Tkr;
     Dec(C);
    until (C<=0);
end {Wait} ;


function round(r:single):longint;
var l : longint;
begin
 l := trunc(r);
 if (frac(r) >= 0.5) then inc(l);
 if (frac(r) <= -0.5) then dec(l);

 round := l;

end;



procedure beep(beeptapa:byte);
var t1, t2 : Time;
begin
(*
 sound(1000*beeptapa);
 delay(15);
 NoSound;
*)

(* ok - kotitekoinen
 sound(1000*beeptapa);
 GetTime(t1.Hour,t1.Minute,t1.Second,t1.Sec100);
 t2:=t1;

 repeat
  GetTime(t1.Hour,t1.Minute,t1.Second,t1.Sec100);

 until (t1.Sec100 <> t2.Sec100);

 NoSound;
*)

 sound(1000*beeptapa);
 wait(2);
 NoSound;


end;

function HexW(W: word): string; {Word}
   const
     HexChars: array [0..$F] of Char = '0123456789ABCDEF';
   begin
     HexW :=
       HexChars[(W and $F000) shr 12] +
       HexChars[(W and $0F00) shr 8]  +
       HexChars[(W and $00F0) shr 4]  +
       HexChars[(W and $000F)];
    end;

function nsqrt(x:single):single;
var temp : single;
begin

 temp:=sqrt(abs(x));

 if (x<0) then temp:=-temp;

 nsqrt:=temp;

end;


procedure putsaa;
{var ch : char; }
 begin
  while keypressed do readkbd(ch,ch2);
 end;

procedure clearchs;
 begin
  ch:=#1; ch2:=#1;
 end;

procedure waitforkey;
{var ch : char; }
begin
 putsaa;
 readkbd(ch,ch2);
end;

Function waitforkey2:boolean;
var tempboole : boolean;
{    ch2 : char; }
begin

 putsaa;

 tempboole:=false;

 readkbd(ch,ch2);

 if (ch=#0) and (ch2=#68) then tempboole:=true;

 waitforkey2:=tempboole;

end;


procedure cwrite(col:byte;str1:string);
begin
 textcolor(col);
 write(str1);
end;

procedure cwriteln(col:byte;str1:string);
begin
 textcolor(col);
 writeln(str1);
end;


procedure dowindow(x1,y1,x2,y2,col:integer);
begin
 window(x1,y1,x2,y2);
  textbackground(col);
   clrscr;
end;

function pcomp(score,sij:longint):longint;
var temp : longint;
begin
 pcomp:=(score*51)+50-sij;
{ pcomp:=score*51; }
end;


function plusstr(points:integer):integer;
begin
 plusstr:=length(txtp(points))*6;
end;



Function sh(str1:string;maxpituus:byte):string;
var temp1,temp2 : byte;
var str2 : string;
begin

 str2:='';
 temp2 := length(str1);

 if (temp2>maxpituus) then
  begin
   for temp1:=2 to temp2-1 do
    if (str1[temp1]=' ') and (str1[temp1+1]<>' ') then
      begin
       str2:=str1[1]+'.'+copy(str1,temp1,temp2-temp1+1);
       if (length(str2)<=maxpituus) then begin sh:=str2; exit; end;
      end;

   if str2='' then str2:=str1;

    temp1:=length(str2);

   if (temp1>maxpituus) then
    str2:=copy(str2,1,maxpituus-1)+'.';

  end else str2:=str1;

 sh:=str2;

end;




function nsh(str1:string;maxpituus:integer):string;
var temp1,temp2, temp3 : integer;
var str2 : string;
begin

 str2:='';
 temp2 := fontlen(str1);
 temp3 := length(str1);

 if (temp2>maxpituus) then
  begin

   for temp1:=2 to temp3-1 do
    if (str1[temp1]=' ') and (str1[temp1+1]<>' ') then
      begin
       str2:=str1[1]+'.'+copy(str1,temp1,temp3-temp1+1);
       if (fontlen(str2) <= maxpituus) then begin nsh:=str2; exit; end;
      end;

   if (str2='') then str2:=str1;

    temp1:=fontlen(str2);
    temp3:=length(str2);

   if (temp1>maxpituus) then
    while (fontlen(str2) > maxpituus) do
     begin
      dec(temp3);
      str2:=copy(str2,1,temp3)+'.';
     end;

  end else str2:=str1;

 nsh:=str2;

end;

function paraletter(str1:string):char;
var tempch : char;
    temp : integer;
begin

 tempch:=#0;
 temp:=1;

 while (str1[temp]<>')') and (temp<length(str1)) do inc(temp);

 if (temp>1) then tempch:=str1[temp-1];

 paraletter:=tempch;

end;



Procedure savescreen(str1:string);
var f1 : text;
    temp : integer;
 begin
  assign(f1,str1);

 ReWrite(f1);

  for temp:=0 to 1999 do
   begin
    if temp mod 80 = 0 then writeln(f1);

    write(f1,chr(mem[$b800:temp*2]));

   end;


 Close(f1);

 end;

Function txtp(jokuluku:longint):string;
var str1 : string;
begin
 str(abs(jokuluku),str1);
 insert('.',str1,length(str1));

 if (length(str1)<3) then str1:='0'+str1;

 if (jokuluku<0) then str1:='-'+str1;

 if (jokuluku<>0) then txtp:=str1 else txtp:='0.0';
end;

Function txt(jokuluku:longint):string;
var str1 : string;
begin
 str(jokuluku,str1);
 if (jokuluku<>0) then txt:=str1 else txt:='0';
end;

Function num(jokustr:string):longint;
var temp : longint;
    code : integer;
begin

 val(jokustr,temp,code);
 if (code>0) then temp:=-1;

 num:=temp;

end;

procedure Fileok(IORes:integer;filename:string);
begin

 if (IORes<>0) then
  begin
   AsetaMoodi($3);
   Writeln('SJ3 error:  Can''t find file ',filename,'.  Where have you put it? ');
   Readln;
   Halt;
  end;

end;


function upstr(str1:string):string;
var outstr : string;
    index  : integer;
begin

 outstr:=str1;

 for index:=1 to length(outstr) do
  begin
   outstr[index]:=upcase(outstr[index]);

   case outstr[index] of
   'Ü' : outstr[index]:='è';
   'Ñ' : outstr[index]:='é';
   'î' : outstr[index]:='ô';
   'Å' : outstr[index]:='ö';
   'õ' : outstr[index]:='ù';
   'ë' : outstr[index]:='í';
   end;

  end;

 upstr:=outstr;

end;

function toansi(str1:string):string;
var outstr : string;
    index  : integer;
begin

 outstr:=str1;

 for index:=1 to length(outstr) do
  begin
   case outstr[index] of
   'è' : outstr[index]:='¬';
   'é' : outstr[index]:='ƒ';
   'ô' : outstr[index]:='÷';
   'ö' : outstr[index]:='‹';
   'ù' : outstr[index]:='ÿ';
   'í' : outstr[index]:='∆';
   'Ü' : outstr[index]:='Â';
   'Ñ' : outstr[index]:='‰';
   'î' : outstr[index]:='ˆ';
   'Å' : outstr[index]:='¸';
   'õ' : outstr[index]:='¯';
   'ë' : outstr[index]:='Ê';
   '·' : outstr[index]:='ﬂ'; { beta? }
   end;

  end;

 toansi:=outstr;

end;



function nmstr(str1:string):string;
var outstr : string;
    index  : integer;
begin

 outstr:=upstr(str1);

 for index:=1 to length(outstr) do
  begin
   if (index>1) and (outstr[index-1]<>' ') then
    begin
     case outstr[index] of
     'A'..'Z' : outstr[index]:=chr(ord(outstr[index])+32);
     'è' : outstr[index]:='Ü';
     'é' : outstr[index]:='Ñ';
     'ô' : outstr[index]:='î';
     'ö' : outstr[index]:='Å';
     'ù' : outstr[index]:='õ';
     'í' : outstr[index]:='ë';
     end;
    end;
  end;

 nmstr:=outstr;

end;


end.

