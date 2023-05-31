Unit SJ3UNIT;

 {$I REGSTAT.PAS}

interface

procedure Init;

const  NumPl = 75;  { montako pelaajaa on ylip„„t„„n }
       NumTeams = 15;
       MaxOwnPl = 10; { montako omaa pelaajaa voi olla }
       NumWCHills = 20;  { montako m„ke„ World Cupissa }
       MaxExtraHills = 1000; { montako extra m„ke„ voi olla. CHECK!!! }
       MaxCustoms = 200; { montako custom hill filea .SJC voi olla }

       HexCh : array[0..15] of char =
       ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

       WCpoints : array[1..30] of byte =
        (100,80,60,50,45,40,36,32,29,26,24,22,20,18,16,
         15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1);
{
       Teampoints : array[1..6] of byte =
        (10,6,4,3,2,1);
}

       Teampoints : array[1..8] of integer =
        (400,350,300,250,
         200,150,100,50);


type Stat_type = record
      CompPos : byte;
      WCPos : byte;
      CompPts : integer;
      Round1Pos : byte;
      RoundPts : array [0..2] of longint;
      RoundLen : array [0..2] of integer;
      Reason : array [0..2] of byte;
     end;

    HillStr = string[25];
    TimeStr = string[22];
    NameStr = string[30];
    FileStr = string[8];



{
    Key_type = record
    JUMP1, JUMP2,
    RIGHT1, RIGHT2,
    LEFT1, LEFT2,
    TELE1, TELE2,
    TWO1, TWO2 : char;
    end;
}

    Key_type = record
    A,B : char;
    end;

    Hill_type = record
     Name : string[25];
     Author : string[30];
     Kr : integer;
     FrIndex, BkIndex : string[3];
     BkBright, BkMirror, VxFinal : byte;
     Pk, PlSave : double;
     Profile : longint;
     HRName : NameStr;
     HRLen : integer;
     HRTime : TimeStr;
    end;

    Hillinfo_type = record
     Name : HillStr;
     Kr : integer;
     HRName : NameStr;
     HRLen : integer;
     HRTime : TimeStr;
    end;

(*
    Hillrec = record
     Name : NameStr;
     Len  : integer;
     Time : TimeStr;
     end;
*)

    Hiscore = record
     Name : NameStr;
     Pos : byte;
     Score : Longint;
     Time : TimeStr;
    end;

    Date = record
     Year,Month,Day,DayofWeek : Word;
    end;

    Time = record
     Hour, Minute, Second, Sec100 : Word;
    end;

var NumHills, Vcode : byte;
    NumExtraHills : word;

{function getch(xx,yy:integer;bkcolor:byte):char;}
procedure getch(xx,yy:integer;bkcolor:byte;var tempch,tempch2:char);
function getstr(xx,yy,maxlength:integer;oldstr:string;bkcolor:byte):string;
function getstr2(xx,yy,maxchars:integer;oldstr:string;bkcolor:byte):string;

procedure lopputext(version:string;a1,a2:Time);

function MakeMenu(x,y,length,height,items,index:integer;bgcolor,phase,tab:byte):integer;

function LoadHill(var KeulaX:integer;nytmaki:integer;Acthill:hill_type):byte;

Function waitforkey3(xx,yy:integer;var ch:char):boolean;
procedure teamwarning;

procedure newunregtext;

{procedure mainmenutext(phase:byte;reg:boolean); }
procedure mainmenutext(phase:byte;version:string);
procedure unregendtext;
procedure newregtext(regname,regnumber:string);
procedure regendtext(regname,regnumber:string);

function makeletter(temp:integer):char;

procedure resultbox(phase:byte;result:integer);

function hillfile(nyt:integer):string;

{ procedure WriteExtraHillHR(index:integer);}
function fexist(filename:string):boolean;

procedure CheckExtraHills;
procedure LoadHillInfo;
procedure GetNow(var Now:Time);

function LoadInfo(nytmaki:integer;
                  var hill:hill_type):byte;

procedure choosewindplace(var place:byte);

procedure SetupItem(index,screen,entries:byte;str1:string);

procedure HillMaker(phase:byte);
{ procedure HillEditor(phase:byte); }

procedure setgoals;
function loadgoal(num:integer):integer;

function hillkr(nytmaki:integer):integer;
function hillname(nytmaki:integer):HillStr;
function hillcode(nytmaki:integer):longint;

function HRname(nytmaki:integer):NameStr;
function HRLen(nytmaki:integer):integer;
function HRTime(nytmaki:integer):TimeStr;

procedure SetHRinfo(nytmaki:integer;name:NameStr;len:integer;time:TimeStr);

function replayinfo(var filename, author, name:string;nytmaki,hp:integer):byte;


procedure WriteExtras;
procedure ReadExtras;

function quitting(phase:byte):byte;
function dayandtime(D1:Date;T1:Time):string;

Function Luehaalarit(index,col:byte):byte;
function injured:shortint;

function keyname(chw:word):string;
function kword(ch1,ch2:char):word;
procedure DefaultKeys(var K:array of word);
procedure ConfigureKeys(var K:array of word);

function crypt(arvo:longint;jarj:integer):string;
function uncrypt(str0:string;jarj:integer):longint;

function valuestr(str0:string;arvo:integer):word;
function svaluestr(str0:string;arvo:integer):word;
function choosehill(mmaara:byte):byte;
procedure kothchallenge(x:integer;kothpack:byte);
function kothtitle(temp:integer):string;

function lengthpoint(kr:integer):integer;

function mightdelete(filestr:string):byte;

procedure DoCoachCorner(height,kulmalaskuri:integer;grade,ponn,style:byte);

{procedure DrawLumi(delx,dely,wind:integer;lmaara:word); }
procedure DrawLumi(delx,dely,wind:integer;lmaara:word;draw:boolean);

procedure makevcode(version:string;reg:boolean);

(*
function ReadKey : char { in lieu of Crt.ReadKey } ;
*)

(*
procedure Textcolor(col:byte);
procedure Textbackground(col:byte);
procedure GotoXY(x,y:integer);
procedure Window(x1,y1,x2,y2:integer);
procedure clrscr;
*)


implementation

uses crt, dos, sj3help, sj3graph, sj3lang, maki, lumi, sj3pcx, sdlport, SysUtils;

{var osote : array [0..4000] of byte; }

var HD : array[0..NumWCHills+MaxExtraHills] of ^Hillinfo_type;

(*
    mnimet : array[0..NumWCHills+MaxExtraHills] of HillStr;
    kri : array[0..NumWCHills+MaxExtraHills] of integer;
*)

(*
 function ReadKey : char { in lieu of Crt.ReadKey } ;
  const Buff : char = #0 ; var R : Tregisters ;
  begin
    if Buff<>#0 then begin ReadKey := Buff ; Buff := #0 end else
      with R do begin AH := 0 ; Intr($16, R) ;
      if AL=0 then Buff := char(AH) ;
      ReadKey := char(AL) end ;
    end {ReadKey} ;
*)

(*

function ReadKey : char ; assembler ; { ei extended }
  asm
   mov AH,00h;
   int 16h
  end {ReadKey};

*)

(*
function ReadKey : char ; assembler ; { toimii melkein }
  asm
   mov AH,08h;
   int 21h
  end {ReadKey};
*)

  {
procedure Textcolor(col:byte); begin end;
procedure Textbackground(col:byte); begin end;
procedure GotoXY(x,y:integer); begin end;
procedure Window(x1,y1,x2,y2:integer); begin end;
procedure clrscr; begin end;
  }

procedure makevcode(version:string;reg:boolean);
var pos : byte;
begin

 pos:=2; { v3.11 !!! }
 if (reg) then pos:=4;

 if ((vcode and pos)=0) then vcode:=(vcode or pos);

end;

function lengthpoint(kr:integer):integer;
var return : integer;
begin

 return:=10;

 case kr of
 0..24   : return:=48;
 25..29  : return:=44;
 30..34  : return:=40;
 35..39  : return:=36;
 40..49  : return:=32;
 50..59  : return:=28;
 60..69  : return:=24;
 70..79  : return:=22;
 80..99  : return:=20;
 100..130: return:=18;
 131..200: return:=12;
 201..999: return:=10;
 end;

(*
 K-Point Distance Meter Value
20 to 24 m . . . . . . . . . . . . . . 4.8 pts./m
25 to 29 m . . . . . . . . . . . . . . 4.4 pts./m
30 to 34 m . . . . . . . . . . . . . . 4.0 pts./m
35 to 39 m . . . . . . . . . . . . . . 3.6 pts./m
40 to 49 m . . . . . . . . . . . . . . 3.2 pts./m
50 to 59 m . . . . . . . . . . . . . . 2.8 pts./m
60 to 69 m . . . . . . . . . . . . . . 2.4 pts./m
70 to 79 m . . . . . . . . . . . . . . 2.2 pts./m
80 to 99 m . . . . . . . . . . . . . . 2.0 pts./m
100 to 120 m . . . . . . . . . . . . . . 1.8 pts./m
145 to 185 m . . . . . . . . . . . . . . 1.2 pts./m
*)

 lengthpoint:=return;

end;

{function givech(xx,yy:integer;bkcolor:byte):char;}
procedure givech(xx,yy:integer;bkcolor:byte;var tempch,tempch2:char);
var run : integer;
    col : byte;

begin

 run:=0;

 repeat

  inc(run); if (run>20) then run:=0;

  col:=240;
  if (run>10) then col:=bkcolor;

  fillbox(xx,yy+6,xx+4,yy+6,col);
  DrawScreen;

 until (SDLPort.KeyPressed);

  SDLPort.WaitForKeyPress(tempch,tempch2);

  fillbox(xx,yy+6,xx+4,yy+6,bkcolor);
  writefont(xx,yy,tempch);

{ givech:=ch; }

end;



{function getch(xx,yy:integer;bkcolor:byte):char;}
procedure getch(xx,yy:integer;bkcolor:byte;var tempch,tempch2:char);
begin

  fillbox(xx-2,yy-2,xx+6,yy+8,bkcolor);

   givech(xx,yy,bkcolor,tempch,tempch2);

   DrawScreen;

{  getch:=ch; }

end;


