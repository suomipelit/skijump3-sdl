unit sj3info; { pelaaja & profiili-infoa }

 {$I REGSTAT.PAS}

interface { -------------------------------------------------------------- }

uses maki,{crt,} windos, sj3unit, sj3help, sj3graph, sj3lang, sj3pcx;

const NumHiscores = 61; { 1-20=WC + 21-30=TC + 31-35=4h + 36-41=KOTH + 42-61=CC }

type Profile_type = record
      name, realname : NameStr;
      suitcolor, skicolor, kothlevel, replace, bestwchill, besthill, cstyle,skipquali : byte;
      bestwcjump, bestpoints, best4points, bestjump : word;
      besthillfile : string[12];
      bestresult, best4result : string[20];
      wcs, legswon, wcswon, totaljumps : longint;
     end;

var top : array[0..NumHiscores] of Hiscore;
    nimet : array[0..NumPl+1] of NameStr;
    jnimet : array[0..NumTeams] of NameStr;

    pmaara : byte;

    NumProfiles : byte; { piilota alas }

    profileorder : array[0..20] of byte;
    profile : array[0..20] of Profile_type; { ehk„ my”s }

(*    HR : array[0..NumWCHills+MaxExtraHills] of Hillrec; { uusi 3.10 } *)

procedure LoadNames(whatset:char;
                    teamdiscount:byte;
                    var teamlineup:array of byte;
                    replaces:boolean);

procedure profiles;

procedure chooseseecomps(var seecomps:byte);
procedure welcomescreen(var languagenumber:byte);

procedure WriteProfiles;
procedure LoadProfiles;
procedure ResetTops(kerroin:byte;Today:Date;Now:Time);
{procedure loadcustomrecord(SetFile:string;var sortby:byte); }

{procedure writecustomrecord(SetFile:string;sortby:byte); }

function loadcustom(SetFile:string;var sortby:byte;
                    var HillOrder:array of integer;
                    var CupHills:integer):longint;

function writecustom(SetFile:string;sortby:byte;
                     HillOrder:array of integer;CupHills:integer):integer;


procedure FindCustoms(var NumCustoms:integer;
                      var Filenames:array of FileStr);

procedure selectcustomhills(var sortby:byte;var CupHills:integer;
                            var HillOrder : array of integer;
                            var SetFile:string);

procedure newcrecordscreen(SetFile:string;NewHi,OldHi:Hiscore;sortby:byte);

procedure CallSendme(version,regname,regnumber:string;
                     Today:date;Now:Time; vcode:byte);

procedure drawmainmenu;

implementation { ********************************************************* }

{$IFDEF REG}
const maxcustomhills = 40;
{$ELSE}
const maxcustomhills = 5;
{$ENDIF}

var maxprofiles, maxpmaara : integer;


procedure defaulthi(var hi:hiscore);
begin

 with hi do
  begin
   name:='Nobody';
   pos:=0;
   score:=0;
   time:='-';
  end;

end;


function loadcustom(SetFile:string;var sortby:byte;
                    var HillOrder:array of integer;
                    var CupHills:integer):longint;

var temp,temp2,nytmaki : integer;
    str1:string;
    f2 : text;
    code, checksum, compare, compare2 : longint;

begin

 {$I-}
 assign(f2,Setfile+'.SJC');
 reset(f2);
 {$I+}