function getstr(xx,yy,maxlength:integer;oldstr:string;bkcolor:byte):string;
var newstr : string;
    out : boolean;
    cx : integer;
{    tempch, tempch2 : char; }
begin

 out:=false;

 newstr:=oldstr;

  repeat

   cx:=fontlen(newstr);

   fillbox(xx-2,yy-2,xx+maxlength+2,yy+7,bkcolor);
   writefont(xx,yy,newstr);

   DrawScreen;

   givech(xx+cx,yy,bkcolor,ch,ch2);

   if (ch2=#83) then delete(newstr,1,length(newstr));

   case ch of

   #8 : delete(newstr,length(newstr),1);

   #13,#27 : out:=true;
{
   #32..#254 : if (cx+7 < maxlength) then newstr:=newstr+tempch; }

{   '0'..'9','A'..'Z','','Ž','™',
   'a'..'z','†','„','”','.',',','#','!','(',')','-', }
   #32..#254 : if (cx+7 < maxlength) and (fontlen(ch)>0) then newstr:=newstr+ch;

   end; { case }

  until (out);

 if (ch=#27) then newstr:=oldstr;

 getstr:=newstr;


end;



function getstr2(xx,yy,maxchars:integer;oldstr:string;bkcolor:byte):string;
var newstr : string;
    out : boolean;
    cx : integer;
{    tempch, tempch2 : char; }
begin

 out:=false;

 newstr:=oldstr;

  repeat

   cx:=fontlen(newstr);

   fillbox(xx-2,yy-2,xx+(maxchars*7)+2,yy+8,bkcolor);
   writefont(xx,yy,newstr);

   DrawScreen;

   givech(xx+cx,yy,bkcolor,ch,ch2);

   if (ch2=#83) then delete(newstr,1,length(newstr));

   case ch of

   #8 : delete(newstr,length(newstr),1);

   #13,#27 : out:=true;
{
   #32..#254 : if (cx+7 < maxlength) then newstr:=newstr+tempch; }

{   '0'..'9','A'..'Z','','Ž','™',
   'a'..'z','†','„','”','.',',','#','!','(',')','-', }
   #32..#254 : if (length(newstr) < maxchars) and (fontlen(ch)>0) then newstr:=newstr+ch;

   end; { case }

  until (out);

 if (ch=#27) then newstr:='ÿ';

 getstr2:=newstr;


end;


Procedure GetNow(var Now:Time);
begin
 gettime(Now.Hour,Now.Minute,Now.Second,Now.Sec100);
end;



function kothtitle(temp:integer):string;
var str1 : string;
begin

   case temp of
   1..6 : str1:=txt(temp)+'. '+lstr(130+temp);
    0,7 : str1:='0. '+lstr(137);
   end;

 kothtitle:=str1;

end;



function loadgoal(num:integer):integer;
var temp, value:integer;
    f2 : text;
begin

 assign(f2,'GOALS.SKI');
 {$I-}
 reset(f2);
 {$I+}

 value:=0;

 if (IOResult=0) and (num>0) and (num<=numwchills) then
  begin
   for temp:=1 to num do
    readln(f2,value);

   close(f2);
  end;

 loadgoal:=value;

end;

procedure setgoals;
var goals : array[0..numwchills] of integer;
    temp, y : integer;
    oldindex, index : integer;
    leave : boolean;
{    tempch1, tempch2 : char; }

 procedure loadgoals;
  var f2 : text;
      temp2 : integer;
  begin
   assign(f2,'GOALS.SKI');
   {$I-}
   reset(f2);
   {$I+}
   if (IOResult=0) then
    begin
     for temp2:=1 to NumWCHills do
      readln(f2,goals[temp2]);
     close(f2);
    end;
  end;

 procedure writegoals;
  var f2 : text;
      temp2 : integer;
  begin
   assign(f2,'GOALS.SKI');
   {$I-}
   rewrite(f2);
   {$I+}
   if (IOResult=0) then
    begin
     for temp2:=1 to NumWCHills do
      writeln(f2,goals[temp2]);
     close(f2);
    end;
  end;

 procedure drawgoal(temp2,phase:integer);
  begin
   if (phase=0) then fontcolor(240) else fontcolor(246);
   y:=(temp2*8)+24;
   fillbox(168,y-2,202,y+6,243);
   fillarea(168,y-2,202,y+6,63);
   if (temp2>20) then ewritefont(200,y,lstr(154))
                 else ewritefont(200,y,txtp(goals[temp2]));
  end;


begin

 loadgoals;

  Newscreen(1,0);

  fontcolor(240);
  writefont(30,6,lstr(200));
  fontcolor(241);
  writefont(40,13,lstr(243));

  fontcolor(246);

  writefont(24,23,lstr(106));
  ewritefont(200,23,lstr(242));
  ewritefont(250,23,'K');
  ewritefont(300,23,'HR');

  index:=1;
  leave:=false;

  for temp:=1 to NumWcHills do
   begin
    y:=(temp*8)+24;
    fontcolor(246);
    ewritefont(18,y,txt(temp)+'.');
    fontcolor(240);
    writefont(24,y,nsh(hillname(temp),140));
{    ewritefont(200,y,txtp(goals[temp])); }
    drawgoal(temp,0);
    fontcolor(247);
    ewritefont(250,y,txtp(hillkr(temp)*10));
    ewritefont(300,y,txtp(HRLen(temp)));
   end;

   inc(temp); drawgoal(temp,0); { exit }

 repeat

  y:=(index*8)+24;
  drawgoal(index,1);
  box(168,y-2,202,y+6,240);

  drawscreen;

  clearchs;
  SDLPort.WaitForKeyPress(ch,ch2);

  oldindex:=index;

  if ((ch2=#75) or (ch='-')) and (goals[index]>4) then dec(goals[index],5);
  if ((ch2=#77) or (ch='+')) and (goals[index]<2500) then inc(goals[index],5);
  if (ch2=#72) and (index>1) then dec(index);
  if (ch2=#80) and (index<21) then inc(index);
  if ((ch=#13) and (index=21)) or (ch2=#68) then leave:=true;
  if (ch=#27) or (ch2=#79) then index:=21;
  if (ch2=#71) then index:=1;

  drawgoal(oldindex,0);

 until (leave);

 writegoals;

end;



procedure DrawLumi(delx,dely,wind:integer;lmaara:word;draw:boolean);
begin

{ temp:=(tuuli div abs(tuuli))*(random(abs(tuuli)) div 10);

 Lumi.Update(Video,128,(delx*2)+temp,dely*2); }

{ Lmaara:=240;
  tuuli:=-40; }

 if (LMaara>0) then Lumi.Update(Video,delx*2,dely*2,wind*8,draw);

{ writefont(1,192,txt(wind)); }

{  if (LMaara>0) then Lumi.Update(Video,LMaara,delx*2,dely*2,tuuli); }

end;




procedure kothchallenge(x:integer;kothpack:byte);
var temp : integer;
    y : integer;
begin

 fontcolor(246);
 writefont(x,110,lstr(130));

 y:=120;

 if (kothpack=0) then kothpack:=7;

 for temp:=1 to 7 do
  begin
   fontcolor(241);
   if (temp=kothpack) or (kothpack=255) then fontcolor(240);

   writefont(x,y,kothtitle(temp));

   inc(y,8); if (temp=6) then inc(y,8); { ylim„„r„iset }
  end;

end;


function LoadHill(var KeulaX:integer;nytmaki:integer;Acthill:hill_type):byte;
var temp : integer;
    l  : longint;
    str1 : string;
    res : byte;
begin
          res:=0;

          LataaPCX('LOAD.PCX',320*200,0,0);
          SiirraStandardiPaletti;
          AsetaPaletti;

          WriteVideo;

{          FillBox(0,0,319,199,242); }

{          NewScreen(5,0); }

{          FontColor(240);
          MuutaLogo(2);
          WriteFont(60,90,'LOADING HILL...');
          DrawAnim(148,90,62);
          WriteFont(185,99,'...PLEASE WAIT');
          AsetaPaletti;   }

          str1:=txt(Acthill.kr);

          Fontcolor(246); { 205 }
{          Writefont(160-fontlen(str1) div 2,97,str1); }
          EWritefont(311,107,str1);
          Fontcolor(240);
          EWritefont(311-Fontlen(str1),107,Acthill.name+' K');

          DrawScreen;

          LataaPCX('FRONT'+Acthill.frindex+'.PCX',1024*512,0,0);

          TallennaAlkuosa(1);

          LaskeLinjat(KeulaX,acthill.kr,acthill.pk);

          l:=0;

          for temp:=0 to 1023 do
           inc(l,longint(profiili(temp)*(temp mod 13+profiili(temp) mod 11)) mod 13313);

           dec(l,1500000);

          LataaPCX('BACK'+acthill.bkindex+'.PCX',1024*400,Maki.Sivuja,acthill.bkmirror);

          TakaisinAlkuosa(1);

          if (l<>acthill.profile) then { profiilichekkaus }
           begin

             alertbox;

             str1:='RUN THE HILL MAKER AGAIN.';

             if (nytmaki<=NumWCHills) then
              begin
               res:=1;
               str1:='EXITING CUP.';
              end;

             writefont(80,90,'THE PROFILE OF HILL #'+acthill.frindex);
             writefont(80,102,'HAS BEEN CHANGED! NOT GOOD.');
             writefont(80,114,str1);

             writefont(80,130,'PRESS A KEY...');
             drawscreen;

             waitforkey;

           end;

          SavytaPaletti(1,acthill.bkbright);

          Loadhill:=res;

end;



function MakeMenu(x,y,length,height,items,index:integer;bgcolor,phase,tab:byte):integer;
var{ tempch1,tempch2 : char; }
{    index : integer; }
    xx,yy : integer;
    out,fill,putkeen : boolean;
    boxcol : byte;
    del : boolean;
    oldindex : integer;
    thing : integer;

begin  { phase: 0 - DEL ei k„y, 1 - DEL k„y, 2 - 2 columns! DEL k„y }
       {        3 - kaikki putkeen, 4 - ei fillarea, 5 - old players }
       {        6 - new profiles, 7 - kaikki putkeen & ei fill }

 out:=false;
 del:=false; { delete n„pp„in ei k„yt”ss„ }
 thing:=63;

 if (phase=5) then begin thing:=64; phase:=1; end;

 case phase of
 1,2,6 : del:=true;
 end;

 fill:=true;

 case phase of
 4,7 : fill:=false;
 end;

 putkeen:=false;

 case phase of
 3,7 : putkeen:=true;
 end;

{ if (phase=2) then cols:=2; }

{ index:=1; }

 index:=abs(index);

  xx:=x-6;
  yy:=y-3+((index-1)*height);

(*
  if (index>tab) and (cols=2) then
   begin
    xx:=x+160-6;
    yy:=y-3+((index-1-tab)*height);
   end;
*)

  boxcol:=240;

 repeat

  box(xx,yy,xx+length,yy+height,bgcolor);
  if (fill) then fillarea(xx,yy,xx+length,yy+height,thing);

   clearchs; oldindex:=index;

  if (SDLPort.KeyPressed) then SDLPort.WaitForKeyPress(ch,ch2);

   case (ch2) of
   #72,#75 :{  if (cols=2) and (tempch2=#75) and (index>tab) then dec(index,tab)
             else }
              begin
               if (index>1) then dec(index)
                            else index:=items+2;
               if (index=items+1) then dec(index); { skip v„li }
              { boxcol:=32; }
              end;
   #77,#80 :{ if (cols=2) and (tempch2=#77) then inc(index,tab)
              else }
             begin
              if (index<items+1) then inc(index)
                                 else index:=1;
              if (index=items+1) then inc(index); { skip v„li }
             { boxcol:=32; }
             end;
   #59..#68 : begin
               index:=ord(ch2)-58;
               out:=true;
              end;
   end; { case }

   case (ch) of
   '0'..'9' : index:=ord(ch)-48;
   'A'..'F' : if (phase<>6) then index:=ord(ch)-55; { me halutaan ett„ E on edit }
   'a'..'f' : index:=ord(ch)-87;
   end;

   if (index<=0) or (index>items) then
    begin
     index:=items+2;
     if (putkeen) then index:=items+1;
    end;

   if (ch2=#71) then index:=1;
   if (ch=#27) or (ch2=#79) then
    begin
     index:=items+2;
     if (putkeen) then index:=items+1;
    end;

   if (ch2=#68) then { F10 }
    begin
     out:=true;
     index:=items+2;
     if (putkeen) then index:=items+1;
     if (phase=6) then index:=254;
    end;

   if (ch=#9) and (tab>0) then
    begin { tab }
     out:=true;
     if (tab<254) then index:=tab;
     if (tab=255) then index:=items+2;
    end;

   if (ch=#13) or (ch=' ') then out:=true;

   xx:=x-6;
   yy:=y-3+((index-1)*height);

   if (phase=6) and ((ch=#13) or (upcase(ch)='E') or (ch=#9)) then
    begin
     index:=tab;
     out:=true;
    end;

(*
   if (index>tab) and (cols=2) then
    begin
     xx:=x+160-6;
     yy:=y-3+((index-1-tab)*height);
    end;
*)

{  inc(boxcol); if (boxcol>47) then boxcol:=16; }

  box(xx,yy,xx+length,yy+height,boxcol);

  DrawScreen;

   if (ch2=#83) and (del) then begin out:=true; index:=-index; end; { delete! }

   if (phase=6) and (index<>oldindex) then out:=true;

 until (out);

  box(xx,yy,xx+length,yy+height,bgcolor);
  if (fill) then fillarea(xx,yy,xx+length,yy+height,thing);

 if (phase<>6) then
  begin
   DrawScreen;
   if (index>items) then index:=0;  { exit }
  end;

 clearchs;

 MakeMenu:=index;

end;




procedure DoCoachCorner(height,kulmalaskuri:integer;grade,ponn,style:byte);
var wstr : string;
    cstr : array[0..5] of string;
    temp, index, count,x,y : integer;
begin

 for temp:=0 to 5 do cstr[temp]:='';

 index:=360+style*40;

 case kulmalaskuri of
 0..49 : cstr[0]:=lstr(index+2);
 50..61 : cstr[0]:=lstr(index+3);
 62..200 : cstr[0]:=lstr(index+4);
 end;

 if (grade<10) then
  begin
   case grade of
    1 : cstr[1]:=lstr(index+5);
    2 : cstr[1]:=lstr(index+6);
    3 : cstr[1]:=lstr(index+7);
   end;
  end else
   begin
    case grade div 10 of
     1..5  : cstr[1]:=lstr(index+10);
     6..8  : cstr[1]:=lstr(index+11);
        9  : cstr[1]:=lstr(index+12);
       10  : cstr[1]:=lstr(index+13);
       11  : cstr[1]:=lstr(index+14);
   12..20  : cstr[1]:=lstr(index+15);
    end;
   end;

  case ponn of
   0..5  : cstr[2]:=lstr(index+18);
   6..9  : cstr[2]:=lstr(index+19);
  10..12 : cstr[2]:=lstr(index+20);
  13..15 : cstr[2]:=lstr(index+21);
      16 : cstr[2]:=lstr(index+22);
  17..19 : cstr[2]:=lstr(index+23);
  20..23 : cstr[2]:=lstr(index+24);
  24..50 : cstr[2]:=lstr(index+25);
  end;

  case height of
  0..49  : cstr[3]:=lstr(index+28);
 50..55  : cstr[3]:=lstr(index+29);
 56..60  : cstr[3]:=lstr(index+30);
 61..64  : cstr[3]:=lstr(index+31);
 65..70  : cstr[3]:=lstr(index+32);
 71..90  : cstr[3]:=lstr(index+33);
 91..200 : cstr[3]:=lstr(index+34);
 end;

  if (grade<10) then cstr[0]:=cstr[1]; { jos kupat n„es }
  if (grade=1) then cstr[3]:=lstr(index+35);

  cstr[1]:=cstr[random(2)];
  cstr[2]:=cstr[random(2)+2];

  cstr[1]:=cstr[1]+'*'+cstr[2];

  FontColor(252);

  DrawAnim(3,150,65);
   writefont(12,150,lstr(400));

  index:=1;
  x:=12; y:=160;

   writefont(x,y,'"');

  count:=30;
  x:=18; y:=152;

  wstr:='';

  for temp:=1 to length(cstr[1]) do
   begin

    wstr:=wstr+cstr[1][temp];
    if (wstr[index]='*') then wstr[index]:=' ';
    inc(index);

    if ((index > count) and (cstr[1][temp]=' ')) or ((cstr[1][temp]='*') and (index>count div 2)) then
     begin
      if (y<190) then inc(y,8);
      x:=18;
      if (cstr[1][temp]='*') then delete(wstr,length(wstr),1);

      writefont(x,y,wstr);
      x:=x+fontlen(wstr);

      wstr:='';
      index:=1;
     end;



   end;

   if (index>1) then
    if (length(wstr)<2) then writefont(x,y,wstr+'"')
                        else
                         begin
                          x:=18;
                          if (y<192) then inc(y,8);
                          writefont(x,y,wstr+'"');
                         end;

end;



procedure SetupItem(index,screen,entries:byte;str1:string);
var xx,yy : integer;
    istr : string;
    good : boolean;
begin

 xx:=25;
 yy:=(index*10)+30;

 good:=true;

{$IFNDEF REG}
  case screen of
   0 : if (index>4) then good:=false;
   1 : if (index=4) then good:=false;
   2 : case index of
       1,2,6,8,10 : good:=false;
       end;
  end;

 if (not good) then fontcolor(241); { harmaaksi, jos ei ole reg option }

 if (good) then fontcolor(246);
{$ELSE}
 fontcolor(246);
{$ENDIF}

 if (index=0) then yy:=(entries*10)+50;

 istr:=HexCh[index]+'.';

 ewritefont(xx,yy,istr);

 if (good) then fontcolor(240);

 xx:=35;

 case screen of
 0 : istr:=lstr(195+index);
 1 : istr:=lstr(203+index);
 2 : istr:=lstr(211+index);
 3 : istr:=lstr(225+index)
 end; { screen case }

 writefont(xx,yy,istr);

 if (good) then fontcolor(246);

 xx:=255;

 writefont(xx,yy,str1);

end;

function HRName(nytmaki:integer):NameStr;
begin
 HRName:=HD[nytmaki]^.HRName;
end;

function HRLen(nytmaki:integer):integer;
begin
 HRLen:=HD[nytmaki]^.HRLen;
end;

function HRTime(nytmaki:integer):TimeStr;
begin
 HRTime:=HD[nytmaki]^.HRTime;
end;

procedure SetHRinfo(nytmaki:integer;name:NameStr;len:integer;time:TimeStr);
begin
 HD[nytmaki]^.HRName:=name;
 HD[nytmaki]^.HRLen:=len;
 HD[nytmaki]^.HRTime:=time;
end;

function hillkr(nytmaki:integer):integer;
var temp:integer;
begin

 temp:=0;

 if (nytmaki > 0) and (nytmaki <= NumWChills+NumExtraHills) then
  temp:=HD[nytmaki]^.kr;

 hillkr:=temp;

end;


function hillname(nytmaki:integer):HillStr;
var str1 : string;
begin

 if (nytmaki < 0) or (nytmaki > NumWChills+NumExtraHills) then
  str1:='Unknown'
   else str1:=HD[nytmaki]^.name;

(*
 if (nytmaki=0) then str1:='a Random Hill'; { ainakin koth }
 *)

 if (nytmaki=0) then str1:=lstr(155);

 hillname:=str1;

end;


function hillcode(nytmaki:integer):longint;
var temp:longint;
    h : hill_type;
begin

 temp:=0;

 if (nytmaki > 0) and (nytmaki <= NumWChills+NumExtraHills) then
  begin
   loadinfo(nytmaki,h);
   temp:=h.profile+
         round(h.plsave*311)+
         h.vxfinal*131+
         round(h.pk)*17+
         h.kr*11+
         svaluestr(h.name,1);
  end;

 hillcode:=temp;

end;

procedure writehill(var f1:text;h:hill_type;index,phase:integer);
 { phase: 0 - tavallinen, 1 - ei profiilin checkkausta (HR:t) }
var a,c : integer;
    b : byte;
    l1, l2 : longint;

begin

 l1:=0; l2:=0;

 writeln(f1,'*'+chr(index+64));
 writeln(f1,h.name);
 writeln(f1,h.kr);
 writeln(f1,h.frindex);
 writeln(f1,h.bkindex);
 writeln(f1,h.bkbright);
 writeln(f1,h.bkmirror);
 writeln(f1,h.vxfinal);

 b:=round(h.pk*100);
  writeln(f1,b);

 a:=round(h.plsave*10000);
  writeln(f1,a);

 writeln(f1,h.author);

  inc(l1,valuestr(h.name,index+1));
  inc(l1,longint(h.kr)*77);
  c:=num(h.frindex); { t„m„ yhteensopivuudenkin takia }
   if (c<0) then c:=valuestr(h.frindex,index+1); { jos indexiss„ kirjaimia (v3.10) }
   inc(l1,longint(c)*272);
  c:=num(h.bkindex); { t„m„ my”s }
   if (c<0) then c:=valuestr(h.bkindex,index+1);
   inc(l1,longint(c)*373);
  inc(l1,longint(h.bkbright)*313);
  inc(l1,longint(h.bkmirror)*5775);
  inc(l1,longint(h.vxfinal)*333);
  inc(l1,longint(b) mod 55555);
  inc(l1,longint(a) mod 11111);
  inc(l1,valuestr(h.author,index+2));

   l1:=l1 xor 787371;

   writeln(f1,l1);

  l2:=0;

  if (phase=1) then
   begin
    writeln(f1,h.profile);
   end else
   begin

    h.hrname:='Defaultÿ';
    h.hrlen:=0;
    h.hrtime:='Jan 1 2001 1:00';  { nollataan hillrec }

    LataaPCX('FRONT'+h.frindex+'.PCX',1024*512,0,0);
    LaskeLinjat(a,h.kr,h.pk);

    for a:=0 to 1023 do
     inc(l2,longint(profiili(a)*(a mod 13+profiili(a) mod 11)) mod 13313);

    dec(l2,1500000);

    writeln(f1,l2);
   end;

{  writeln(f1); }

  if (index=0) then { extra hill }
   begin
    l1:=0;

    writeln(f1,h.hrname); { m„kienkkatiedot }
    writeln(f1,h.hrlen);
    writeln(f1,h.hrtime);

    inc(l1,valuestr(h.hrname,13)); { checksum }
    inc(l1,longint(h.hrlen)*3553);
    writeln(f1,l1);
   end;

end;



procedure defaulthill(var hill:hill_type);
begin

 with hill do
  begin
   name:='Default';
   author:='Unknown';
   frindex:='1'; { front index eli etukuvan j„rj n:o }
   bkindex:='0'; { back index }
   bkbright:=100; { taustan kirkkaus, 100 = normaali }
   bkmirror:=0; { peilataanko tausta? 0 - ei, 1 - joo }

   kr:=120;
   pk:=1.0;
   plsave:=0.321;
   vxfinal:=140;

   hrname:='Default Jumperÿ';
   hrlen:=0;
   hrtime:='Oct 1 2000 0:00';

  end;

end;



procedure resultbox(phase:byte;result:integer);
var temp : integer;
{    tempch, tempch2 : char; }
begin

 temp:=348+(phase*2);

 if (result<>0) then inc(temp);

 { 1 - repl, 2 - custo, 3 - extrh }

 fillbox(59,79,261,121,250);
 fillbox(60,80,260,120,245);

 fontcolor(246);

 writefont(75,90,lstr(temp));
 waitforkey3(240,105,ch);

end;




procedure makewarning(num:integer;str1:string);
begin

 alertbox;

 writefont(80,90,'SJ3 WARNING #'+txt(num));
 writefont(80,105,str1);

 writefont(80,120,'PRESS A KEY...');
 drawscreen;

 waitforkey;

end;



function findstart(var f1:text;
                   nytmaki:integer):byte;
var str1:string;
    result:byte;
    out:boolean;
begin

 out:=false;
 result:=1; { ei l”ytynyt ok }

 repeat

  if (eof(f1)) then out:=true
               else readln(f1,str1);

  if (str1[1]='*') then
   if (nytmaki=0) or (str1[2]=chr(nytmaki+64))
    then begin out:=true; result:=0; end;

 until (out);

  findstart:=result;

end;



function fexist(filename:string):boolean;
var tempb : boolean;
    f1 : file;
begin

 tempb:=false;

  {$I-}
  assign(f1,filename);
  reset(f1);
  {$I+}
  if (IOResult = 0) then
   begin
    tempb:=true;
    close(f1);
   end;

  fexist:=tempb;

end;



function hillfile(nyt:integer):string;
var str1 : string;
    temp : integer;
    f2 : text;
begin

 hillfile:='HILLBASE.SKI';

 if (nyt<=NumExtraHills) then
  begin
   assign(f2,'MOREHILL.SKI');
   {$I-}
   reset(f2);
   {$I+}
   FileOK(IOResult,'MOREHILL.SKI');

   str1:='ERROR.SJH';

   readln(f2); { NumExtraHills pois }

   for temp:=1 to nyt do
    readln(f2,str1);

   close(f2);

   hillfile:=str1;

  end;
end;





function LoadInfo(nytmaki:integer;
                 var hill:hill_type):byte;

var f1 : text;
    a,c : integer;
    b : byte;
    str1 : string;
    l1,l2,l3,l4 : longint;
    temp : integer;

 procedure checkfile(phase:integer);
 var filename : string;
     str2 : string;
     indexstr : string[3];

 begin

 str2:='FRONT';
 indexstr:=hill.frindex;
  if (phase=1) then begin str2:='BACK'; indexstr:=hill.bkindex; end;

 filename:=str2+indexstr+'.PCX';

 if (not fexist(filename)) then
  begin
   AsetaMoodi($3);
   writeln('Error #345A: File '+filename+' does not exist,');
   writeln('even though it''s mentioned in the ',str1,' file.');
   writeln('Using FRONT1.PCX and BACK1.PCX.');
   writeln;
   writeln('Press a key...');

   hill.bkindex:='1';
   hill.frindex:='1';

   waitforkey;

   AsetaMoodi($13);
  end;
 end;


begin

 l1:=0; l2:=0; l3:=0; l4:=0;

 defaulthill(hill);

 if (nytmaki<=NumWCHills) then str1:='HILLBASE.SKI'
                          else str1:=hillfile(nytmaki-NumWCHills)+'.SJH';

  assign(f1,str1);

  {$I-}
  reset(f1);
  {$I+}
  FileOk(IOResult, str1);

  temp:=nytmaki;

  if (nytmaki>NumWCHills) then temp:=0;

  if (findstart(f1,temp)=0) then
    begin
     readln(f1,hill.name);
     readln(f1,hill.kr);
     readln(f1,hill.frindex);
     readln(f1,hill.bkindex);
     readln(f1,hill.bkbright);
     readln(f1,hill.bkmirror);
     readln(f1,hill.vxfinal);
     readln(f1,b);
      hill.pk:=(b/100);
     readln(f1,a);
     hill.plsave:=(a/10000);
     readln(f1,hill.author);
     readln(f1,l2); { checksum }
     readln(f1,hill.profile);

      inc(l1,valuestr(hill.name,temp+1));
      inc(l1,longint(hill.kr)*77);
      c:=num(hill.frindex); { t„m„ yhteensopivuudenkin takia }
       if (c<0) then c:=valuestr(hill.frindex,temp+1); { jos indexiss„ kirjaimia (v3.10) }
      inc(l1,longint(c)*272);
      c:=num(hill.bkindex); { t„m„ my”s }
       if (c<0) then c:=valuestr(hill.bkindex,temp+1);
      inc(l1,longint(c)*373);
      inc(l1,longint(hill.bkbright)*313);
      inc(l1,longint(hill.bkmirror)*5775);
      inc(l1,longint(hill.vxfinal)*333);
      inc(l1,longint(b) mod 55555);
      inc(l1,longint(a) mod 11111);
      inc(l1,valuestr(hill.author,temp+2));

      l1:=l1 xor 787371;

     if (nytmaki>NumWCHills) then { voi olla ettei n„it„ oo - v3.00}
      begin

       {$I-}
       readln(f1,hill.hrname);
       readln(f1,hill.hrlen);
       readln(f1,hill.hrtime);
       readln(f1,l3);
       {$I+}

       if (IOResult=0) and (l3<>0) then { kaikki ok }
        begin
         inc(l4,valuestr(hill.hrname,13));
         inc(l4,longint(hill.hrlen)*3553);
         if (l3<>l4) then inc(l1);
        end else
        begin
         { beep(1); }
         hill.hrname:='Nobodyÿ';
         hill.hrlen:=0;
         hill.hrtime:='Oct 1 2000 0:00';
        end;

      end;
    end;

 close(f1);

 checkfile(0);
 checkfile(1);

 if (l1<>l2) then { joku ei t„sm„„! }
  begin
   if (nytmaki<NumWCHills) then
    begin
     AsetaMoodi($3);
     writeln('Error #324A: Something''s wrong in the ',str1,' file.  ');
     writeln('Maybe it''s been edited or something.  That won''t do.  Exiting.');
     Waitforkey;
     Halt;
    end else
     begin
      sj3help.beep(1);

      AsetaMoodi($3);

      writeln('Warning #56B: Something doesn''t add up in the '+str1+' file. ');
      writeln('Continuing with a default hill.');
      writeln;
      writeln('Press a key...');

      waitforkey;
      defaulthill(hill);

      AsetaMoodi($13);

     end;
  end;

end;


function checkdiff(h1,h2:hill_type):boolean;
var tempb : boolean;
begin
 tempb:=false;

 if (h1.name<>h2.name) or
    (h1.author<>h2.author) or
    (h1.kr<>h2.kr) or
    (h1.frindex<>h2.frindex) or
    (h1.bkindex<>h2.bkindex) or
    (h1.bkbright<>h2.bkbright) or
    (h1.bkmirror<>h2.bkmirror) or
    (h1.vxfinal<>h2.vxfinal) or
    (h1.pk<>h2.pk) or
    (h1.plsave<>h2.plsave) or
    (h1.profile<>h2.profile) then tempb:=true;

 checkdiff:=tempb;

end;





procedure edithill(var h2:hill_type;var filestr:string;change:boolean);
var temp : integer;
    tempb : byte;
    leave2 : boolean;
{    ch,ch2 : char; }
    index2 : integer;
    xx, xx2, yy : integer;
    str1 : string;
    oldhill : hill_type;

 procedure getnum(var thisnum:byte;low,high:byte);
 var code : integer;
    temp : longint;
    str2 : string;
 begin
  str2:=getstr(xx2,yy,30,txt(thisnum),242);
  val(str2,temp,code);

  if (temp<low) then temp:=low;
  if (temp>high) then temp:=high;

  if (code=0) then thisnum:=temp;
 end;

 procedure getint(var thisnum:integer;low,high:integer);
 var code : integer;
     temp : longint;
     str2 : string;
 begin
  str2:=getstr(xx2,yy,30,txt(thisnum),242);
  val(str2,temp,code);

  if (temp<low) then temp:=low;
  if (temp>high) then temp:=high;

  if (code=0) then thisnum:=temp;

 end;

begin

 leave2:=false;
{ change:=false; }
 index2:=1;
 xx:=15;
 xx2:=120;
 yy:=20;

 oldhill:=h2;
{ oldfile:=filestr; }

 repeat

  newscreen(5,0);

  for temp:=1 to 12 do
   begin

    case temp of
     1 : str1:='HILL.NAME';
     2 : str1:='K.POINT';
     3 : str1:='FRONT INDEX';
     4 : str1:='BACK INDEX';
     5 : str1:='BACK BRIGHT';
     6 : str1:='MIRROR BACK';
     7 : str1:='VX.FINAL';
     8 : str1:='ADJUST.K';
     9 : str1:='AIR.P.PLUS';
    10 : str1:='AUTHOR';
    11 : str1:='FILENAME';
    12 : str1:='EXIT, DON''T SAVE';
    end;

    yy:=10+(temp-1)*13;

    fontcolor(240);
    if (temp<12) then str1:=str1+':';
    writefont(xx,yy,txt(temp)+'. '+str1);

    str1:='';

    case temp of
    2 : str1:='Critical Point (40-300«)';
    3 : str1:='FRONT*.PCX (000-ZZZ)';
    4 : str1:='BACK*.PCX (000-ZZZ)';
    5 : str1:='PERCENTS OF ORIGINAL (0-255)';
    6 : str1:='0-NO, 1-MIRROR (0-1)';
    7 : str1:='TAKE-OFF SPEED (60-145 KM/H)';
    8 : str1:='MOVE K-POINT ON HILL (50-150)';
    9 : str1:='+ 990 MBAR (0-30)';
    11 : str1:='     8 CHARS MAX';
    end;

    fontcolor(241);
    writefont(xx2+40,yy,str1);

    str1:='';

    case temp of
    1 : str1:=h2.name;
    2 : str1:=txt(h2.kr);
    3 : str1:=h2.frindex;
    4 : str1:=h2.bkindex;
    5 : str1:=txt(h2.bkbright);
    6 : str1:=txt(h2.bkmirror);
    7 : str1:=txt(h2.vxfinal-40);
    8 : str1:=txt(round(h2.pk*100));
    9 : str1:=txt(round(h2.plsave*10000)-3204);
    10: str1:=h2.author;
    11: str1:=filestr;
    end;

    fontcolor(246);
    writefont(xx2,yy,str1);

   end;

    temp:=14;

    yy:=10+(temp-1)*13;

    writefont(xx,yy,'0. EXIT and SAVE');

  index2:=MakeMenu(10,8,110,13,12,index2,243,0,0);

  yy:=10+(index2-1)*13;

  case index2 of
  0 : begin
       if (not change) then change:=checkdiff(oldhill,h2);
       if (not change) then filestr:='NULL'; { ei tarvi tallentaa }
       leave2:=true;

       if (filestr<>'NULL') then
        begin

         if (fexist(filestr+'.SJH')) then
          begin
           alertbox;

           writefont(80,90,'FILE '+filestr+'.SJH ALREADY EXISTS.');
           writefont(80,110,'WRITE OVER? (Y/N):');

           getch(190,110,243,ch,ch2);

           if (upcase(ch) <> 'Y') then
            begin leave2:=false; index2:=11; end;
          end;
        end;
      end;
  1 : h2.name:=getstr(xx2,yy,150,h2.name,242);
  2 : getint(h2.kr,40,300);
  3 : begin
       str1:=h2.frindex;
       h2.frindex:=getstr(xx2,yy,20,h2.frindex,242);
       if (not fexist('FRONT'+h2.frindex+'.PCX')) then
        begin
         alertbox;
         writefont(80,90,'INVALID FRONT INDEX VALUE.');
         writefont(80,100,'FILE FRONT'+h2.frindex+'.PCX DOESN''T EXIST.');
         waitforkey3(190,110,ch);
         h2.frindex:=str1;
        end;
      end;
  4 : begin
       str1:=h2.bkindex;
       h2.bkindex:=getstr(xx2,yy,20,h2.bkindex,242);
       if (not fexist('BACK'+h2.bkindex+'.PCX')) then
        begin
         alertbox;
         writefont(80,90,'INVALID BACK INDEX VALUE.');
         writefont(80,100,'FILE BACK'+h2.bkindex+'.PCX DOESN''T EXIST.');
         waitforkey3(190,110,ch);
         h2.bkindex:=str1;
        end;
      end;
  5 : getnum(h2.bkbright,0,255);
  6 : getnum(h2.bkmirror,0,1);
  7 : begin
       tempb:=h2.vxfinal-40;
       getnum(tempb,60,145);
       h2.vxfinal:=tempb+40;
      end;
  8 : begin
       temp:=round(h2.pk*100);
       getint(temp,50,150);
       h2.pk:=temp/100;
      end;
  9 : begin
       temp:=round(h2.plsave*10000)-3204;
       getint(temp,0,30);
       h2.plsave:=(temp+3204)/10000;
      end;
  10 : h2.author:=getstr(xx2,yy,150,h2.author,242);
  11 : begin
        str1:=getstr2(xx2,yy,8,filestr,242);
        if (str1<>'ÿ') then filestr:=str1;

{        if (length(filestr)>8) then filestr:=copy(filestr,1,8); }
       end;
  12 : begin
        leave2:=true;
        h2:=oldhill;
        filestr:='NULL';
       end;
  end;

 until (leave2);

 index2:=1; leave2:=false; { kun se on sekoillut v„h„n... }

end;


function replayinfo(var filename, author, name:string;nytmaki,hp:integer):byte;
var result : byte;
    str1 : string;
    temp, index2 : integer;
{    ch, ch2 : char; }
    xx, yy : integer;
    leave2 : boolean;
begin

 result:=0;
 index2:=1;
 leave2:=false;
 xx:=18; yy:=40;

 name:='Huge Jump in '+hillname(nytmaki);
 filename:='TEMP';

 repeat

  newscreen(1,0);

{  fillbox(50,30,270,170,243);
   fillarea(50,30,270,170,64);
   fontcolor(246); }

  fontcolor(240);

  writefont(30,6,lstr(25)+': '+txtp(hp)+'« at '+hillname(nytmaki)+' K'+txt(hillkr(nytmaki)));

  for temp:=1 to 5 do
   begin

    yy:=(temp*16)+26;

    if (temp<5) then fontcolor(240)
                else inc(yy,16);

    str1:='';
    case temp of
    1,2,3 : str1:=lstr(290+temp);
    4,5 : str1:=lstr(291+temp);
    end;

    writefont(xx,yy,txt(temp)+'. '+str1);
    fontcolor(246);

    str1:='';
    case temp of
    1 : str1:=author;
    2 : str1:=name;
    3 : str1:=filename;
    end;

    writefont(xx+130,yy,str1);

   end;

  index2:=makemenu(15,39,135,16,4,index2,243,0,0);

  yy:=(index2*16)+26;

  case index2 of
  1 : author:=getstr(xx+130,yy,130,author,242);
  2 : name:=getstr(xx+130,yy,130,name,242);
  3 : begin
       str1:=getstr2(xx+130,yy,8,filename,242);
       if (str1<>'ÿ') then filename:=str1;
{       if (length(filename)>8) then filename:=copy(filename,1,8); }
      end;
  4 : begin
       leave2:=true;
       result:=1;
      end;
  0 : begin
       leave2:=true;

       if (fexist(filename+'.SJR')) then
        begin
         alertbox;

         writefont(80,90,filename+'.SJR '+lstr(345));
         writefont(80,110,lstr(346)+' ('+lch(6,1)+'/'+lch(7,1)+'):');

         getch(190,110,243,ch,ch2);

         if (upcase(ch) <> lch(6,1)) then
          begin leave2:=false; index2:=3; end;

        end;
       end;
  end;

 until (leave2);

 replayinfo:=result;

end;


function keyname(chw:word):string;
var str1:string;
    ch : key_type;
begin

 ch.A:=chr(hi(chw));
 ch.B:=chr(lo(chw));

 str1:='NULL';

 case ch.A of
 #0 : case ch.B of
     #59..#67 : str1:='F'+txt(ord(ch.B)-58);
      #71 : str1:='HOME';
      #72 : str1:=lstr(280);
      #73 : str1:='PAGE UP';
      #75 : str1:=lstr(281);
      #76 : str1:='NP 5';
      #77 : str1:=lstr(282);
      #79 : str1:='END';
      #80 : str1:=lstr(283);
      #81 : str1:='PAGE DOWN';
      #82 : str1:='INSERT';
      #83 : str1:='DELETE';
      end;

  #8 : str1:='BACKSPACE';
  #9 : str1:='TAB';

{ #13 : str1:='ENTER'; }
 ' ' : str1:='SPACE';
 '.' : str1:='.';
 ',' : str1:=',';
 '-' : str1:='-';
 '+' : str1:='+';
 '/' : str1:='/';
 '*' : str1:='*';


 #48..#57 : str1:=txt(ord(ch.A)-48);
 #65..#90 : str1:=ch.A;
 #97..#122 : str1:=upcase(ch.A);

 end;

 keyname:=str1;

end;

function kword(ch1,ch2:char):word;
begin

 kword:=ord(ch1)*$100+ord(ch2);

end;


procedure DefaultKeys(var K:array of word);
begin

  K[1]:=72;
  K[2]:=77;
  K[3]:=75;
  K[4]:=ord('T')*$100+20;
  K[5]:=ord('R')*$100+19;

end;


procedure ConfigureKeys(var K:array of word);
var leave2 : boolean;
    index2, temp, temp2, x, y : integer;
    str2 : string;
    tch : key_type;

begin

 leave2:=false;
 index2:=1;
 x:=25;

 repeat

  Newscreen(1,0);

  fontcolor(240);
  writefont(30,6,lstr(199));

  for temp:=1 to 6 do
   begin
    y:=temp*10 + 30;
    fontcolor(240);
    writefont(x+10,y,lstr(temp+330));
    str2:='';

    if (temp<6) then str2:=keyname(K[temp]);

    fontcolor(246);
    writefont(x+160,y,str2);
    ewritefont(x,y,txt(temp)+'.');
   end;

  inc(y,20);
  ewritefont(x,y,'0.');
  fontcolor(240);
  writefont(x+10,y,lstr(337));

  index2:=makemenu(35,40,150,10,6,index2,243,0,0);

  tch.A:=#0; tch.B:=#0;

  case index2 of
  0 : leave2:=true;
  1..5 : begin
           repeat
            y:=index2*10+30;

            fillbox(180,y-2,319,y+7,243);
            fillarea(180,y-2,319,y+7,63);

            getch(185,y,245,tch.A,tch.B);
            tch.A:=upcase(tch.A);

            str2:=keyname(kword(tch.A,tch.B));

            temp2:=0;

            for temp:=1 to 5 do
             if (kword(tch.A,tch.B) = K[temp]) then temp2:=temp;

            if (temp2>0) and (temp2<>index2) then str2:='NULL';

           until (str2<>'NULL');

           K[index2]:=kword(tch.A,tch.B);

          end;
  6 : DefaultKeys(K);
  end;

 until (leave2);

end;


procedure WriteExtraHillHR(index:integer);
var f1 : text;
    h : hill_type;
    temp : integer;
begin

 LoadInfo(index,h);

 h.HRName:=HD[index]^.HRname;
 h.HRLen:=HD[index]^.HRlen;
 h.HRTime:=HD[index]^.HRtime;

 temp:=index-NumWCHills;

 assign(f1,hillfile(temp)+'.SJH');
 {$I-}
 rewrite(f1);
 {$I+}
 if (IOResult=0) then
  begin
   writehill(f1,h,0,1); { ainoa mesta jossa phase=1 }
   close(f1);
  end else
   begin
    writeln('Error #29: Couldn''t write file ',hillfile(temp)+'.SJH');
    writeln('Maybe the disk is full or something.');
   end;

end;

(*
procedure HillEditor(phase:byte);
var h : array[0..20] of hill_type;
    filestr : string;
    temp, index : integer;
    str1 : string;
    leave : boolean;
    f1 : text;
begin

 for temp:=1 to 20 do
  LoadInfo(temp,h[temp]);

  index:=1;

  filestr:='NULL';

 repeat

  NewScreen(5,0);

  for temp:=1 to NumWCHills do
   begin
    fontcolor(246);
    ewritefont(71,(temp-1)*8+10,txt(temp)+'.');
    fontcolor(247);
    str1:=copy(hillname(temp),1,6);
     writefont(80+fontlen(str1),(temp-1)*8+10,'K'+txt(hillkr(temp)));
    fontcolor(240);
    writefont(75,(temp-1)*8+10,str1);
   end;

  inc(temp,2);
   ewritefont(71,(temp-1)*8+10,'0.');
   writefont(75,(temp-1)*8+10,'EXIT');

  DrawScreen;

  index:=MakeMenu(60,11,80,8,20,1,243,0,0);

  if (index=0) then leave:=true
               else edithill(h[index],filestr,false);

 until (leave);

 assign(f1,'HILLBASE.SKI');
 rewrite(f1);

 writeln(f1,'-HILLBASE.SKI- DO NOT ATTEMPT TO EDIT THIS FILE!');

 for temp:=1 to 20 do
  begin

   writehill(f1,h[temp],temp,0);

  end;

  writeln(f1,'*** End of Base File ***');

  close(f1);

 leave:=false; index:=1; { ihan vaan kun se on ollut v„h„n sekaisin... }

end;
*)


procedure CheckExtraHills;
var DirInfo : TSearchRec;
    f1 : text;
    temp : integer;
    filenames : array[0..MaxExtraHills] of string[12];

begin
 NumExtraHills:=0;

 for temp:=0 to MaxExtraHills do filenames[temp]:='';

 if FindFirst ('*.SJH',faAnyFile,DirInfo)=0 then
 begin
   repeat
     if (NumExtraHills < MaxExtraHills) then
     begin
       temp:=1;

       inc(NumExtraHills);

       while (DirInfo.Name[temp]<>'.') do
       begin
         filenames[NumExtraHills]:=filenames[NumExtraHills]+DirInfo.Name[temp];
         inc(temp);
       end;
     end;
   Until FindNext(DirInfo)<>0;

   FindClose(DirInfo);
 end;

 Assign(f1,'MOREHILL.SKI');
 ReWrite(f1);

 writeln(f1,NumExtraHills);

 for temp:=1 to NumExtraHills do
  writeln(f1,filenames[temp]);

 Close(f1);

end;




procedure LoadHillInfo;  { t„ll„ ladataan mnimet ja kri -taulut kuntoon }
var f1 : text;
    temp : byte;
    NowHill : hill_type;
    filename : string;

begin

 filename:='MOREHILL.SKI';

 assign(f1,filename);

 {$I-}
 reset(f1);
 {$I+}
 FileOk(IOResult, filename);

 readln(f1,NumExtraHills);

 close(f1);

 for temp:=1 to NumWCHills+NumExtraHills do
  begin
   LoadInfo(temp,NowHill);
   HD[temp]^.Name:=NowHill.Name;
   HD[temp]^.Kr:=NowHill.Kr;
  end;

 NumHills:=NumWCHills+NumExtraHills;

end;


{procedure chooselanguage; }



procedure choosewindplace(var place:byte);
var index, apu1, yy : integer;
    str1 : string;
const winds : byte = 11;
begin

 fillbox(54,19,276,181,248);
 fillbox(55,20,275,180,243);

 fontcolor(246);
 writefont(75,30,lstr(221));

 for apu1:=1 to winds do
  begin
   yy:=apu1*10+34;
   { 390-top, 391-middle, 392-bottom, 393-left, 394-center, 395-right, 396-jpr }
   case apu1 of
    1 : str1:=lstr(392)+'-'+lstr(393);
    2 : str1:=lstr(391)+'-'+lstr(393);
    3 : str1:=lstr(392)+'-'+lstr(395);
    4 : str1:=lstr(392)+'-'+lstr(394);
    5 : str1:=lstr(391)+'-'+lstr(395);
    6 : str1:=lstr(390)+'-'+lstr(395);
    7 : str1:=lstr(390)+'-'+lstr(394);
    8 : str1:=lstr(390)+'-'+lstr(393);
    9 : str1:=lstr(396)+': '+lstr(390);    { oikeasti 11 }
   10 : str1:=lstr(396)+': '+lstr(391);    { 12 }
   11 : str1:=lstr(396)+': '+lstr(392);    { 13 }
   end;

   fontcolor(246);
   ewritefont(85,yy,txt(apu1)+'.');
   fontcolor(240);
   writefont(90,yy,str1);

  end;

   inc(yy,20);
   fontcolor(246);
   ewritefont(85,yy,'0.');
   fontcolor(240);
   writefont(90,yy,lstr(154));

  apu1:=place; if (apu1>10) then dec(apu1,2);

  index:=makemenu(70,44,140,10,winds,apu1,243,4,0);

  if (index>8) then inc(index,2);

  if (index>0) then place:=index;

end;


procedure WriteExtras; { kirjoitetaan extrahillsien hillrecit }
var temp, index : integer;
begin

 for temp:=1 to NumExtraHills do
  begin
   index:=temp+NumWCHills;
   WriteExtraHillHR(index);
  end;

end;

procedure ReadExtras;
var temp,index : integer;
    h : Hill_type;
begin

 for temp:=1 to NumExtraHills do
  begin
   index:=temp+NumWCHills;
   LoadInfo(index,h);
   HD[index]^.HRname:=h.HRname;
   HD[index]^.HRlen:=h.HRlen;
   HD[index]^.HRtime:=h.HRtime;
  end;

end;




function mightdelete(filestr:string):byte;
var f1 : text;
    tempb : byte;

begin

 tempb:=1;

 alertbox;

 writefont(75,90,lstr(194)+' '+filestr);
 writefont(75,110,lstr(193)+' ('+lch(6,1)+'/'+lch(7,1)+')');

 getch(220,110,243,ch,ch2);

 if (upcase(ch) = upcase(lch(6,1))) then
  begin

   assign(f1,filestr);
   {$I-}
   reset(f1);
   {$I+}
   if (IOResult=0) then
    begin
     close(f1);
     erase(f1);
     tempb:=0; { yep, deleted }
    end;
  end;

{       command:='/C DEL '+filestr+' > NUL:';
       SwapVectors;
        Exec(GetEnv('COMSPEC'),Command);
       SwapVectors; }
{       if (DosError <> 0) then
        begin
         fillbox(60,60,260,120,244);
         writefont(80,70,'OK, THIS DELETE THING');
         writefont(80,80,'IS A LITTLE STRANGE.');
         writefont(80,90,'I GOT DOSERROR '+txt(doserror)+'.');
         writefont(80,100,'PLEASE REPORT ME. THANKS.');
         DrawScreen;
         Readkey;
        end; }

 clearchs;

 mightdelete:=tempb;

end;




procedure HillMaker(phase:byte);

const show = 18;

var h : hill_type;
    filestr : string;
    items, temp, temp2, index : integer;
    create, next, prev : byte;

    start : integer;

    str1 : string;
    edit, newfile, leave : boolean;
    f1 : text;
{    tempch : char; }
    cols : array [1..3] of integer;

begin

 index:=1;

 start:=0; { sivulis„ys... }

 cols[1]:=100;
 cols[2]:=160;
 cols[3]:=300;

 newfile:=false;

{
 writefont(1,1,txt(DosError));
 drawscreen;
 readkey;
}

 repeat

  NewScreen(5,0);
  create:=0; next:=0; prev:=0; { koodeja... }

  fontcolor(246);
{  writefont(100,10,lstr(271)); }
  writefont(5,5,lstr(270));
{  writefont(1,1,txt(DosError)); }

  fontcolor(241);
  writefont(5,21,lstr(271));
  writefont(5,29,lstr(272));


  fontcolor(247);

  str1:=txt(1+(start div show))+' '+lstr(8)+' '+txt((numextrahills-1) div show+1);

  writefont(5,45,lstr(157)+' '+str1);
  writefont(cols[1],5,lstr(273));
  writefont(cols[2],5,lstr(274));

  fontcolor(240);

  temp:=0;

  temp2:=NumExtraHills-start;
   if (temp2>show) then temp2:=show;

  items:=temp2;

  if (NumExtraHills>0) then
   for temp:=1 to temp2 do
    begin
     str1:=nsh(hillname(start+temp+NumWCHills)+' K'+txt(hillkr(start+temp+NumWCHills)),150);
    { ewritefont(300,5+temp*8,str1); }
     writefont(cols[1],5+temp*8,hillfile(start+temp));
     writefont(cols[2],5+temp*8,str1);
    end;

  if (NumExtraHills<MaxExtraHills) then
   begin
    fontcolor(246);
    inc(temp); inc(items); create:=items;
    writefont(cols[1],5+temp*8,lstr(275)); { * add new * }
   end;

  fontcolor(247);

  if (start+temp2 < NumExtraHills) then
   begin
    inc(temp); inc(items); next:=items;
    writefont(cols[1],5+temp*8,lstr(158)); { * next page * }
   end;

  if (start > 0) then
   begin
    inc(temp); inc(items); prev:=items;
    writefont(cols[1],5+temp*8,lstr(159)); { * previous page * }
   end;

   fontcolor(240);

   inc(temp,2);
   writefont(cols[1],5+temp*8,lstr(276));

   DrawScreen;

   index:=MakeMenu(99,14,221,8,items,1,243,1,0);

   leave:=false;

   if (index<0) and (abs(index)+start<=NumExtraHills) then { delete? }
    begin
     filestr:=hillfile(abs(index)+start)+'.SJH';

     if (mightdelete(filestr) = 0) then
      begin
       CheckExtraHills;
       LoadHillinfo;
      end;
    end;

   if (index>0) then
    begin

     edit:=false;

     if (index=next) then inc(start,show);
     if (index=prev) then dec(start,show);

     if (index=create) then
      begin
       filestr:='NEW'+txt(index+start);
       defaulthill(h);
       edit:=true;
       newfile:=true;
      end;

     if (index<=temp2) then { uusi }
      begin
       loadinfo(start+index+NumWCHills,h);
       filestr:=hillfile(start+index);
       edit:=true;
      end;

     if (edit) then
      begin
       edithill(h,filestr,newfile);

       if (filestr<>'NULL') then { sitten kirjoitetaan p„„lle }
        begin
         {$I-}
         assign(f1,filestr+'.SJH');
         rewrite(f1);
         {$I+}
         if (IOResult=0) then
          begin
           writehill(f1,h,0,0); { file aukesi ok }
           close(f1);
          end;

         newscreen(5,0);
         resultbox(3,IOResult);

       end;

       checkextrahills;
       loadhillinfo;
      end;

    end;

   if (index=0) then leave:=true;

 until (leave);

end;


function injured:shortint;
var temp1 : shortint;
begin
{ v3.00 classified - top secret change!
 case random(4) of
 0,1 : temp1:=0;
 2   : temp1:=1;
 3   : temp1:=random(4)+1;
 end;
}

 case random(5) of
 0,1,2 : temp1:=0;
 3   : temp1:=1;
 4   : temp1:=random(4)+1;
 end;


 injured:=temp1;

{ injured:=5; }

end;


function makeletter(temp:integer):char;
var tempch:char;
 begin

 tempch:=' ';

  case temp of
   1 : tempch:='E'; { Early Takeoff }
   2 : tempch:='L'; { Slow Landing }
   3 : tempch:='F'; { Fall }
   4 : tempch:='D'; { Did not show }
   5 : tempch:='H'; { Hillrecord }
   6 : tempch:='t'; { Telemark-landing }
   7 : tempch:='r'; { Two Footed landing }
  end;

 makeletter:=tempch;

end;


function dayandtime(d1:Date;t1:Time):string;
var str1,str2 : string;
const days : array [0..6] of string[4] =
 ( 'Sun','Mon','Tue','Wed','Thu','Fri','Sat' );
      months : array[1..12] of string[5] =
 ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

 begin

 str2:=txt(d1.Day);
 if d1.Day<10 then str2:=' '+str2;

  str1:=days[d1.DayofWeek]+' '+str2+' '+months[d1.Month]+' '+txt(d1.Year)+' ';
  if t1.Hour<10 then str1:=str1+' ';
   str1:=str1+txt(t1.Hour)+':';
  if t1.Minute<10 then str1:=str1+'0';
    str1:=str1+txt(t1.Minute);

    dayandtime:=str1;
 end;



Function waitforkey3(xx,yy:integer;var ch:char):boolean;
var tempboole : boolean;
{    ch2 : char; }

begin

{ if (place=1) then yy:=191; }

 while SDLPort.KeyPressed do SDLPort.WaitForKeyPress(ch,ch2);

 tempboole:=false;

 fontcolor(240);

 ewritefont(xx,yy,lstr(15));

 getch(xx+1,yy,243,ch,ch2);

  if (ch=#0) and (ch2=#68) then begin tempboole:=true; ch:=#27; end;

 waitforkey3:=tempboole;

end;


function quitting(phase:byte):byte;
               { 0-main menu, 1-world cup }
var str1, str2 : string;
    tempb : byte;
begin

 str1:=lrstr(251,253);
 if (phase=1) then str1:=lstr(245);
 str2:=lrstr(256,258);

 alertbox;

 tempb:=fontlen(str2)+4;

 fontcolor(241);
 writefont(70+tempb,110,'('+lch(6,1)+'/'+lch(7,1)+')');

 inc(tempb,25);

 fontcolor(246);

 writefont(70,90,str1);
 writefont(70,110,str2);

 getch(70+tempb,110,243,ch,ch2);

 tempb:=1;
 if (upcase(ch) = lch(6,1)) then tempb:=0;
 clearchs;

 quitting:=tempb;

end;


procedure teamwarning;
begin

{ alertbox; }

 fillbox(59,59,261,141,242);
 fillbox(60,60,260,140,244);

 fillarea(60,60,260,140,63);

 fontcolor(246);

 writefont(80,72,lstr(261));
 writefont(80,82,lstr(262));
 writefont(80,92,lstr(263));
 writefont(80,112,lstr(264));
 writefont(80,122,lstr(265));

 drawscreen;

 waitforkey;

end;



Function Luehaalarit(index,col:byte):byte;
var { ch : char; }
    old : byte;
    y : integer;
begin

  fillbox(145,50,318,60,243);
  fillarea(145,50,318,60,64);
  fillbox(145,180,318,195,243);
  fillarea(145,180,318,195,64);

  fontcolor(241);
  writefont(170,51,lstr(149)+':');
{  fontcolor(241); }
  writefont(150,185,lstr(150));

  old:=col;  { vanha v„ri }

  LoadSuit(col,0);
   AsetaPaletti;

  y:=(index-1)*9+64;

  fillbox(300,y-2,314,y+8,242);
  fillbox(302,y,312,y+6,218);
  fillbox(303,y+1,311,y+5,216);

  drawscreen;

 repeat

  LoadSuit(col,0);
   AsetaPaletti;

  SDLPort.WaitForKeyPress(ch,ch2);

   if (ch=#0) then
    begin
     ch:=readkey;
      if ((ch=#72) or (ch=#75)) and (col>0) then dec(col);
      if ((ch=#80) or (ch=#77)) and (col<6) then inc(col);
    end;

 until (ch=#13) or (ch=#27);

 if (ch=#27) then col:=old;

 Luehaalarit:=col;

end;


Function crypt(arvo:longint;jarj:integer):string;
var str1,str2 : string;
    index : byte;
begin

 str(arvo,str1);

 if (length(str1)<5) then for index:=1 to 5-length(str1) do str1:='0'+str1;

 str2:='';

 for index:=5 downto 1 do
   str2:=str2+chr(ord(str1[index])+21);

 str1:=chr(68+2*(arvo mod 7 xor 1));  { tarkistusluku arvosta }
 insert(str1,str2,2);
 str1:=chr(65+((jarj xor 33) mod 19));  { tarkistusluku j„rjestyksest„ }
 insert(str1,str2,3);
 str1:=chr(68+random(6));  { ihan vaan satunnainen kirjain }
 if (length(txt(arvo))>5) then str1:=chr(ord(str1[6])+27);
 insert(str1,str2,5);
{  insert('*',str2,5); }

 crypt:=str2;

end;



function uncrypt(str0:string;jarj:integer):longint;
var str1 : string;
    high,chk1,chk2 : char;
    luku1 : longint;
    luku2 : integer;
    index : byte;

begin

 high := str0[5]; { satunnainen kirjain, tai yli 100 000 }
 delete(str0,5,1);{ pois }
 chk1 := str0[2];
 delete(str0,2,1);
 chk2 := str0[2];
 delete(str0,2,1);

{ writeln('J„i: ',str0); }

 str1:='';

 for index:=5 downto 1 do
   str1:=str1+chr(ord(str0[index])-21);

 val(str1,luku1,luku2);

 if (ord(high)>74) then  { ei pelkk„ satunnaiskirjain }
  begin
   luku1:=(100000*(ord(high)-75))+luku1;
  end;

 str1[1]:=chr(68+2*(luku1 mod 7 xor 1));
 if (str1[1]<>chk1) then luku1:=0;
 str1[1]:=chr(65+((jarj xor 33) mod 19));
 if (str1[1]<>chk2) then luku1:=0;

 uncrypt:=luku1;

end;


function valuestr(str0:string;arvo:integer):word;
var word1,index:word;
begin

 word1:=0;

 for index:=1 to length(str0) do
  begin
{    inc(word1,(ord(str0[index]))); }
{   inc(word1,((ord(str0[index])-63)*((index mod 5)+41))); }
    inc(word1,((ord(str0[index]))*((index mod 5)+41)))
{   write(index mod 5,':',ord(str0[index]),':',word1,', ');}

  end;

 valuestr:=word1*(arvo mod 7+1)+arvo;

end;


function svaluestr(str0:string;arvo:integer):word;
var word1,index:word;
begin

 word1:=0;

 for index:=1 to length(str0) do
  begin
{    inc(word1,(ord(str0[index]))); }
{   inc(word1,((ord(str0[index])-63)*((index mod 5)+41))); }
   case str0[index] of
{   'A'..'Z','a'..'z','0'..'9',' ','.' : inc(word1,((ord(str0[index]))*((index mod 5)+41))); }
   'A'..'Z','a'..'z','0'..'9' : inc(word1,((ord(str0[index]))*((index mod 5)+41))); { v3.10 }
   else inc(word1,3);
   end;

{   write(index mod 5,':',ord(str0[index]),':',word1,', ');}

  end;

 svaluestr:=word1*(arvo mod 7+1)+arvo;

end;


procedure mainmenutext(phase:byte;version:string);
var x,y, temp, num : integer;
begin

  x:=11;
  fontcolor(246);

  fillbox(11,80,11+fontlen(lstr(17)),85,8);
{  fillarea(11,80,11+fontlen(lstr(17]),85,63); }

  writefont(x,80,lstr(17+phase));

  fontcolor(240);

 if (phase=1) then
  begin

   FillBox(1,94,116,199,8);
{   FillArea(2,51,149,179,63); }

   for temp:=1 to 7 do
    begin
     y:=86+temp*12;
     num:=temp;
     if (temp=7) then begin inc(y,12); num:=0; end;
{$IFNDEF REG}
     if (temp=4) then fontcolor(241);
{$ENDIF}
     if (temp=5) then fontcolor(240);
     writefont(x,y,txt(num)+' - '+lstr(temp+26));
    end;

  end;


 if (phase=0) then
  begin
   for temp:=1 to 7 do
    begin
     y:=86+temp*12;
      num:=temp;
     if (temp=7) then begin inc(y,12); num:=0; end;

     writefont(x,y,txt(num)+' - '+lstr(temp+19));

    end;

{   fontcolor(241); }

(*
{   fillbox(268,6,308,12,104); }
   fillbox(268,6,307,11,164);
{   fillbox(245,18,308,24,134); }
   fillbox(245,18,307,23,165);
   fillbox(245,30,269,35,166);
*)

  end;

   ewritefont(308,6,'SKI JUMP');
   ewritefont(308,18,'INTERNATIONAL');
   writefont(245,30,'v'+version);

end;


procedure newregtext(regname,regnumber:string);
begin

{  fillbox(130,155,310,155,9); }
  fillbox(128,155,312,155,9);

  fontcolor(240);

  writefont(132,163,lstr(35)+' '+lstr(36));

{  writefont(150,150,lstr(35]);
   writefont(150,160,lstr(36]); }

{  writefont(170,140,lstr(36]); }
  fontcolor(246);
{  fillbox(139,172,311,197,250);
  fillbox(140,173,310,196,245); }

{  fillarea(140,173,310,196,63); }

  fillbox(132,175,308,196,248);

  writefont(140,177,regname);
  { writefont(140,187,'#'+regnumber); }

  DrawScreen;

end;




procedure newunregtext;
var temp : integer;
begin

  fillbox(130,120,310,120,9);

  fontcolor(240);
  writefont(150,130,lstr(38));
  writefont(150,140,lstr(39));

  temp:=(random(3)*2)+41;

  fontcolor(246);

   writefont(150,155,lstr(temp));
   writefont(150,165,lstr(temp+1));

  fontcolor(240);
  writefont(150,180,lstr(40));

  DrawScreen;

end;


procedure unregendtext;
begin
 gotoxy(2,10);
 cwrite(8,'- You have been playing an '); cwrite(31,'UNREGISTERED');
 cwriteln(8,' version of SJ3.  ');
{
 writeln('   To rule the Universe and register SJ2, send 50 FIM or 10$ USD to ');
 writeln('   Ville K”n”nen, Kalliopurontie 21 D 24, 02920 Espoo, Finland');
 write('   For an easier Internet registration or other details, see ');
 cwriteln(15,'REGISTER.TXT');
}

 write('   Please do the right thing,');
 writeln(' register SJ3!  It''s cheap and easy, ');
 write('   read '); cwrite(15,'REGISTER.TXT');
 cwriteln(8,' for step-by-step instructions.');

end;


procedure regendtext(regname,regnumber:string);
begin
 gotoxy(2,10);
 cwrite(8,'- YOU RULE!!!');
 writeln('  This version is registered to Everyone. ');
 textcolor(15);
 cwriteln(8,'   Thanks for all the support!!!');
 
{ write('  This version is registered to: ');
 textcolor(15);
 writeln(sh(regname,25),' #',regnumber);
 cwriteln(8,'   Thanks a million for registering.  I wish all users were like you.');
 writeln('   (But if you''re not ',sh(regname,32),', you should be ashamed.)');
 }
 
end;



procedure lopputext(version:string;a1,a2:Time);
var out : Time;
    temp1, temp2, diff : longint;

begin

   textcolor(0);
   gotoxy(69,2);write(' Ûß Û');
   gotoxy(69,3);write(' Û  Û');
   gotoxy(69,4);write('ÜÛ ÜÛ');

   textcolor(4);
   gotoxy(75,2);write('ßÛ');
   gotoxy(75,3);write('þÛ');
   gotoxy(75,4);write('ÜÛ');


   temp1:=longint(a1.second)+longint(a1.minute)*60+longint(a1.hour)*3600;
   temp2:=longint(a2.second)+longint(a2.minute)*60+longint(a2.hour)*3600;

   if (temp2 < temp1) then inc(temp2,86400);

   diff:=temp2-temp1;

   out.hour:=diff div 3600;
   out.minute:=(diff div 60)-(out.hour*60);
   out.second:=diff-(diff div 60)*60;

  gotoxy(2,2);
  cwrite(15,'- You played SJ3 v'+version+' for');

  if (out.hour>0) then
   begin
    write(' ',out.hour,' hour');
    if (out.hour>1) then write('s');

    if (out.minute>0) and (out.second>0) then write(',')
     else if (out.minute>0) or (out.second>0) then write(' and');

   end;

  if (out.minute>0) then
   begin
    write(' ',out.minute,' minute');
    if (out.minute>1) then write('s');
    if (out.second>0) then write(' and');
   end;

  if (out.second>0) then
   begin
    write(' ',out.second,' second');
    if (out.second>1) then write('s');
   end;

  if (out.hour=0) and (out.minute=0) and (out.second=0) then write(' no time at all');
  writeln('. ');

 gotoxy(2,4);
 cwriteln(8,'- Play original DOS version if you aim for the');
 cwrite(8,'   Universal Hall of Fame.');

 gotoxy(2,7);
 cwriteln(15,'- Be sure to check out the Official Ski Jump International');
 write('   webpage located at  ');
 cwrite(8,'http://www.nomasi.com/sj3/');

  window(1,16,80,19);
  textbackground(1);
   clrscr;
  writeln;
  cwriteln(9,'   Quote of the moment: ');
  cwrite(15,'   ');

  case random(40) of
  0 : writeln('Drama, excitement, speed, life, Ski Jump International.');
  1 : writeln('"I traded K.I.T.T for Ski Jump International" - M. Knight');
  2 : writeln('"Ski Jump International is out there" - F. Mulder');
  3 : writeln('NSA, CIA, FBI, INTERPOL, SJ3 = ass-kicking action all the way');
  4 : writeln('Ski Jump International - for the love of flying since 1994');
  5 : writeln('"Only nuclear testing is more fun than SJ3" - J. Chirac');
{  6 : writeln('"We tried to add SJ3 to our new mobile, but it was too cool" - J. Ollila'); }
  6 : writeln('"Our new phone had SJ3 in it and nobody used it for talking" - J. Ollila');
  7 : writeln('"Only exploiting Nigeria is more addictive than SJ3" - Shell Inc.');
  8 : writeln('"Only exploiting the Amazonas is more fun than SJ3" - Texaco');
  9 : writeln('"There shall be no tobacco advertising in SJ3" - European Union');
 10 : writeln('S.J.3. - four letters that deliver pure enjoyment');
 11 : writeln('Genesis, Exodus, Leviticus, Numeri, Deuterononium, SJ3');
 12 : writeln('"SJ3 was not the reason for our comeback" - Spice Girls');
 13 : writeln('"SJ3 can be explained with modern science" - D. Scully');
 14 : writeln('"There is no cleaner sport than SJ3" - J. Samaranch');
 15 : writeln('"We have warned SJ3 for it''s refusal to allow weapons inspectors" - USA');
 16 : writeln('"SJ3 is a neo-communist plot and it must be stopped at any cost" - J. Helms');
 17 : writeln('"Half of USA''s 396 Billion Dollar defense budget is spent on SJ3 regs"');
 18 : writeln('"I made SJ3 out of fertilizer and window cleaner" - MacGyver');
 19 : writeln('"Salt Lake City offered $700 000 in bribes to get into SJ3" - D. Pound');
 20 : writeln('"SJ3 played a key part in our struggle for independence" - X. Gusmao');
{ 21 : writeln('"Only blind retributions are more fun than SJ3" - G. W. Bush '); }
 21 : writeln('"We''ll bomb and invade any nation that uses pirate SJ3''s!" - G.W.Bush');
 22 : writeln('Engineered with love and tradition from 1994 - SJ3');
 23 : writeln('VX ANTHRAX AK-47 NWO FNORD G-7 NSA SJ3 PGP PRISM BLANKET IRA PLUTONIUM');
 24 : writeln('"SJ3 is the only reason why I still use a Microsoft OS" - L. Torvalds');
 25 : writeln('"SJ3 is banned in China for it''s pro-Tibetian views" - J. Zemin');
 26 : writeln('"SJ3 is the last beacon of free press in Russia" - V. Guzinsky');
 27 : writeln('SJ3 - no sex, no drugs, no violence - just the love of flying');
{ 27 : writeln('"SJ3 is being investigated for terrorist links" - CIA'); }
{ 28 : writeln('"SJ3 is a great comfort "- N. Chomsky & S. Sontag'); }
 28 : writeln('"I am still the greatest, but SJ3 is getting damn close" - M. Ali');
 29 : writeln('"I pity the fool who doesn''t play SJ3" - Mr.T');
 30 : writeln('S is for Serenity, J is for Joy and 3 is for ... a Free Palestine!');
{ 31 : writeln('"I own 13 Uzis, 10 shotguns and one SJ3. Try to rob me now." - C. Heston'); }
 31 : writeln('"We didn''t join the Euro as we can buy SJ3 with any currency" - DK, SE & UK');
 32 : writeln('H2O, CO2, O2, SJ3 - stuff I can''t live without');
 33 : writeln('Sex, drugs & SJ3');
 34 : writeln('"The downloads of SJ3 are monitored because of its suspicious content" - NSA'); { max length }
 35 : writeln('SJ3 - almost as addictive as Coca-Cola and almost as fattening as McDonald''s');
 36 : writeln('"SJ3 is more magic than me" - D. Blaine');
 37 : writeln('"New Europe doesn''t need democratic decisions, it needs SJ3." - D. Rumsfeld');
 38 : writeln('"As soon as I own SJ3, it will start to love me too." - S. Berlusconi');
 39 : writeln('"I have never overstated anyones weapons or games.  SJ3 is god." - T. Blair');
 40 : writeln('"SJ3 inspired me to admit that we are illegal occupiers." - A. Sharon');
{ 41 : writeln('"SJ3 is the only thing that separates us from animals.  Except SJ3." - H. Simpson'); }

  end;

  textcolor(7);

   window(1,1,80,25);

  gotoxy(1,22);

end;

Procedure drawat(col1,col2,a,kr:integer;name:string);
begin
 textcolor(col1); textbackground(col2);

 gotoxy(28,2+a);
  if (kr>0) then write('    ',a,'. ',name,' K',kr,'    ')
   else write(' ** ',a,'. ',name,' ** ');

end;


Function choosehill(mmaara:byte):byte;
var a,b:byte;
{    ch : char; }

begin

   for a:=1 to mmaara do
    drawat(14,1,a,HD[a]^.Kr,HD[a]^.Name);

  a:=1;

 repeat

   drawat(1,11,a,HD[a]^.Kr,HD[a]^.Name);

   gotoxy(32,2+a);

   SDLPort.WaitForKeyPress(ch,ch2);

    b:=a;

   if (ch=#0) then
     case ch2 of
      #80 : if a<mmaara then inc(a);
      #72 : if a>1 then dec(a);
      #71 : a:=1;
      #79 : a:=mmaara;
 {     ' ','+' : if ht[f]=1 then ht[f]:=0 else ht[f]:=1; }
     end;

     if (a<>b) then drawat(14,1,b,HD[b]^.Kr,HD[b]^.Name);

  until (ch=#27) or (ch=#13);

 if (ch=#27) then a:=255;

  window(1,1,80,25);

  choosehill:=a;

end;

procedure NewHDs;
var temp : integer;
begin

 for temp:=0 to NumWCHills+MaxExtraHills do
  New(HD[temp]);

end;

procedure Init;
begin

 NewHDs;
end;

end.