{ defaulthi(Hi); }

 code:=0;
 checksum:=0; compare:=0; compare2:=0;

 for temp:=1 to 20 do defaulthi(top[temp+41]);

 if (IOResult=0) then
  begin
   sortby:=0;
   {$I-}      { ei niin v„li„ vaikkei l”ytyisik„„n }

   readln(f2,Cuphills);

   temp:=0;

   repeat

    readln(f2,nytmaki);

    if (nytmaki>NumWChills) then
     begin
      nytmaki:=-1;
      readln(f2,str1);

      if (numextrahills>0) then
        for temp2:=1 to numextrahills do
         if (hillfile(temp2) = str1) then nytmaki:=temp2+NumWChills;

     end;

    if (nytmaki>0) then
     begin
      inc(temp);
      HillOrder[temp]:=nytmaki;
     end;

   until (nytmaki=0) or (temp>=40);

   if (temp>=40) then { se lopettava nolla pois }
    begin
     readln(f2,nytmaki);
     while (nytmaki<>0) do readln(f2,nytmaki);
    end;

   CupHills:=temp;
   if (CupHills=0) then code:=-1;

   for temp:=1 to 4 do readln(f2,str1); { v3.10 enkka pois alta }

   readln(f2,sortby);
   if (sortby<>1) then sortby:=0;

   readln(f2,str1);
   val(str1,code,temp); { luetaan code }
   if (code=0) and (temp<>0) then code:=1;

   { v3.12 lis„ys #1 start / ei lueta codea vaan lasketaan se }
   compare2:=0;
   inc(compare2,svaluestr(upstr(setfile),11)*13+1);

   for temp:=1 to CupHills do
    begin
     inc(compare2,hillcode(Hillorder[temp]) mod 193557);
    end;

   compare2:=compare2 xor (566727+sortby*2);

   { v3.12 lis„ys end }

   readln(f2,str1);

   for temp:=1 to 20 do
   if (not eof(f2)) then
    with top[temp+41] do
     begin
      readln(f2,name); inc(checksum,svaluestr(name,temp));
      readln(f2,pos); inc(checksum,(pos+temp)*11);
      readln(f2,score); inc(checksum,(score+temp+1)*3);
      readln(f2,time);
     end;

   readln(f2,str1);
   compare:=0;
   val(str1,compare,temp);

   checksum:=checksum xor 131333;

   if (compare<>checksum) or (compare2<>code) then
    for temp:=1 to 20 do
     defaulthi(top[temp+41]);

   { v3.12 muutos #2 start / yksi uusi checksum (sis. code) }

   readln(f2,str1); { luetaan se jos sit„ on }
                    { t„st„ seuraa ett„ v3.11:n SJC nollautuu v3.12:ssa! }
   compare:=0;
   val(str1,compare,temp);

   checksum:=checksum xor 131333;
   checksum:=((checksum + 5 + code)*2) xor 356777;

   if (compare<>checksum) then
    for temp:=1 to 20 do
     defaulthi(top[temp+41]);
   { v3.12 muutos #2 end }

   {$I+}

   close(f2);

  end;

 loadcustom:=code;

end;



function writecustom(SetFile:string;sortby:byte;
                     HillOrder:array of integer;CupHills:integer):integer;

var temp,result : integer;
    str1:string;
    checksum, code : longint;
    f2 : text;

begin

 {$I-}
 assign(f2,Setfile+'.SJC');
 rewrite(f2);
 {$I+}

 checksum:=0;
 result:=1;

 if (IOResult=0) then
  begin

   code:=0; { SJC:n m„kij„rkk„koodi }
   setfile:=upstr(setfile);

   writeln(f2,CupHills);
   inc(code,svaluestr(setfile,11)*13+1);

   for temp:=1 to CupHills do
    begin
     writeln(f2,HillOrder[temp]);
     inc(code,hillcode(Hillorder[temp]) mod 193557);
     if (HillOrder[temp] > NumWCHills) then writeln(f2,hillfile(HillOrder[temp]-NumWCHills));
    end;

   code:=code xor (566727+sortby*2);

   writeln(f2,'0'); { endofhillsequence }

   writeln(f2,'v3.12 SJC'); { vanha enkkastandardi }
   writeln(f2,'0');
   writeln(f2,'0');
   writeln(f2,'-');

   writeln(f2,sortby); { uutta }

   writeln(f2,code);
   writeln(f2,'0');

   for temp:=1 to 20 do
    with top[temp+41] do
     begin
      writeln(f2,name); inc(checksum,svaluestr(name,temp));
      writeln(f2,pos); inc(checksum,(pos+temp)*11);
      writeln(f2,score); inc(checksum,(score+temp+1)*3);
      writeln(f2,time);
     end;

   checksum:=checksum xor 131333;
   writeln(f2,checksum);
   { v3.12 muutos #2 }
   checksum:=checksum xor 131333;
   checksum:=((checksum + 5 + code)*2) xor 356777;
   writeln(f2,checksum);

   result:=0;

   close(f2);

  end;

 writecustom:=result;

end;



procedure newcrecordscreen(SetFile:string;NewHi,OldHi:Hiscore;sortby:byte);
var tempb : boolean;
{    tempch : char; }
    str1 : string;
begin

 tempb:=true;
 if (Oldhi.score<=0) then tempb:=false;

 fillbox(54,59,276,135,248);
 fillbox(55,60,275,134,243);

 fontcolor(246);
 writefont(75,69,lstr(128));
 str1:=txt(newhi.score);
 if (sortby=1) then str1:=txtp(newhi.score);

 ewritefont(242,80,str1);

 fontcolor(240);
 writefont(85,80,nsh(newhi.name,90));
 ewritefont(200,80,txt(newhi.pos)+'.');

 fontcolor(241);
 writefont(95,87,newhi.time);
 writefont(75,100,lstr(129));

 if (tempb) then
  begin
   str1:=txt(oldhi.score);
   if (sortby=1) then str1:=txtp(oldhi.score);
   writefont(85,110,nsh(oldhi.name,90));
   ewritefont(200,110,txt(oldhi.pos)+'.');
   ewritefont(242,110,str1);
   writefont(95,117,oldhi.time);
  end
   else writefont(85,110,'-');

 drawscreen;

 waitforkey;

end;



procedure FindCustoms(var NumCustoms:integer;
                      var Filenames:array of FileStr);

var DirInfo : TSearchRec;
    Attr : word;
    temp3 : integer;
begin

 NumCustoms:=0;
 for temp3:=0 to Maxcustoms do FileNames[temp3]:='';

 Attr:=0;

 FindFirst('*.SJC', Attr, DirInfo);

 while (DosError = 0) and (NumCustoms < maxcustoms) do
  begin

   inc(NumCustoms);

   temp3:=0;

   while (DirInfo.Name[temp3]<>'.') do
    begin
     filenames[NumCustoms]:=filenames[NumCustoms]+DirInfo.Name[temp3];
     inc(temp3);
    end;

   if (filenames[NumCustoms] = 'TEMP') then
    begin filenames[NumCustoms]:=''; dec(NumCustoms); end;

   FindNext(DirInfo);

  end;

  DosError:=0;

end;



procedure selectcustomhills(var sortby:byte;var CupHills:integer;
                            var HillOrder : array of integer;
                            var SetFile:string);


var hill, x, y : integer;
{    max : byte; }
    tempstr : string;
    temphi : Hiscore;

{    cols : array[1..4] of integer;
    start, hill : integer;          }

 procedure dohill(num:integer;phase:byte); { 1 - valinnassa, 2 - saletti, 3 - del }
 var x : integer;
     str1 : string;
  begin

   y:=num*7+32;
   x:=17; if (num>20) then begin x:=162; dec(y,140); end;
   hill:=HillOrder[num];

   fillbox(x,y-1,x+142,y+7,248);

   if (phase=3) then
    begin
     fillbox(x,y-1,x+142,y+7,243);
     fillarea(x,y-1,x+142,y+7,63);
    end
     else
      begin
       fontcolor(246);
       if (phase=2) then ewritefont(x+14,y,txt(num)+'.');

       if (phase=1) then fontcolor(241);
       if (phase=2) then
        if (hill>NumWCHills) then fontcolor(253)
                             else fontcolor(240);

       str1:=nsh(hillname(hill),104);
       writefont(x+15,y,str1);
       if (phase=2) then fontcolor(247);
       writefont(x+18+fontlen(str1),y,'K'+txt(hillkr(hill)));
      end;

  end;

 procedure doscreen;
 var temp2:integer;
 begin
  NewScreen(2,0);

  fontcolor(240);
  writefont(68,8,lstr(118));

  fontcolor(241);
  writefont(78,16,lstr(119));

  writefont(78,23,lstr(285)+', '+lstr(286)+', '+lstr(287));
  writefont(78,30,lstr(288+sortby));

{
 fontcolor(247);
 writefont(40,24,lstr(141));
 writefont(295,24,lstr(142));
}
  if (CupHills>0) then
   for temp2:=1 to CupHills do dohill(temp2,2);

  drawscreen;
 end;


(*
 function loadcustom(filename:string):integer;
  var result : byte;
      nytmaki, temp1, temp2 : integer;
      str1 : string;
      ok : boolean;
      f1 : text;
  begin

   {$I-}
   assign(f1,filename);
   reset(f1);
   {$I+}
   result:=1;

   if (IOResult=0) then
    begin
     readln(f1,Cuphills);

     temp1:=0;

     repeat

      readln(f1,nytmaki);

      if (nytmaki>NumWChills) then
       begin
        nytmaki:=-1;
        readln(f1,str1);
        if (numextrahills>0) then
         begin
          for temp2:=1 to numextrahills do
           if (hillfile(temp2) = str1) then nytmaki:=temp2+NumWChills;
         end;
       end;

       if (nytmaki>0) then
        begin
         inc(temp1);
         HillOrder[temp1]:=nytmaki;
        end;

      until (nytmaki=0);

      {$I-}
      readln(f1,temphi.name);
      readln(f1,temphi.pos);
      readln(f1,temphi.score);
      readln(f1,temphi.time);
      sortby:=0;
      readln(f1,sortby); { v3.10:n SJC:ss„ t„t„ ei ole }
      if (sortby<>1) then sortby:=0; { jos se lukee v3.10sjc:st„ mit„ sattuu }
      {$I+}

     close(f1);

     CupHills:=temp1;
     if (CupHills>0) then result:=0;

    end;

   LoadCustom:=result;

  end;
*)

 function selectload:byte; { palauttaa: 0 - ladattu, 1 - ei }

 var filenames:array [0..maxcustoms] of FileStr;
     numcustoms, actcustom : integer;
     leave2 : boolean;
     temp2 : integer;
     tempb,result : byte;
     temphillorder : array[0..41] of integer;

  procedure nocustoms;
  begin
   resultbox(4,0);
  end;


 begin

 findcustoms(NumCustoms,Filenames);
 result:=1;

 if (numcustoms>0) then
   begin

   actcustom:=1;

   repeat

    loadcustom(filenames[actcustom],tempb,tempHillOrder,temp2); { just hi's }
    temphi:=top[42];

    leave2:=true; { v„liaikaisk„yt”ss„ }
    if (temphi.score=0) then leave2:=false;

    fillbox(74,69,246,151,248);
    fillbox(75,70,245,150,243);

    fontcolor(240);
    writefont(85,75,lstr(116));
     if (leave2) then writefont(95,130,nsh(temphi.name,90))
                 else writefont(95,130,'-');

    fontcolor(241);
    writefont(85,85,lstr(150));
    writefont(85,121,lstr(115));

     if (leave2) then
      begin
       writefont(95,139,temphi.time);
{       ewritefont(210,130,txt(temphi.pos)+'.'); }
      end;

    fillbox(85,95,180,115,245);
    ewritefont(220,102,txt(actcustom)+' / '+txt(numcustoms));
     fontcolor(246);
    writefont(95,102,filenames[actcustom]);
     tempstr:=txt(temphi.score);
     if (tempb=1) then tempstr:=txtp(temphi.score);

     if (leave2) then ewritefont(232,130,tempstr);

    leave2:=false;

    drawscreen;

    clearchs;
    readkbd(ch,ch2);

    if (ch='+') or (ch=' ') or (ch2=#77)  or (ch2=#80) then inc(actcustom);
    if (ch='-') or (ch2=#75) or (ch2=#72) then dec(actcustom);
    if (ch2=#71) then actcustom:=1;
    if (ch2=#79) then actcustom:=numcustoms;

    if (actcustom<1) then actcustom:=1;
    if (actcustom>numcustoms) then actcustom:=numcustoms;

    if (ch2=#83) then { delete! }
     begin
      if (mightdelete(filenames[actcustom]+'.SJC') = 0) then
       begin
        FindCustoms(NumCustoms,Filenames);
        actcustom:=1;
        setfile:='TEMP';
        if (numcustoms=0) then
         begin
          nocustoms;
          leave2:=true;
          end;
       end;
       doscreen;
     end;

    if (ch=#27) or (ch2=#68) then leave2:=true;

    if (ch=#13) then
     begin
      if (loadcustom(filenames[actcustom],sortby,HillOrder,CupHills) > 0) then
       begin
        leave2:=true;
        setfile:=filenames[actcustom];
        result:=0;
        {if (Cuphills <= max) then inc(Cuphills);}
       end;
     end;

   until (leave2);

  end else
   begin
    nocustoms;
   end;

  doscreen;
  clearchs;

  selectload:=result;

 end;

(*
 function savecustom(filename:string):integer;
 var f1 : text;
     temp2,result : integer;
     code : longint;

 begin
  result:=1;
  {$I-}
  assign(f1,filename+'.SJC');
  rewrite(f1);
  {$I+}
  code:=0;

  if (IOResult=0) then
   begin
    writeln(f1,CupHills);
    inc(code,svaluestr(filename,11)*13+1);

    for temp2:=1 to CupHills do
     begin
      writeln(f1,HillOrder[temp2]);
      inc(code,hillcode(Hillorder[temp2]) mod 193557);
      if (HillOrder[temp2] > NumWCHills) then writeln(f1,hillfile(HillOrder[temp2]-NumWCHills));
     end;

    code:=code xor (566727+sortby*2);

    writeln(f1,'0');

    defaulthi(temphi); { aina nollista }
    writeln(f1,temphi.name);
    writeln(f1,temphi.pos);
    writeln(f1,temphi.score);
    writeln(f1,temphi.time); { enkkatiedot v3.10 yhteensopivuutta varten }

    inc(code,sortby);
    writeln(f1,sortby);      { v3.11 lukee ne n„iden j„lkeen }
    writeln(f1,code);
    writeln(f1,'0');

    close(f1);
    result:=0;
   end;

  savecustom:=result;

 end;
*)


 function saveset:integer; { palauttaa: 0 - save onnistui, 1 - ei }
 var f1 : text;
     result,temp : integer;
     str1 : string;
   {  tempch,tempch2 : char; }

 begin

  result:=1;

  str1:='CUSTOM';

  fillbox(74,69,246,121,248);
  fillbox(75,70,245,120,243);

  fontcolor(240);
  writefont(85,75,lstr(117));
  fontcolor(241);
  writefont(85,85,lstr(293));

  fillbox(85,95,180,115,245);
  fontcolor(246);

  str1:=getstr2(95,102,8,str1,245);
  str1:=upstr(str1);

  if (str1<>'ÿ') then
   begin
    ch:='Y';

    if (fexist(str1+'.SJC')) then { file exists }
     begin
      alertbox;

      writefont(80,90,'FILE '+str1+'.SJC ALREADY EXISTS.');
      writefont(80,110,'WRITE OVER? (Y/N):');

      getch(190,110,243,ch,ch2);
     end;

    if (upcase(ch)='Y') then
     begin
      for temp:=1 to 20 do defaulthi(top[temp+41]);
      result:=WriteCustom(str1,sortby,hillorder,cuphills);
     end;

   end;

  resultbox(2,result);
  if (result=0) then SetFile:=str1;

  doscreen;

  clearchs;

  saveset:=result;

 end;

 function hillsummary:string;
 var temp : integer;
      sum : string;
 begin
  sum:='';

  for temp:=1 to CupHills do
   sum:=sum+chr(hi(HillOrder[temp]))+chr(lo(HillOrder[temp]));

  sum:=sum+chr(sortby);

  hillsummary:=sum;
 end;


 procedure doselection;
 var loop, loop2 : integer;
     str1 : string;
     leave : boolean;
     {ch, ch2 : char; }
     hills,tempb : byte;

  begin

   hills:=NumWCHills+NumExtraHills;

   for loop:=0 to 41 do
    HillOrder[loop]:=1;

   CupHills:=1;

{   LoadCustom('TEMP.SJC'); }

   LoadCustom(SetFile,sortby,hillorder,cuphills);

   str1:=hillsummary; { str1 indikoi muutoksia }

   doscreen;

   repeat

{    if (CupHills <= max) then inc(CupHills); }

     repeat

      dohill(CupHills+1,1);

{      writefont(1,1,txt(CupHills)); }

      fillbox(250,30,305,36,243);
      fillarea(250,30,305,36,63);

      if (str1=hillsummary) and (SetFile<>'TEMP') then
       begin
        fontcolor(241);
        ewritefont(305,30,'('+SetFile+')');
       end;
{       ewritefont(300,18,txt(length(hillsummary))); }

      DrawScreen;

      clearchs;

      readkbd(ch,ch2);

      if ((ch2=#71) or (ch2=#83)) then HillOrder[CupHills+1]:=1; { home }
      if (ch2=#79) then HillOrder[CupHills+1]:=Hills; { end }
      if ({(ch2=#72) or} (ch2=#75)) and (HillOrder[CupHills+1]>1) then dec(HillOrder[CupHills+1]);
      if ({(ch2=#80) or} (ch2=#77)) and (HillOrder[CupHills+1]<Hills) then inc(HillOrder[CupHills+1]);
      if (ch2=#73) and (HillOrder[CupHills+1]>5) then dec(HillOrder[CupHills+1],5);
      if (ch2=#81) and (HillOrder[CupHills+1]<Hills-5) then inc(HillOrder[CupHills+1],5);
      if (ch2=#68) then begin { CupHills:=1; } ch:=#27; end;
      if ({(ch2=#83) or }(ch=#8) or (ch2=#72)) and (CupHills>0) then { delete }
       begin
        dohill(Cuphills+1,3);
        dec(CupHills);
       end;
      if (upcase(ch)=paraletter(lstr(285))) then if (selectload=0) then str1:=HillSummary;
      if (upcase(ch)=paraletter(lstr(286))) and (CupHills>0) then if (saveset=0) then str1:=HillSummary;
      if (upcase(ch)=paraletter(lstr(288))) then
       begin
        inc(sortby);
        if (sortby=2) then sortby:=0;
        doscreen;
       end;

      if (upcase(ch)=paraletter(lstr(287))) then { randomize }
       begin
        if (cuphills < maxcustomhills) then
         begin
          loop2:=20;
          if (cuphills>=20) then loop2:=maxcustomhills;
          for loop:=cuphills+1 to loop2 do
           begin
            HillOrder[loop]:=random(20)+1;
            dohill(loop,2);
           end;
         CupHills:=loop2;
        end;
       end;

    until (ch=#13) or (ch=#27) or (ch2=#80) or (ch=' ');

{     if (ch=#27) then dec(CupHills); }

     if ((ch=' ') or (ch2=#80)) then
      begin
       if (CupHills < maxcustomhills) then inc(CupHills);
       dohill(CupHills,2);
      end;

   until (ch=#13) or (ch=#27);

 if (str1<>HillSummary) then SetFile:='TEMP'; { setti muuttunut, enkat menee t„nne }

 if ((ch2=#68) or (ch=#27)) then CupHills:=0; { kikkaillaan v„h„n... }

 if (CupHills>0) then
  begin
   dohill(CupHills+1,3); { pois j„m„ }

    for loop:=1 to CupHills do dohill(loop,2);

{   ewritefont(300,24,str1);
    ewritefont(300,32,hillsummary); }

   waitforkey3(295,183,ch);

   { inc(CupHills); }
   WriteCustom('TEMP',sortby,hillorder,cuphills);

  end;

  if (CupHills=0) then HillOrder[1]:=1;
(*
   else
    begin { t„„ on sit„ kun siirretyt taulukot alkaa nollasta }
     for loop:=1 to CupHills do
      HillOrder[loop-1]:=HillOrder[loop];

    end;
*)



 end;

begin { p„„proceduuri }

 defaulthi(temphi);

 doselection;

end;



Procedure LoadNames(whatset:char;
                    teamdiscount:byte;
                    var teamlineup:array of byte;
                    replaces:boolean);

var f4 : text;
    l1, l2 : longint;
    s : string;
    temp,c, temp2, temp3 : integer;
    ok : boolean;
    tempb : byte;

begin

 l1:=0;  { checksum-laskuri }
 l2:=0;

 s:='names'+whatset+'.ski';

 assign(f4,s);
 {$I-}
 reset(f4);
 {$I+}
 FileOK(IOResult,s);

 readln(f4,s); { titlerivi pois }

 temp2:=0; { toteutuneet nimet }

  for temp:=1 to NumPl+1 do
   begin
    readln(f4,s);
    ok:=true; { k„yk” nimi eli ei kai ole replace-listoilla }

    for temp3:=1 to pmaara do
     if (profile[profileorder[temp3]].replace = temp) and (replaces) then ok:=false;

    if (ok) then
     begin
      inc(temp2);
      nimet[temp2]:=s;
     end;

    inc(l1,valuestr(s,temp mod 43));

   end;

  if (nimet[76]='') then nimet[76]:='Trainee';

  for temp:=1 to pmaara do { siirret„„n profilesta nimet }
   begin
    nimet[NumPl+1-temp]:=Profile[profileorder[temp]].name;
   end;


(*
  for temp:=1 to NumPl-pldiscount do
    nimet[temp]:='Mieshmieshmieshmieshmieshmiesh '+txt(temp);
*)

{  nimet[NumPl+1]:='The Training Man'; }

   readln(f4,s); { tyhj„ rivi, ehk„ koodi }

  for temp:=1 to NumTeams-1 do
   begin
    readln(f4,s);
    inc(l1,valuestr(s,temp mod 31));

    for temp2:=1 to 4 do
     begin
      readln(f4,tempb);
      if (tempb<0) or (tempb>67) then tempb:=1;
      inc(l1,tempb mod temp2);

      if (temp<NumTeams+1-teamdiscount) then
       begin
        jnimet[temp]:=s;
        teamlineup[(temp-1)*4+temp2]:=tempb;
       end;

     end;

   end;

  if (whatset='0') then readln(f4,s);

  val(s,l2,c); { haetaan se names:n checksum }

 close(f4);

 inc(l1,5661);

 if (whatset='0') and (l1<>l2) then
     begin
     AsetaMoodi($3);
     writeln('Error #92: Something wrong with the namefile. Shit.');
     Waitforkey;
     Halt;
    end;

{  writeln(l1);
   writeln(l2);
   readln; }

end;


procedure ResetTops(kerroin:byte;Today:Date;Now:Time);
var temp : integer;
    name : NameStr;
    len : integer;
    time : TimeStr;

begin

  top[01].score:=1515;top[01].pos:=1;    { 1  }
  top[02].score:=1343;top[02].pos:=1;    { 3  }
  top[03].score:=1212;top[03].pos:=2;    { 5  }
  top[04].score:=1101;top[04].pos:=3;    { 7  }
  top[05].score:=999; top[05].pos:=4;    { 9  }
  top[06].score:=888; top[06].pos:=5;    { 11 }
  top[07].score:=777; top[07].pos:=6;    { 13 }
  top[08].score:=665; top[08].pos:=7;   { 15 }
  top[09].score:=555; top[09].pos:=8;   { 17 }
  top[10].score:=494; top[10].pos:=10;   { 19 }
  top[11].score:=444; top[11].pos:=12;   { 21 }
  top[12].score:=383; top[12].pos:=14;   { 23 }
  top[13].score:=333; top[13].pos:=16;   { 25 }
  top[14].score:=272; top[14].pos:=18;   { 27 }
  top[15].score:=222; top[15].pos:=20;   { 29 }
  top[16].score:=161; top[16].pos:=22;   { 31 }
  top[17].score:=111; top[17].pos:=25;   { 33 }
  top[18].score:=77;  top[18].pos:=30;   { 35 }
  top[19].score:=33;  top[19].pos:=35;   { 37 }
  top[20].score:=11;  top[20].pos:=40;   { 39 }

 for temp:=1 to 20 do
  begin
   top[temp].name:=nimet[top[temp].pos]+'ÿ';
   top[temp].time:=dayandtime(Today,Now);
{   top[temp].pos:=a*2-1; }
{   top[temp].score:=((37-a)*(28-a))-(a*3); }
  end;

 for temp:=1 to NumWCHills do
  begin
   name:=nimet[1+random(6+random(10))]+'ÿ';
   len:=round(hillkr(temp)/0.94)*10*kerroin;
   time:=dayandtime(Today,Now);
   SetHRinfo(temp,name,len,time);
  end;

 if (NumExtraHills>0) then
  for temp:=1 to NumExtraHills do
   begin
    name:=nimet[1+random(6+random(10))]+'ÿ';
    len:=round(hillkr(temp+NumWCHills)/0.94)*10*kerroin;
    time:=dayandtime(Today,Now);
    SetHRinfo(temp+NumWCHills,name,len,time);
   end;

 for temp:=21 to 30 do
  begin
   top[temp].pos:=round((temp-20)*1);
   top[temp].name:=jnimet[top[temp].pos]+'ÿ';
   top[temp].time:=dayandtime(Today,Now);
  end;

  top[21].score:=42;
  top[22].score:=35;
  top[23].score:=28;
  top[24].score:=21;
  top[25].score:=17;
  top[26].score:=11;
  top[27].score:=8;
  top[28].score:=5;
  top[29].score:=3;
  top[30].score:=1;


  top[31].score:=10111;  top[31].pos:=1;
  top[32].score:=9876;  top[32].pos:=3;
  top[33].score:=9449;  top[33].pos:=6;
  top[34].score:=9010;  top[34].pos:=10;
  top[35].score:=8321;  top[35].pos:=15;

 for temp:=31 to 35 do
  begin
   top[temp].name:=nimet[top[temp].pos]+'ÿ';
{   top[temp].pos:=(round((a-31)*2)+(a-30))*kerroin; }
{   top[temp].score:=(9999+500*31-a*500)*kerroin; }
   top[temp].time:=dayandtime(Today,Now);
  end;

 for temp:=1 to 35 do   { katsos jos nollaa ne scoret! }
  begin
   top[temp].pos:=top[temp].pos*kerroin;
   top[temp].score:=top[temp].score*kerroin;
  end;

 for temp:=36 to 41 do
  begin
   top[temp].name:='Not Completed';
   top[temp].pos:=0;
   top[temp].score:=0;
   top[temp].time:=dayandtime(Today,Now);
  end;
end;



procedure defaultprofile(index:integer;phase:byte);
var temp : integer;
    count, count2 : byte;
    ok : boolean;
    str1 : string;

begin

 with Profile[index] do
 begin
  name:='SKI JUMPER';
  realname:='';
  suitcolor:=0; skicolor:=0;
  kothlevel:=0;
  replace:=0; cstyle:=1;
  wcs:=0; legswon:=0; wcswon:=0;
  bestwcjump:=0; bestwchill:=1;
  bestjump:=0; besthill:=1;
  besthillfile:='HILLBASE';
  bestresult:='-'; best4result:='-';
  bestpoints:=0; best4points:=0;
  totaljumps:=0;
 end;

 count2:=2;

 if (phase=1) then
  repeat

   ok:=true; count:=0;

   for temp:=1 to numprofiles do
    if (Profile[temp].name = Profile[index].name) and (temp<>index) then inc(count);

   if (count>0) then
    begin Profile[index].name:='SKI JUMPER '+txt(count2); ok:=false; end;

   inc(count2);

   if (count2>200) then ok:=true; { jos se dorka j„„ rundiin }

  until (ok);

end;



function ProfileCode(P:Profile_type):longint;
var temp : longint;
begin

 temp:=0;

 with P do
 begin

  inc(temp,valuestr(name+bestresult+best4result,11));
  inc(temp,suitcolor xor 31);
  inc(temp,skicolor xor 53);
  inc(temp,kothlevel and 44);
  inc(temp,replace or 91);
  inc(temp,bestwchill xor 157);
  inc(temp,bestwcjump and 311);
  inc(temp,besthill xor 113);
  inc(temp,bestjump and 277);
  inc(temp,bestpoints or 133);
  inc(temp,best4points and 31);

  inc(temp,cstyle xor 37);
  inc(temp,wcs and 741);
  inc(temp,legswon or 453);
  inc(temp,wcswon xor 857);
  inc(temp,totaljumps+5);

 end;

 ProfileCode:=temp;

end;



procedure LoadProfiles;
var f1 : text;
    temp : integer;
    str1 : string;
    l1, l2 : longint;
begin

{$IFDEF REG}
 maxpmaara:=10; maxprofiles:=20; { t„t„ kutsutaan kuitenkin ekana }
{$ELSE}
 maxpmaara:=2; maxprofiles:=4;
{$ENDIF}

 str1:='PLAYERS.SKI';

 assign(f1,str1);
 {$I-}
 reset(f1);
 {$I+}
 FileOK(IOResult,str1);

 for temp:=0 to 20 do DefaultProfile(temp,0);

 readln(f1,NumProfiles);
  if (NumProfiles=0) or (NumProfiles>maxprofiles) then NumProfiles:=1;

 for temp:=1 to NumProfiles do
  begin
   str1:=#1; l1:=0; l2:=0;
   while (str1[1]<>'*') do readln(f1,str1);

   with Profile[temp] do
    begin
     readln(f1,name);
     readln(f1,suitcolor); readln(f1,skicolor);
     readln(f1,cstyle);
     readln(f1,kothlevel); readln(f1,replace);
     readln(f1,wcs); readln(f1,legswon); readln(f1,wcswon);
     readln(f1,bestwcjump); readln(f1,bestwchill);
     readln(f1,bestjump); readln(f1,besthill);
     readln(f1,besthillfile);
     readln(f1,bestresult); readln(f1,bestpoints);
     readln(f1,best4result); readln(f1,best4points);
     readln(f1,totaljumps);
     readln(f1,skipquali);
     readln(f1,realname); if (realname='0') then realname:=name;
     readln(f1); readln(f1);
     readln(f1,l1); { checksum }
    end;

    if (l1<>profilecode(Profile[temp])) then
     begin
      beep(1);
      DefaultProfile(temp,0);
     end;

{$IFNDEF REG}
     with Profile[temp] do
      begin
       suitcolor:=0;
       skicolor:=0;
       replace:=0;
      end;
{$ENDIF}

  end;

 close(f1);

end;



procedure WriteProfiles;
var f1 : text;
    temp : integer;
    str1 : string;
    l1, l2 : longint;
begin

 str1:='PLAYERS.SKI';

 assign(f1,str1);
 rewrite(f1);

 writeln(f1,NumProfiles);
  if (NumProfiles=0) or (NumProfiles>20) then NumProfiles:=1;

 for temp:=1 to NumProfiles do
  begin

   writeln(f1,'*'+txt(temp));

   with Profile[temp] do
    begin
     writeln(f1,name);
     writeln(f1,suitcolor); writeln(f1,skicolor);
     writeln(f1,cstyle);
     writeln(f1,kothlevel); writeln(f1,replace);
     writeln(f1,wcs); writeln(f1,legswon); writeln(f1,wcswon);
     writeln(f1,bestwcjump); writeln(f1,bestwchill);
     writeln(f1,bestjump); writeln(f1,besthill);
     writeln(f1,besthillfile);
     writeln(f1,bestresult); writeln(f1,bestpoints);
     writeln(f1,best4result); writeln(f1,best4points);
     writeln(f1,totaljumps);
     writeln(f1,skipquali);
     writeln(f1,realname);
     writeln(f1,'0'); writeln(f1,'0');
    end;

    writeln(f1,profilecode(Profile[temp]));
    writeln(f1);
    writeln(f1);

  end;

 close(f1);

end;


procedure emptyedit;
begin
 fillbox(166,4,319,198,244);
 fillarea(166,4,319,198,63);
end;


procedure choosesuitski(index,phase:integer); { 0 -suit, 1 -ski}
var max, temp, x, y, value :integer;
begin

 if (fontlen(lstr(306))>fontlen(lstr(307))) then
  x:=172+fontlen(lstr(306)) else
  x:=172+fontlen(lstr(307));
 if (x>288) then x:=288;

 max:=NumSuits;
 value:=Profile[index].SuitColor+1;
 y:=24;

 for temp:=1 to Max do
  LoadSuit(temp-1,temp);

 if (phase=1) then
  begin
   max:=NumSkis;
   for temp:=1 to Max do
    LoadSkis(temp-1,temp);
   value:=Profile[index].SkiColor+1;
   inc(y,8);
  end;

 if (value=0) then value:=max-1;

 AsetaPaletti;

 fillbox(x,y,x+30,y+4+(max*8),242);
 box(x,y,x+30,y+4+(max*8),244);

 for temp:=1 to Max do
  begin
   fillbox(x+6,y+4,x+24,y+8,temp*5);
   if (phase=0) then
       box(x+6,y+4,x+24,y+8,(temp*5)+2);
   inc(y,8);
  end;

  y:=y-59+(phase*32);

 value:=MakeMenu(x+9,y,24,8,Max-1,value,242,7,value);

 if (value=0) then value:=max;
 if (phase=0) then Profile[index].SuitColor:=value-1
              else Profile[index].SkiColor:=value-1;

{ drawscreen; }

end;


procedure drawsuitski(index,phase:integer);
var x,xl,y, temp : integer;
begin

 LoadSuit(Profile[index].suitcolor,0);
 LoadSkis(Profile[index].skicolor,0);

 if (fontlen(lstr(306))>fontlen(lstr(307))) then
  x:=178+fontlen(lstr(306)) else
  x:=178+fontlen(lstr(307));

 xl:=x+18; if (xl>318) then xl:=318;
 y:=28;

{ if (phase=1) then fillbox(x-3,y-2,xl+3,y+6,242); }

{  fillbox(x-2,y-1,xl+2,y+5,242); }

  fillbox(x,y,xl,y+4,216);
      box(x,y,xl,y+4,218);

 inc(y,8);

{ if (phase=2) then fillbox(x-2,y-1,xl+2,y+5,242); }

 fillbox(x+1,y+1,xl-1,y+3,231);

 asetapaletti;

end;


procedure writeprofile(index,phase,inorder:integer);
                            { 0 - sivun„ytt”, 1 - edit }
var temp, temp2, colx, x, y : integer;
    col1, col2 : byte;
    str1 : string;
    ActHill : hill_type;

 function gety:integer;
  var tempy : integer;
  begin
   case temp of
    0..9  : tempy:=temp*8+4;
   10..15 : tempy:=temp*8+10;
   16..19 : tempy:=temp*16-118;
   end;
   gety:=tempy;
  end;

(*
 function getsnum(temp2:integer):integer;
  var tempy : integer;
  begin
   tempy:=304+temp2;
   if (temp2>6) then tempy:=303+temp2;
   if (temp2=6) then tempy:=218;
   getsnum:=tempy;
  end;
*)

begin

 colx:=166;

 col1:=241;
 col2:=246;

 emptyedit;

 if (phase=1) then
  begin
   col1:=240;
   fillbox(175,85,305,85,241);
  end;
 if (numprofiles<16) then
  begin
   fillbox(1,175,158,199,243);
   fillarea(1,175,158,199,63);
  end;

 if (numprofiles<16) and (inorder>=0) then
  begin
   fontcolor(241);
   temp:=2;
   if (inorder>0) then temp:=0;
   writefont(8,175,lstr(322));
   writefont(11,183,lstr(323+temp));
   writefont(11,191,lstr(324+temp));
  end;


if (index>0) and (index<=NumProfiles) then
 begin

  fontcolor(col1);

{  drawanim(250,44,179); }
  drawsuitski(index,0);

  for temp:=1 to 18 do
   begin
    str1:=lstr(temp+303);

    if (phase=0) and (temp>7) and (temp<10) then str1:='';

{$IFNDEF REG}
   if (phase=1) then
     begin
      if (temp=3) then fontcolor(241);
      if (temp=6) then fontcolor(240);
     end;
{$ENDIF}

    if (temp=10) and (phase=1) then fontcolor(241);

    writefont(colx,gety,str1);

   end;

  fontcolor(col2);

  for temp:=1 to 18 do
   begin
    str1:='';

    with Profile[index] do
     case temp of
     1 : str1:=name;
     2 : str1:=realname;
     5 : if (replace=0) then str1:='-'
                        else str1:=nimet[replace];
     6 : if (cstyle=0) then str1:=lstr(9)
                       else str1:=lstr(361+cstyle*40);
     7 : str1:=lstr(231+skipquali);
     10 : str1:=txt(totaljumps);
     11 : str1:=txt(wcs);
     12 : str1:=txt(legswon);
     13 : str1:=txt(wcswon);
     14 : str1:=bestresult;
     15 : str1:=best4result;
     16 : if (bestwcjump=0) then str1:='-'
           else str1:=txtp(bestwcjump)+'« '+hillname(bestwchill);
     17 : if (bestjump=0) then str1:='-'
           else
            begin
             if (besthill > NumWCHills) then
              begin
               temp2:=0;

               if (NumExtraHills>0) then
                while (temp2<NumExtraHills) do
                 begin
                  inc(temp2);
                  if (hillfile(temp2) = besthillfile) then
                   begin
                    LoadInfo(temp2+NumWCHills,Acthill);
                    temp2:=NumExtraHills;
                   end;
                 end;
               str1:=txtp(bestjump)+'« '+acthill.name;
              end else str1:=txtp(bestjump)+'« '+hillname(besthill);
            end;

     18 : if (kothlevel=0) then str1:='-'
                           else str1:=lstr(130+kothlevel);
     end;

     x:=colx+4; y:=gety;

     if (temp>15) then inc(y,8)
                  else inc(x,fontlen(lstr(303+temp)));

     writefont(x,y,str1);

   end;



 end;{ else emptyedit; }



end;


procedure doorder;
var temp, temp2 : integer;
 function y:integer;
  begin
   y:=temp*8+4;
  end;

begin

 fontcolor(246);

 if (NumProfiles>0) then
  for temp:=1 to NumProfiles do
   begin
    fillbox(10,y-1,30,y+6,243);
    for temp2:=1 to pmaara do
     if (Profileorder[temp2] = temp) then
      writefont(18,y,txt(temp2)+'.');

   end;

end;

procedure doscreen;
var temp : integer;

 function y:integer;
  begin
   y:=temp*8+4;
  end;

begin

 newscreen(7,0);

 temp:=0;

 fontcolor(241);
{ writefont(20,2,lstr(280)+':'); }
 writefont(40,3,lstr(34));

 fontcolor(240);

 for temp:=1 to NumProfiles do
  begin
   writefont(40,y,profile[temp].name);
  end;

 if (NumProfiles<maxprofiles) then
  begin
   fontcolor(246);
   inc(temp);
   writefont(40,y,lstr(302));
  end;

 inc(temp,2);
 fontcolor(240);
  writefont(40,y,lstr(33));

 doorder;

end;


procedure selectreplace(index:integer);
var x,y, temp : integer;
    ok, leave : boolean;
    value : integer;
{    ch,ch2 : char; }
begin

 value:=Profile[index].replace;
 if (value>65) then value:=65;

 x:=fontlen(lstr(308))+170;
 y:=44;
 leave:=false;

 repeat

  fillbox(x-2,y-1,318,y+6,245);
{  ok:=true; }

{
  for temp:=1 to numprofiles do
   if (profile[temp].replace = value) and (temp<>index) and (value>0) then ok:=false;
}

  fontcolor(240);

  if (value>0) then
   begin
    writefont(x,y,nsh(nimet[value],305-x));
    ewritefont(316,y,'#'+txt(value));
   end else writefont(x,y,lstr(9));

  DrawScreen;

  readkbd(ch,ch2);

  if (ch=#0) then
   begin
    if (ch2=#71) then value:=1;
    if (ch2=#79) then value:=65;
    if (ch2=#72) or (ch2=#75) then dec(value);
    if (ch2=#80) or (ch2=#77) then inc(value);
    if (ch2=#73) then dec(value,10);
    if (ch2=#81) then inc(value,10);
   end;

  if (value<0) then value:=0;
  if (value>65) then value:=65;

{  if (ch=#13) and (not ok) then ch:=#1; }

  until (ch=#13) or (ch=#27);

  if (ch=#13) then Profile[index].replace:=value;

end;


function question(str1:string):boolean;
var temp : byte;
 {   tempch,tempch2 : char; }
    tempboo : boolean;
    str2 : string;

begin

 str2:=lstr(193);

 alertbox;

 temp:=fontlen(str2)+4;

 fontcolor(241);
 writefont(70+temp,110,'('+lch(6,1)+'/'+lch(7,1)+')');

 inc(temp,25);

 fontcolor(246);

 writefont(70,90,str1);
 writefont(70,110,str2);

 getch(70+temp,110,243,ch,ch2);

 tempboo:=false;
 if (upcase(ch) = lch(6,1)) then tempboo:=true;

 clearchs;

 question:=tempboo;

end;


procedure welcomescreen(var languagenumber:byte);
var x, index, temp : integer;
    full : boolean;

begin

 full:=false;
 if (languagenumber=255) then full:=true;

 if (languagenumber=255) then languagenumber:=1;
 for temp:=1 to {numprofiles}5 do Profile[temp].CStyle:=1;

 if (full) then
  begin
   x:=240;

   NewScreen(6,0);

   fontcolor(240);
   ewritefont(x,6,'WELCOME!');
   fontcolor(246);
   ewritefont(x,16,'TERVETULOA!');
   fontcolor(247);
   ewritefont(x,26,'WILLKOMMEN!');
   fontcolor(240);
   ewritefont(x,36,'VŽLKOMMEN!');

  end else
   begin
    fillbox(74,41,246,186,248);
    fillbox(75,42,245,185,243);
   end;

{ fontcolor(246);
 writefont(x,70,'BENVENUTO!'); }

  x:=100;

  fontcolor(240);
  writefont(x,50,'PLEASE CHOOSE A LANGUAGE:');

  x:=155;

  fontcolor(246);

  for temp:=1 to numlanguages do
    writefont(x-(fontlen(lnames[temp]) div 2),temp*8+55,lnames[temp]);

  temp:=3; if (not full) then temp:=7;
 index:=MakeMenu(112,64,100,8,numlanguages-1,1,243,temp,0);

 if (index=0) then index:=numlanguages;

 languagenumber:=index;

 LoadLanguage(languagenumber);

end;




procedure chooseseecomps(var seecomps:byte);
var sch1, sch2 : char;
    temp : integer;
    index : byte;
    leave : boolean;
    str1 : string;

begin

  leave:=false;

  fontcolor(240);

  fillbox(74,79,246,133,248);
  fillbox(75,80,245,132,243);

  writefont(85,85,lstr(219));
  fontcolor(241);
  writefont(85,95,lstr(150));

  index:=seecomps;

  repeat

   if (index>NumPl) then
    begin
     str1:=lstr(index);
     fontcolor(240);
    end
     else
      begin
       str1:='#'+txt(index)+' '+nsh(nimet[index],115);
       fontcolor(246);
      end;

   fillbox(85,105,235,125,245);
   writefont(95,112,str1);

   drawscreen;

    sch1:=#1; sch2:=#1;
    readkbd(sch1,sch2);

    if (sch1='+') or (sch2=#77) or (sch2=#80) then
     begin
      inc(index);
      if (index>NumPl-11) and (index<235) then index:=235;
      if (index>240) then index:=1;
     end;

    if (sch1='-') or (sch2=#75) or (sch2=#72) then
     begin
      dec(index);
      if (index<235) and (index>Numpl) then index:=NumPl-11;
      if (index<1) then index:=240;
     end;

    if (sch2=#71) then index:=1;
    if (sch2=#79) then index:=240;

    if (sch1=#27) or (sch2=#68) or (sch1=#13) then leave:=true;

   until (leave);

  if (sch1=#13) then seecomps:=index;


end;



procedure editprofile(index:integer);
var tempboo, leave2 : boolean;
    temp, index2 : integer;
    str1, oldstr : string;
begin

 leave2:=false;
 index2:=1;

 writeprofile(index,1,-1);

 repeat

  index2:=makemenu(168,13,154,8,8,index2,244,3,9);

  case index2 of
  0 : leave2:=true;
  1 : begin { name edit }
       repeat

        tempboo:=true;
        oldstr:=Profile[index].name;

        temp:=314-170-fontlen(lstr(304));

        str1:=getstr(170+fontlen(lstr(304)),12,temp,oldstr,245);
        str1:=upstr(str1);

        if (str1<>'') then
         begin
          for temp:=1 to numprofiles do
           if (temp<>index) and (str1 = Profile[temp].name) then tempboo:=false;

           if (tempboo) then Profile[index].name:=str1;
         end;

       until (tempboo);

       doscreen;

      end;

  2 : begin { realname edit }
       oldstr:=Profile[index].realname;

       temp:=314-170-fontlen(lstr(305));
       str1:=getstr(170+fontlen(lstr(305)),20,temp,oldstr,245);
       str1:=upstr(str1);

       Profile[index].realname:=str1;

       doscreen;

      end;

{$IFDEF REG}
  3 : choosesuitski(index,0);
  4 : choosesuitski(index,1);
  5 : begin
       selectreplace(index);
       doscreen;
      end;
{$ENDIF}

  6 : begin
       inc(Profile[index].cstyle);
       if (lstr(361+(Profile[index].cstyle*40))='?') then Profile[index].cstyle:=0;
       emptyedit;
      end;

  7 : begin
       inc(Profile[index].skipquali);
       if (Profile[index].skipquali>2) then Profile[index].skipquali:=0;
       doscreen;
      end;

  8 : begin
       if (question(lstr(329))) then DefaultProfile(index,1);
       doscreen;
      end;



  end; { case }

  if (index2 > 0) then writeprofile(index,1,-1);

 until (leave2);

 emptyedit;

end;





procedure profiles;
var oldindex, index, temp, x : integer;
    entries : integer;
    temp2 : integer;
    leave : boolean;

 function getentry:integer;
 var temp2 : integer;
 begin
  temp2:=numprofiles+1;
  if (numprofiles>=maxprofiles) then temp2:=numprofiles;
  getentry:=temp2;
 end;

begin

 leave:=false;
 index:=1;

 doscreen;

 repeat

  entries:=getentry;

{  writefont(1,102,txt(entries));
  writefont(1,112,txt(maxprofiles)); }

  temp2:=0;
  oldindex:=index;

  for temp:=1 to pmaara do
   if (Profileorder[temp] = oldindex) then temp2:=temp;

  temp:=temp2; if (oldindex>numprofiles) then temp:=-1;

  writeprofile(index,0,temp);

   index:=makemenu(40,13,122,8,entries,index,243,6,255);

  if ((index=255) and (oldindex>entries)) or (index=254) then leave:=true;

  if (not leave) and (index=255) then { enter pressed }
   begin

    if (temp2>0) or (oldindex>numprofiles) then { edit }
     begin
      if (oldindex>numprofiles) and (numprofiles<>maxprofiles) then
       begin
        DefaultProfile(oldindex,1);
        inc(numprofiles);
        doscreen;
       end;

      editprofile(oldindex);
     end
      else { lis„„ pelaaja hypp„„viin }
       if (pmaara<maxpmaara) then
        begin
         inc(pmaara);
         profileorder[pmaara]:=oldindex;
         doorder;
        end;{ else
         begin
          alertbox;
          writefont(80,90,lstr(47));
          writefont(80,100,lstr(48));
          drawscreen;
          waitforkey;
          doscreen;
         end;}

   end;

  if (oldindex<=numprofiles) and (not leave) and (index<0) then { del pressed }
   begin
    temp2:=0;

    for temp:=1 to pmaara do
     if (Profileorder[temp] = oldindex) then temp2:=temp;

    if (temp2>0) then { poista j„rjestyksest„ }
     begin

      if (pmaara>0) then
       begin
        for temp:=temp2 to pmaara do
         ProfileOrder[temp]:=ProfileOrder[temp+1];

        dec(pmaara);
        doorder;
       end;
     end else  { poista profile kokonaan }
      begin

       if (question(lstr(328)+': '+Profile[oldindex].name)) then
        begin

         if (numprofiles>1) then
          begin
           dec(numprofiles);
           for temp:=oldindex to numprofiles do
            Profile[temp]:=Profile[temp+1];
           for temp:=1 to pmaara do
            if (profileorder[temp] > oldindex) then dec(profileorder[temp]);

          end
           else DefaultProfile(oldindex,1);
        end;

        doscreen;

      end;
   end;

{  writefont(160+random(150),random(192),'.'+txt(index)); }

  if (index>100) or (index<0) then index:=oldindex;

 until (leave);

 if (pmaara=0) then
  begin
   { beep(1); }
   ProfileOrder[1]:=1;
   pmaara:=1;
  end;

 drawscreen;

{ signupplayers; }

end;


procedure CallSendme(version,regname,regnumber:string;
                     Today:date;Now:Time;vcode:byte);

var f2 : text;
    str1, realname : string;
    sortby : byte;
    anywritten : boolean;
    apu1, apu2, apu3 : integer;
    laskuri, ahi, code : longint;
    NumCustoms : integer;
    Files : array [0..MaxCustoms] of FileStr;
    TempHillOrder : array[0..41] of integer;
    checkstrs : array[0..21] of string[12];
    TempCupHills : integer;


 procedure dotop(fname:string);
  begin
   assign(f2,fname);
   rewrite(f2);

   writeln(f2,'SJ3 v',version,' - ',fname,' - created at ',dayandtime(Today,Now));
   writeln(f2);
   writeln(f2,'            (please fill in the real full names below!)');
   writeln(f2,toansi('            (example: "LARS76" = Ville K”n”nen )'));
   writeln(f2,toansi('            (         "VILLE KONONEN" = Ville K”n”nen )'));
   writeln(f2,'.:Jumpers:.');
   writeln(f2);
  end;

 procedure findnames(phase:byte); { 1-sendme, 2-extras, 3-customs }
  var writtenstr : array[0..200] of string[31];
      numwritten : integer;
      temp1, temp2, temp3 : integer;
      stop,stop2 : integer;
      ok : boolean;


  begin

   for temp1:=0 to 101 do writtenstr[temp1]:='';
   numwritten:=0;
   stop2:=1;

   case phase of
   1 : stop:=40+numprofiles;
   2 : stop:=NumExtrahills;
   3 : begin
        stop:=NumCustoms;
        stop2:=20;
       end;
   end;

   for temp1:=1 to stop do
    begin
     if (phase=3) then LoadCustom(files[temp1],sortby,temphillorder,tempcuphills);

     for temp2:=1 to stop2 do
      begin
       ok:=true;
       case phase of
       1 : case temp1 of
            1..20 : str1:=top[temp1].name;
            21..40 : str1:=HRname(temp1-20);
            41..99 : str1:=Profile[temp1-40].name;
           end;
       2 : str1:=HRname(temp1+20);
       3 : str1:=top[temp2+41].name;
       end;

       for temp3:=1 to numwritten do
        if (str1 = writtenstr[temp3]) then ok:=false; { on jo }

       if (str1[length(str1)]='ÿ') then ok:=false; { computer jumper }
       if (str1 = 'Nobody') and (phase=3) then ok:=false; { customs default }

       realname:='';
       for temp3:=1 to NumProfiles do
        if (str1=Profile[temp3].name) then realname:=nmstr(Profile[temp3].realname);

       if (ok) then
        begin
         writeln(f2,'"',toansi(str1),'" = ',toansi(realname));
         if (numwritten<200) then inc(numwritten);
         writtenstr[numwritten]:=str1;
        end;
      end;
    end;

   writeln(f2);
   writeln(f2,'- - - - - - - - - - - - - - - - - - - - - - - - - ');
   case phase of
   1 : str1:='YWF';
   2 : str1:='UWF';
   3 : str1:='IWF';
   end;
   str1:=str1+txt(vcode)+'ANYT';
   writeln(f2,'* DO NOT EDIT THIS FILE FROM HERE *   C: ',str1);
   writeln(f2);
   write(f2,'From: ');


   
{$IFDEF REG}
    str1:=regname+' #'+regnumber;
{$ELSE}
    str1:='Some nice gentleman who hasn''t yet registered SJ3.';
{$ENDIF}

    writeln(f2,toansi(str1));

  end;

 procedure writehead(phase:byte);
  var str2:string;
 begin
  case phase of
  1 : str2:='World_Cup';
  2 : str2:='Hillrecords';
  3 : str2:='All_Hill_Index';
  4 : str2:='Profile_info';
  5 : str2:='Extra_hills';
  6 : str2:='Custom_Cups';
  end;

  writeln(f2);
  writeln(f2,'.:',str2,':.');
  writeln(f2);

 end;

begin

 dotop('SENDME.TXT');
 findnames(1);

 writehead(1);
 anywritten:=false;

  laskuri:=0;

  laskuri:=svaluestr(str1,11);
{  writeln(f2,laskuri); }

 for apu1:=1 to 20 do
  begin

   if (top[apu1].name[length(top[apu1].name)]<>'ÿ') then
    begin
     anywritten:=true;
     str1:=crypt(top[apu1].score,apu1);
     writeln(f2,apu1:2,'.',toansi(top[apu1].name):25,top[apu1].pos:3,'.',top[apu1].score:5,' C: ',str1);
     inc(laskuri,svaluestr(str1,apu1));
     inc(laskuri,svaluestr(top[apu1].name,top[apu1].pos));
{     inc(l,svaluestr(txt(toptulos[a]),b*3-1)); }
    end;
  end;

  writeln(f2);
  write(f2,'Checksum: ');

  if (anywritten) then writeln(f2,((laskuri div 2)+20424) xor 545033)
                  else writeln(f2,'None.');

  laskuri:=0;
  ahi:=0; { all hill index - prosentti }

  writehead(2);
  anywritten:=false;

 for apu1:=1 to NumWCHills do
  begin

   str1:=HRname(apu1);
   apu2:=hillkr(apu1)*10;

   if (str1[length(str1)]<>'ÿ') then
    begin
     anywritten:=true;
     str1:=crypt(HRLen(apu1),apu1);

     writeln(f2,upstr(copy(hillname(apu1),1,3)),toansi(HRName(apu1)):25,' ',txtp(HRLen(apu1)):8,' C: ',str1);

     inc(laskuri,svaluestr(str1,apu1));
     inc(laskuri,svaluestr(HRName(apu1),apu1));

     apu2:=HRLen(apu1);

    end; { else writeln(f2); }

   inc(ahi,longint(apu2)); { eli lis„t„„n joko omalla enkalla tai kriittisell„ }

  end;

  writeln(f2);
  write(f2,'Checksum: ');

  if (anywritten) then writeln(f2,((laskuri div 3)+69721) xor 408675)
                  else writeln(f2,'None.');

  laskuri:=0;

  for apu1:=1 to NumWChills do inc(laskuri,longint(hillkr(apu1)*10));

  writehead(3);

{
  writeln(f2,'ahi: ',ahi);
  writeln(f2,'laskuri: ',laskuri);
}
  ahi:=round((ahi/laskuri)*10000);
  str1:=txt(ahi); insert('.',str1,length(str1)-1); str1:=str1+' %';

  writeln(f2,str1:10);

  laskuri:=0;

  writeln(f2);
  write(f2,'Checksum: ');

  if (ahi>10000) then writeln(f2,((ahi shl 3)+69721) xor 408675)
                 else writeln(f2,'None.');

  laskuri:=0;

  writehead(4);

  for apu1:=1 to Numprofiles do
   begin
    laskuri:=0;

    str1:=Profile[apu1].name;
    writeln(f2,toansi(str1));
    inc(laskuri,svaluestr(str1,3));

    ahi:=Profile[apu1].totaljumps; { ahi temp-k„yt”ss„, „l„ pel„sty }
    writeln(f2,' Total_jumps: ',ahi);
    inc(laskuri,ahi+3613);

    ahi:=Profile[apu1].wcswon;
    writeln(f2,' WC_won: ',ahi);
    inc(laskuri,ahi*311);

    ahi:=Profile[apu1].legswon;
    writeln(f2,' Legs_won: ',ahi);
    inc(laskuri,ahi*133);

    str1:=Profile[apu1].best4result;
    writeln(f2,' Best_4H: ',str1);
    apu2:=0; while (str1[apu2]<>' ') and (apu2<length(str1)) do inc(apu2);
    inc(laskuri,svaluestr(copy(str1,1,apu2-1),7));

    apu2:=Profile[apu1].kothlevel;
    writeln(f2,' KOTH_level: ',apu2);
    inc(laskuri,apu2*1313);

    write(f2,' Checksum: ');
    if (laskuri>0) then writeln(f2,(laskuri+11278) xor 591219)
                   else writeln(f2,'None.');
   end;

  writeln(f2,'End.');

  writeln(f2);
  writeln(f2,'.END_OF_SENDME.TXT');
  writeln(f2);
  writeln(f2,'Please send me to vkononen@cc.hut.fi');
  writeln(f2,'Remember to use your real whole name, no nicknames are allowed.');
  writeln(f2,'The Universal Hiscore List @ http://nomasi.com/sj3');

 close(f2);

 if (NumExtraHills>0) then  {      --- EXTRAS! ---      }
  begin

   dotop('EXTRAS.TXT');
   findnames(2);

   laskuri:=0;

   writehead(5);

   for apu1:=21 to NumExtraHills+20 do
    begin

     str1:=HRName(apu1);
     if (str1[length(str1)]<>'ÿ') then
      begin
       str1:=crypt(HRLen(apu1),apu1);

       writeln(f2,upstr(hillname(apu1)),' K',hillkr(apu1));
       writeln(f2,'C: ',hillcode(apu1));

       writeln(f2,' ',toansi(HRName(apu1)):25,' ',txtp(HRLen(apu1)):8,' C: ',str1);

       inc(laskuri,svaluestr(str1,apu1));
       inc(laskuri,svaluestr(HRname(apu1),apu1));

{     inc(l,svaluestr(txt(MEpituus[a]),a*2+2)); }

      end; { else writeln(f2); }

    end;

   if (laskuri>0) then
    begin
     writeln(f2);
     writeln(f2,'Checksum: ',((laskuri div 3)+69721) xor 408675);
    end else writeln(f2,'None.');

   writeln(f2);
   writeln(f2,'.END_OF_EXTRAS.TXT');
   writeln(f2);

   close(f2);

  end;

 FindCustoms(NumCustoms,Files);

 if (NumCustoms>0) then  {      --- CUSTOMS! ---      }
  begin

   dotop('CUSTOMS.TXT');
   findnames(3);

   writehead(6);

   for apu1:=1 to NumCustoms do
    begin
     laskuri:=0;
     code:=LoadCustom(files[apu1],sortby,temphillorder,tempcuphills);

     writeln(f2,'File: ',upstr(files[apu1]));
     writeln(f2,'Sort: ',sortby);
     writeln(f2,'Code: ',code);

     for apu2:=1 to 20 do
      if (top[apu2+41].score>0) then
       begin
        str1:=crypt(top[apu2+41].score,apu2);
        checkstrs[apu2]:=str1;
        inc(laskuri,svaluestr(str1,apu2));
        inc(laskuri,svaluestr(toansi(top[apu2+41].name),top[apu2+41].pos));
       end;

     write(f2,'Chsm: ');
     if (laskuri>0) then writeln(f2,(laskuri+(code div 2)+(sortby*4)+14034) xor 502667)
                    else writeln(f2,'None.');

     for apu2:=1 to 20 do
      if (top[apu2+41].score>0) then
       begin
        str1:=checkstrs[apu2];
        write(f2,apu2:2,'.',toansi(top[apu2+41].name):25,top[apu2+41].pos:3,'.',top[apu2+41].score:7,' C: ',str1);
        if ((top[apu2+41].time)[1]='(') then writeln(f2,' '+top[apu2+41].time)
                                        else writeln(f2);

       end;

     writeln(f2,'End.');
     writeln(f2);

    end;

  writeln(f2,'.END_OF_CUSTOMS.TXT');
  writeln(f2);

  close(f2);

 end;


end;

procedure drawmainmenu;
var x, y, temp : integer;
begin

{  fontcolor(240); }

    fillbox(0,0,319,199,0); drawscreen;
    LataaPCX('MAIN.PCX',320*200,0,0);

    SiirraStandardiPaletti;
    SpecialMainPaletti;
     AsetaPaletti;
    move(mem[Graffa:0],mem[video:0],64000);

(*
    StartSuit; { lataa ne hyppypukujen v„rit 190-200... }
*)
  fontcolor(240);
  writefont(170,51,lstr(34));
  fontcolor(241);

  x:=150;

 for temp:=1 to pmaara do
  begin
   y:=(temp-1)*9+64;
   ewritefont(x+12,y,txt(temp)+'.');
   writefont(x+20,y,nimet[NumPl+1-temp]);

(*
   if (reg) then
    begin
     fillbox(302,y,312,y+6,209+haalarit[temp]);
     fillbox(303,y+1,311,y+5,202+haalarit[temp]);
    end;
*)

  end;

{ Fillbox(160,120,319,199,245); }

end;





begin

 NumProfiles:=1;

end.

