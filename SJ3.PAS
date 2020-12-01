program Skijump3; { Reality Strikes }
uses crt, dos, sj3graph, sj3pcx, sj3unit, sj3help, sj3info,
     sj3list, sj3table, maki, lumi, tuuli, sj3lang, sj3repl, sdlport;

const

 {$I REGSTAT.PAS}

 {$I REGFREE.PAS}

var

 version, version_full : string[10];

 ActHill : hill_type;

 nosamename, automatichrr : boolean;

 jmaara : byte;
 nytmaki : integer;

 wcup, jcup, cupslut : boolean;

 reg : boolean;

 Today : Date;
 Now, Start : Time;

 Stats : array [0..15,0..NumWCHills] of Stat_type;
 CStats : array[0..2,1..NumPl+1] of integer;

{ ex,  ok, }eka,treeni : boolean;
 compactlist, comphrs : boolean;
 diff,diffwc,lct, InvBack, beeppi, goals, kosystem : boolean;

 trainrounds, windplace{,skipquali} : byte;

 sija, qual, inj : array [0..NumPl+1] of byte;

 pisteet : array[0..NumPl+1] of integer;
 mcpisteet : array[0..NumPl+1] of integer;
 fourpts : array[0..NumPl+1] of longint;

 CupStyle : byte;
 CupHills : integer;

 mcluett : array[0..NumPl+1] of byte;
 luett : array[0..NumPl+1] of byte;

  K : array[0..5] of word;

(*
 haalarit : array[0..MaxOwnPl] of byte;
 sukset : array[0..MaxOwnPl] of byte; { profileen... }
*)

 osakilpailu,kierros,startgate : integer;

 HillOrder : array[0..41] of integer;
 SetFile : string;   { pakko olla global, muuten se unohtuu }

 koth, kothwind : boolean;
 kothmaara,kothpack, kothrounds : byte;
 kothmaki : integer;
 kothpel : array[0..20] of byte;

{ startday : word; }

 namenumber : char;
 languagenumber : byte;
 gdetail, seecomps : byte;

 teamlineup : array[0..60] of byte;

 KeulaX : integer; { oltava global?
                             juu, koska se lukee sen vain m„en latauksessa,
                             ja muuten se unohtuu... }

 ThisIsAHillRecord : integer;


procedure MakeSendMe;
begin
 CallSendme(version,regname,regnumber,Today,Now,vcode);
end;


procedure WriteRecords;
var  l1,l2 : longint;
     f1 : text;
     temp : integer;
     str1 : string;
begin

 l1:=0; l2:=0;

  assign(f1,'HISCORE.SKI');
  rewrite(f1);  { topten }

  writeln(f1,'HISCORE.SKI - !!! DO NOT ATTEMPT TO EDIT THIS FILE !!!');

  for temp:=1 to 41 do  { 20 world cupia, 10 teamia, 5 4hillsia ja 6 kothia }
   begin
    str1:=top[temp].name;
     writeln(f1,str1);
     inc(l1,valuestr(top[temp].name,temp));
    str1:=crypt(top[temp].pos,temp);
     writeln(f1,str1);
     inc(l2,valuestr(str1,temp));
    str1:=crypt(top[temp].score,temp);
     writeln(f1,str1);
     inc(l2,valuestr(str1,temp));
   end;

  for temp:=1 to NumWCHills do
   begin
    str1:=HRname(temp);
     writeln(f1,str1);
     inc(l1,valuestr(HRname(temp),temp));
    str1:=crypt(HRLen(temp),temp);
     writeln(f1,str1);
     inc(l2,valuestr(str1,temp));
   end;

  l1:=l1 xor 734697;

  writeln(f1,l1);
  writeln(f1,l2);

  str(l1+l2+53,str1);
  writeln(f1,valuestr(str1,22));

   for temp:=1 to 41 do
     writeln(f1,top[temp].time);

   for temp:=1 to NumWCHills do
     writeln(f1,HRtime(temp));

   makevcode(version,reg);
   writeln(f1,vcode);

  close(f1);


end;

procedure WriteConfig;
var f2 : text;
    temp : integer;
begin

  assign(f2,'CONFIG.SKI');
  rewrite(f2);  { CONFIG }

    writeln(f2,integer(reg));
    writeln(f2,integer(comphrs));
    writeln(f2,integer(lct));
    writeln(f2,integer(diff));
    writeln(f2,integer(compactlist));
    writeln(f2,integer(invback));
    writeln(f2,integer(automatichrr));
    writeln(f2,integer(beeppi));
    writeln(f2,integer(nosamename));
    writeln(f2,integer(goals));
    writeln(f2,integer(diffwc));
    writeln(f2,integer(kosystem));

   writeln(f2,languagenumber);
   writeln(f2,trainrounds);
   writeln(f2,namenumber);
   writeln(f2,Setfile);

   writeln(f2,gdetail);
   writeln(f2,seecomps);
   writeln(f2,'0');
   writeln(f2,'0');
   writeln(f2,'0');

   writeln(f2,jmaara);

   for temp:=1 to jmaara do writeln(f2,jnimet[16-temp]);

   writeln(f2,pmaara);

   for temp:=1 to pmaara do
    begin
     writeln(f2,profileorder[temp]);

{     writeln(f2,nimet[NumPl+1-temp]);
     writeln(f2,haalarit[temp]); }
    end;

   if (kothwind) then temp:=1 else temp:=0;
    writeln(f2,temp);

   writeln(f2,kothrounds);

   writeln(f2,kothpack);
   writeln(f2,kothmaki);
   writeln(f2,kothmaara);

    for temp:=1 to kothmaara do
     writeln(f2,kothpel[temp]);

    for temp:=1 to 5 do writeln(f2,K[temp]); { n„ppiskomennot }

   writeln(f2,windplace);

    for temp:=1 to 2 do
     writeln(f2,'0');
(*
   writeln(f2,integer(BackGrSound));
   writeln(f2,integer(SBSounds));
   writeln(f2,SoundBankNumber);

   writeln(f2,BaseIO);
   writeln(f2,IRQ);
   writeln(f2,DMA); *)

  close(f2);

end;


procedure ResetHiscore(kerroin:byte);
begin

 GetNow(Now);

 ResetTops(kerroin,Today,Now);

 WriteRecords;

end;

procedure ResetConfig;
var temp:integer;
begin

  kothmaara:=1;
  for temp:=1 to 20 do kothpel[temp]:=temp;

  pmaara:=1;
  for temp:=1 to 20 do profileorder[temp]:=0;
  profileorder[1]:=1;

  jmaara:=1;

  { configien nollaus ocks† }

  languagenumber:=255; { se kysyy sitten alussa }

  beeppi:=false;
  gdetail:=0;

  namenumber:='0';

  trainrounds:=0;
{$IFDEF REG}lct:=true;{$ELSE}lct:=false;{$ENDIF}

  diff:=false; diffwc:=false;
  compactlist:=false;
  invback:=false;
  automatichrr:=true;

  goals:=true;
  kosystem:=true;
  seecomps:=1;

  comphrs:=true;
  nosamename:=false;

  DefaultKeys(K);
  windplace:=1;

  Setfile:='TEMP';

  WriteConfig;

end;


procedure ReadRecords;
var l1,l2,l3,l4,l5 : longint;
    f1 : text;
    temp : integer;
    str1 : string;
    name : NameStr;
    len : integer;
    time : TimeStr;

begin

  l1:=0; l2:=0; l3:=0; l4:=0; l5:=0;

  str1:='HISCORE.SKI';

  assign(f1,str1);
  {$I-}
  reset(f1);
  {$I+}
  Fileok(IOresult,str1);

  readln(f1,str1);  { se varoitusrivi pois sielt„ }

  for temp:=1 to 41 do  { 20 World Cup, 10 Team Cupia, 5 4hillsia ja 6 Kothia }
   begin
    readln(f1,top[temp].name);
{    topnimet[a]:=cryptstr(topnimet[a]); }
     inc(l1,valuestr(top[temp].name,temp));
    readln(f1,str1);
     inc(l2,valuestr(str1,temp));
    top[temp].pos:=uncrypt(str1,temp);
    readln(f1,str1);
     inc(l2,valuestr(str1,temp));
    top[temp].score:=uncrypt(str1,temp);
   end;

  for temp:=1 to NumWCHills do  { katso mit„ tehd„„n kun tehd„„n lis„„ m„ki„ }
   begin
    readln(f1,name);
     inc(l1,valuestr(name,temp));
    readln(f1,str1);
     inc(l2,valuestr(str1,temp));
    len:=uncrypt(str1,temp);
    SetHRInfo(temp,name,len,time);
   end;

   l1:=l1 xor 734697;

   readln(f1,l3);
   readln(f1,l4);
   readln(f1,l5);

    str(l1+l2+53,str1);

   for temp:=1 to 41 do
    readln(f1,top[temp].time);

   for temp:=1 to NumWCHills do
    begin
     name:=HRName(temp);
     len:=HRLen(temp);
     readln(f1,time);
     SetHRInfo(temp,name,len,time);
    end;

{   writeln(l5);
   writeln(valuestr(s,22));
   readln;                  }
{   writeln('L1',l1,' -  ',l3);
   writeln('L2',l2,'  -  ',l4);
   readln; }

   vcode:=0;
   {$I-} readln(f1,vcode); {$I+}
   if (vcode=0) or (IOResult<>0) then vcode:=1; { pre-v3.11 }

   close(f1);

   if (l1<>l3) or (l2<>l4) or (valuestr(str1,22)<>l5) then
    begin
     AsetaMoodi($3);
     writeln('Error #21A: Something doesn''t add up in the HISCORE.SKI file.');
     writeln('Maybe you tried to edit it or something.  Please don''t do it again.');
     ResetHiscore(1);
     ResetConfig;
     Waitforkey;
     Halt;
    end;
end;



procedure ReadConfig;
var f2 : text;
    str1 : string;
    temp : integer;
begin

  str1:='CONFIG.SKI';
  assign(f2,str1);
  {$I-}
  reset(f2);
  {$I+}
  Fileok(IOResult,str1);

  readln(f2,temp);
  readln(f2,temp);
   comphrs:=boolean(temp);
  readln(f2,temp);
   {$IFDEF REG}lct:=boolean(temp);{$ELSE}lct:=false;{$ENDIF}
  readln(f2,temp);
   diff:=boolean(temp);
  readln(f2,temp);
   compactlist:=boolean(temp);
  readln(f2,temp);
   {$IFDEF REG}invback:=boolean(temp);{$ELSE}invback:=false;{$ENDIF}
  readln(f2,temp);
   {$IFDEF REG}automatichrr:=boolean(temp);{$ELSE}automatichrr:=false;{$ENDIF}
  readln(f2,temp);
   beeppi:=boolean(temp);
  readln(f2,temp);
   nosamename:=boolean(temp);
  readln(f2,temp);
   goals:=boolean(temp);
  readln(f2,temp);
   diffwc:=boolean(temp);
  readln(f2,temp);
   kosystem:=boolean(temp);

  readln(f2,languagenumber);
  readln(f2,trainrounds);
   {$IFNDEF REG}trainrounds:=0;{$ENDIF}

  readln(f2,namenumber);
   {$IFNDEF REG}namenumber:='0';{$ENDIF}

  setfile:='TEMP';
  readln(f2,str1);
   if (fexist(str1+'.SJC')) then setfile:=upstr(str1);

  readln(f2,gdetail);
  readln(f2,seecomps);

  readln(f2,temp);
  readln(f2,temp);
  readln(f2,temp);

  readln(f2,jmaara);

  for temp:=1 to jmaara do readln(f2,jnimet[NumTeams+1-temp]);

  if (jnimet[NumTeams]='') then jnimet[NumTeams]:='Team Finlando';

  readln(f2,pmaara);

  if (pmaara>0) and (pmaara<11) then
   for temp:=1 to pmaara do
    begin
     readln(f2,profileorder[temp]);
{     readln(f2,nimet[NumPl+1-temp]);
     readln(f2,haalarit[temp]); }
    end
     else
      pmaara:=1;

  {$IFNDEF REG}if (pmaara>2) then pmaara:=2;{$ENDIF}

  readln(f2,temp);
   kothwind:=boolean(temp);

  readln(f2,kothrounds);
  readln(f2,kothpack);
  {$IFNDEF REG}if (kothpack<1) or (kothpack>6) then kothpack:=1;{$ENDIF}
  readln(f2,kothmaki);
  readln(f2,kothmaara);

  if (kothmaara>20) or (kothmaara<0) then kothmaara:=1;

  for temp:=1 to 20 do kothpel[temp]:=temp;  { ettei siell„ ole nollia }

  for temp:=1 to kothmaara do
   readln(f2,kothpel[temp]);

  DefaultKeys(K);

  for temp:=1 to 5 do
   readln(f2,K[temp]);

  readln(f2,windplace);

{  for temp:=1 to 6 do
   readln(f2,str1); }

(* readln(f2,temp);
    BackGrSound:=boolean(temp);
   readln(f2,temp);
    SBSounds:=boolean(temp);

   readln(f2,SoundBankNumber);

   readln(f2,BaseIO);
   readln(f2,IRQ);
   readln(f2,DMA); *)

  close(f2);

end;



procedure setupmenu;
var index : array[0..4] of integer;
{    ch,ch2 : char; }
    str1, str2 : string;
    f3 : text;
    ok, out : boolean;
    temp : integer;
    screen, entries, length : byte;
begin

 for temp:=0 to 4 do index[temp]:=1;
 screen:=0;

 Out:=False;

 repeat

  newscreen(1,0);

  fontcolor(240);

  case screen of
  0 : begin
       str1:=lstr(175);
       entries:=6;
       length:=221;
      end;
  1 : begin
       str1:=lstr(176);
       entries:=4;
       length:=221;
      end;
  2 : begin
       str1:=lstr(177);
       entries:=11;
       length:=221;
      end;
  3 : begin
       str1:=lstr(178);
       entries:=5;
       length:=221;
      end;
  end;

  writefont(30,6,str1);

  for temp:=0 to entries do
   begin

    str1:='';

    case screen of
    1 : case temp of
        1 : if (languagenumber<255) then str1:=lnames[languagenumber]
                                    else str1:='Undecided';

{        2 : if (coachstyle>0) then str1:=lstr(361+coachstyle*40)
                              else str1:=lstr(9); }
        2 : if (beeppi) then str1:=lstr(6) else str1:=lstr(7);
        3 : str1:=lstr(13+gdetail);
        4 : begin
             str1:=namenumber;
              assign(f3,'NAMES'+namenumber+'.SKI');
              {$I-}
              reset(f3);
              {$I+}
              if (IOResult=0) then
               begin
                readln(f3,str2);
                close(f3);
                fontcolor(241);
                writefont(40,78,str2);
               end;
            end;

{        6 : str1:=teamnumber; }
        end;

    2 : case temp of
        1 : if (trainrounds=0) then str1:=lstr(9)
                               else str1:=lstr(trainrounds);
        2 : if (lct) then str1:=lstr(180) else str1:=lstr(185);
        3 : if (diff) then str1:=lstr(181) else str1:=lstr(186);
        4 : if (diffwc) then str1:=lstr(181) else str1:=lstr(186);
        5 : if (compactlist) then str1:=lstr(182) else str1:=lstr(187);
        6 : if (InvBack) then str1:=lstr(183) else str1:=lstr(188);
{        6 : if (preview1) then str1:=lstr(181) else str1:=lstr(185); }
        7 : if (automatichrr) then str1:=lstr(182) else str1:=lstr(185);

        8 : if (goals) then str1:=lstr(180) else str1:=lstr(186);
        9 : if (seecomps>NumPl) then str1:=lstr(seecomps) else str1:='#'+txt(seecomps);

{        8 : str1:=txt(windplace); }
       11 : if (kosystem) then str1:=lstr(182) else str1:=lstr(185);
        end;

    3 : case temp of
        1 : if (comphrs) then str1:=lstr(183) else str1:=lstr(187);
        2 : if (nosamename) then str1:=lstr(185) else str1:=lstr(180);
        end;
    end; { screen case }

    SetupItem(temp,screen,entries,str1);

   end;

{$IFNDEF REG}
  if (screen<3) then
   begin
    fontcolor(241);
    writefont(10,185,lstr(208)+' '+lstr(209));
    fontcolor(240);
   end;
{$ENDIF}

  DrawScreen;

   index[screen]:=MakeMenu(35,40,length,10,entries,index[screen],243,0,0);

  case screen of
   0 : begin

        case index[screen] of
        1,2,3 : screen:=index[screen];
        4 : configurekeys(K);
{$IFDEF REG}
        5 : setgoals;
        6     :  begin
                  WriteExtras;
                  HillMaker(0);
                  ReadExtras;
                 end;
{$ENDIF}
        0     : Out:=true;
        end;

{        index[screen]:=1; }

       end;
   1 : case index[screen] of
       1 : begin
             WelcomeScreen(languagenumber);
           end;
       2 : beeppi:=not beeppi;
       3 : begin
            inc(gdetail);
            if (gdetail>1) then gdetail:=0;
           end;
{$IFDEF REG}
       4 : begin
            repeat
             ok:=false;
             getch(255,70,245,ch,ch2);

             if (ch<>#27) then
              begin
               assign(f3,'names'+ch+'.ski');
               {$I-}
               reset(f3);
               {$I+}
               if (IOResult=0) then
                begin
                 ok:=true;
                 close(f3);
                end;
              end else ok:=true;

            until (ok);

             if (ch<>#27) then
              begin
               namenumber:=ch;
               loadnames(namenumber,jmaara,TeamLineup,true);
              end;

           end;
{$ENDIF}

       0 : screen:=0;

       end;
   2 : case index[screen] of
{$IFDEF REG}
       1 : begin
            inc(trainrounds);
            if (trainrounds>3) then trainrounds:=0;
           end;
       2 : lct:=not lct;
{$ENDIF}
       3 : diff:=not diff;
       4 : diffwc:=not diffwc;
       5 : compactlist:=not compactlist;
{$IFDEF REG}
       6 : invback:=not invback;
       7 : automatichrr:=not automatichrr;
       8 : goals:=not goals;
{$ENDIF}
       9 : chooseseecomps(seecomps);
{$IFDEF REG}
      10 : choosewindplace(windplace);
{$ENDIF}
      11 : kosystem:=not kosystem;

       0 : screen:=0;

       end;
   3 : case index[screen] of
       1 : comphrs:=not comphrs;
       2 : nosamename:=not nosamename;
       3,4 : begin
              fillbox(69,79,251,131,242);
              fillbox(70,80,250,130,244);
              fillarea(70,80,250,130,63);
              str1:=lstr(190);

              if (index[screen]=4) then str1:=lstr(191);
              writefont(80,90,str1+' '+lstr(192));
              writefont(80,110,lstr(193));

              getch(88+fontlen(lstr(193)),110,243,ch,ch2);

              if (upcase(ch) = lch(6,1)) then ResetHiscore(4-index[screen]);
             end;
       5 : begin
            ResetConfig;
           end;
       0 : screen:=0;
       end;
(*
     A : begin
            clrwhole(0);
            SoundSetup(BaseIO,IRQ,DMA,SoundBankNumber,SBSounds,BackGrSound,reg);
           end;
*)

    end;  { screen case }

  until (Out);

{  readkey; }

 WriteConfig; { pistet„„n muutokset levylle }

end;




procedure ResetStats;
var aaa,bbb,ccc : byte;
begin
 for aaa:=0 to 15 do
  for bbb:=0 to NumWcHills do
   begin
    Stats[aaa,bbb].CompPos:=0;
    Stats[aaa,bbb].WCPos:=0;
    Stats[aaa,bbb].CompPts:=0;

    for ccc:=1 to 2 do
     begin
      Stats[aaa,bbb].RoundPts[ccc]:=0;
      Stats[aaa,bbb].RoundLen[ccc]:=0;
      Stats[aaa,bbb].Reason[ccc]:=0;
     end;

   end;
end;


procedure hyppy(index,pel,team:integer);
var { SoundOn : array[0..5] of boolean; }

    tempb : byte;
    temp,temp2 : integer;

{   ch,ch2 : char; } { for #0 }

    statsvictim : integer;

    JumperAnim, SkiAnim, ponnphase : byte;

    kr : integer;
    ponnistus : integer;
    qx : single;

{    KeulaX : integer; }

    paras : integer;

    kor,matka,px,pxk,py,t,pl,kkor {,makikulma} : single;

    umatka, ukor, upx : single;
    ux : integer;

    kulma1, kulmas, hp, x, y, height : integer;

    deltah : array[0..5] of integer;

    sx, sy, fx, fy, keulaY : integer;

    wrx, wry, goalx, goaly {, tuulisafe} : integer;

    DeltaX, DeltaY : integer;  { vaikkakin maki.x ja y ovat longintej„ }

    ok, out, hillrecord : boolean;
    kupat, clanding, landing, grade : byte;

    riski, laskuri : longint;
    tyylip : array[1..7] of integer;
    LMaara : word;
{    LStyle : byte; }

    score : integer;

    kulmalaskuri : integer;

    startanim, ssuunta : integer;

    namestr, str1, str2 : string;
    replayfilename, replayname : string;

    cjumper, draw, mcliivi : boolean;
    reflex, skill, maxspeed : byte;

    RTurns : integer;
    RstartX, RstartY : integer;
    RFlstart, RFlstop : integer;
    RD : array[0..4,0..1000] of byte;

    f1 : text;

    top5 : array[0..6] of byte;

    ActProfile : byte; { aktiivine profiili }

function MakiKulma(x:integer):integer;
var value:integer;
begin

  value:=Profiili(x+9)+Profiili(x+8)+Profiili(x+7)+Profiili(x+6);
  value:=value-Profiili(x-3)-Profiili(x-4)-Profiili(x-5)-Profiili(x-2);

   if ((x>KeulaX-15) and (x<=KeulaX)) { or (x>1015) } then value:=0;

 MakiKulma:=value;

end;

procedure drawkothinfo(pel:integer);
{var apu1, apu2, apu3 : integer; }
var str1 : string;
begin

 str1:=lstr(67)+' '+txt(1+kothmaara+pmaara-mcpisteet[0]);
 str1:=str1+' '+lstr(8)+' '+txt(kothmaara+pmaara);

 ewritefont(308,9,str1);

 if (top5[1]>0) then
  begin
   str1:=lstr(68);

   if (kierros=1) and (kothrounds>1) then str1:=lstr(69);

   ewritefont(308,19,str1);

   str1:=txtp(pisteet[top5[1]]);

   if (kierros=2) then str1:=txtp(pisteet[top5[1]]-pisteet[pel]);

   ewritefont(308,29,nimet[top5[1]]+'$'+str1);
  end;
end;




procedure drawkeymap;
var temp : integer;
begin

{ fontcolor(240); }

 DrawAnim(227,2,64);

 fontcolor(246);
 ewritefont(308,9,lstr(330));

 for temp:=1 to 5 do
  begin
   ewritefont(308,temp*10+9,lstr(330+temp)+': '+keyname(K[temp]));
  end;
 fontcolor(247);

end;


procedure drawtop5info(index, pel:integer);
var str1 : string;
    temp : integer;

begin

 ewritefont(308,9,acthill.name+' K'+txt(acthill.kr));

 for temp:=1 to 5 do
  begin
   if (pisteet[top5[temp]]>0) then
    begin

     str1:=txtp(pisteet[top5[temp]]);

     if (diff) and (temp>1) then str1:=txtp(pisteet[top5[temp]]-pisteet[top5[1]]);

     if (jcup) then str1:=jnimet[top5[temp]]+'$'+str1
               else str1:=nimet[top5[temp]]+'$'+str1;

     ewritefont(308,13+temp*7,str1);

    end;
  end;

  str1:=lstr(62);
  if (kierros=2) and (index=1) and (wcup) then str1:=lstr(63);

  temp:=pisteet[top5[1]]-pisteet[pel];

  if (temp>0) then ewritefont(308,62,str1+': '+txtp(temp+1));

end;




procedure drawwcinfo;
var str1 : string;
    temp : integer;

begin

 if (jcup) then ewritefont(308,9,lstr(71))
           else ewritefont(308,9,lstr(70));

 for temp:=1 to 5 do
  begin
   if (mcpisteet[mcluett[temp]]>0) then
    begin

     str1:=txt(mcpisteet[mcluett[temp]]);

     if (diffwc) and (temp>1) then str1:=txt(mcpisteet[mcluett[temp]]-mcpisteet[mcluett[1]]);

     if (jcup) then str1:=jnimet[mcluett[temp]]+'$'+str1
               else str1:=nimet[mcluett[temp]]+'$'+str1;

     ewritefont(308,13+temp*7,str1);
    end;
  end;

end;

procedure drawhrinfo;
begin
 ewritefont(308,9,acthill.name+' K'+txt(acthill.kr));
 ewritefont(308,19,lstr(65));
 ewritefont(308,29,HRName(nytmaki));
 ewritefont(308,39,txtp(HRLen(nytmaki))+'«');
 if (goals) and (nytmaki<=NumWcHills) then ewritefont(308,49,lstr(242)+': '+txtp(loadgoal(nytmaki)));

end;


procedure drawinfo(var l:longint;index,pel:integer);
begin

 if (pisteet[top5[1]]=0) or (kierros<0) then
  begin { ei tuloksia n„ytett„v„n„ }
   if ((wcup) or (jcup)) and (mcpisteet[mcluett[1]]>0) then
    begin
     case l of
     0..130 : drawhrinfo;
     146..276 : drawwcinfo;
     291 : l:=0;
     end;
    end else drawhrinfo;
  end else
    begin { on tuloksia }
     if (koth) then
      begin
       case l of
        0..130 : drawkothinfo(pel);
        146..276 : drawhrinfo;
        291 : l:=0;
       end;
      end
       else
       case l of
        0..130 : drawtop5info(index,pel);
        146..276 : drawhrinfo;
        292..422 : if (mcpisteet[mcluett[1]]>0) then drawwcinfo else l:=0;
        437 : l:=0;
       end;
    end;
end;


procedure jarjesta5(index:integer);
var num : byte;
    apu1, apu2, apu3 : integer;
begin

 for apu1:=1 to 5 do top5[apu1]:=0;

 if (koth) then  { haetaan huonoin }
  begin

   apu2:=30000; apu3:=0;                   { hae huonoin t„h„n menness„ }

   for apu1:=1 to index-1 do
    if (mcpisteet[mcluett[apu1]]=0) then { jos pelaaja mukana ja ei itse? KOTH }
     if (pisteet[mcluett[apu1]] < apu2) then
      begin
       apu2:=pisteet[mcluett[apu1]];
       apu3:=mcluett[apu1];
      end;

   if (apu2<>30000) then
    begin
     top5[1]:=apu3;
    end;

  end else

  begin

   if (jcup) then num:=NumTeams else num:=NumPl;

   for apu1:=1 to num do
    begin
     apu2:=1;
     repeat   { Verrataan jokaiseen }
       if (pisteet[apu1]>pisteet[top5[apu2]]) then
        begin
          for apu3:=5 downto apu2+1 do
           top5[apu3]:=top5[apu3-1];

          top5[apu2]:=apu1;

          apu2:=num;
        end;
      inc(apu2);

     until (apu2>=6);
   end;
  end;
end;


function writereplay(author,name:string):byte;
var t1, t2 : integer;
    check : longint;
    result: byte;

begin

 {$I-}
 Assign(f1,replayfilename+'.SJR');
 Rewrite(f1);
 {$I+}
 Result:=0;

 if (IOResult=0) then
  begin
   check:=0;
   writeln(f1,RStartX); writeln(f1,RStartY); inc(check,RStartx*2+RStarty);
   writeln(f1,RTurns); inc(check,Rturns*3);
   writeln(f1,nytmaki); if (nytmaki<=numwchills) then inc(check,smallint(nytmaki*131));
   str1:='HILLBASE';
   if (nytmaki>NumWCHills) then str1:=hillfile(nytmaki-NumWCHills);
   writeln(f1,str1); inc(check,word(valuestr(str1,3)*3));
   writeln(f1,Acthill.profile); inc(check,Acthill.profile);
   writeln(f1,lmaara);
   writeln(f1,hp);  inc(check,smallint((hp+2)*69));
   writeln(f1,RFLStart);
   writeln(f1,RFLStop);  inc(check,rflstart+rflstop);
   writeln(f1,WRx); writeln(f1,WRy); inc(check,smallint((WRx+WRy)*2));
   writeln(f1,Profile[actprofile].suitcolor);
   writeln(f1,Profile[actprofile].skicolor);

   writeln(f1,author); inc(check,valuestr(author,2));
   writeln(f1,name);
   writeln(f1,dayandtime(Today,Now));
   writeln(f1,integer(mcliivi));
   t1:=0; { kisailmaisu tai 100-startgate }
   if (treeni) then t1:=100-startgate;
   if (wcup) then t1:=cupstyle+1;
   if (jcup) then t1:=4;
   if (koth) then t1:=5;
   writeln(f1,t1); inc(check,smallint(t1*1412));

   writeln(f1,check xor 3675433);
   writeln(f1,'0');

   writeln(f1);
   writeln(f1,'--- Replay Data --- ');

   write(f1,'*');

   for t1:=0 to 1000 do
    for t2:=0 to 4 do
     write(f1,char(RD[t2,t1]));

   Close(f1);

 end else result:=1;

 writereplay:=result;

end;




begin

 kr:=acthill.kr;

 ch:=#0;

  RTurns:=0;

 if (eka) then
  begin

   LMaara:=Random(2)*Random(256);
   if (Lmaara>0) and (Lmaara<40) then Lmaara:=41+random(150);
   if (Lmaara>0) and (random(4)=0) then inc(Lmaara,1000); { r„nt„ }
{   Lmaara:=1151; }

   VieLmaara(Lmaara);

{   LStyle:=Random(2)*Random(2);
   LStyle:=1; }

   if (gdetail=1) then LMaara:=0;

   if (LoadHill(KeulaX, nytmaki, Acthill)<>0) then
    begin
     ch:=#27;
     cupslut:=true;
    end;

   Maki.X:=0;
   Maki.Y:=0;
    DrawHillScreen;

   Tuuli.Hae;

  end;

  SiirraStandardiPaletti;

  if (LMaara>1000) then TummaLumi;

  if (eka) then AsetaPaletti;

  cjumper:=true;
  draw:=false;

  if (pel > NumPl-pmaara) then  { oma j„tk„ }
   begin
    cjumper:=false;
    draw:=true;
   end;

  temp:=0;

  if (seecomps>NumPl) then  { jos ei suoraa pelaajavalintaa }
   begin
    case (seecomps) of { ketk„ n„ytet„„n }
     235 : temp:=1;
     236 : temp:=3;
     237 : temp:=5;
     238 : temp:=10;
     239 : temp:=100;
    end;

    temp2:=index;
    if (koth) or (jcup) then temp2:=team; { koth: t„nne johdetaan se realindex }
    if (temp2 <= temp) then draw:=true;
   end
    else
     begin { suora pelaaja }
      if (seecomps=pel) then draw:=true;
     end;

  statsvictim:=0; actprofile:=0;

  LoadSuit(pel mod NumSuits,0);
  LoadSkis(pel mod NumSkis,0);

  if (not cjumper) then
   begin
    statsvictim:=NumPl+1-pel;     { antaa pelaajan numeron 1..10 }
    actprofile:=profileorder[statsvictim];
    LoadSuit(Profile[actprofile].suitcolor,0);
    LoadSkis(Profile[actprofile].skicolor,0);
   end;

  mcliivi:=true;
  if (mcluett[1]<>pel) or (treeni) or (koth) then mcliivi:=false;

  if (not mcliivi) then SiirraLiiviPois;

{  AsetaPaletti; }


(*
  if (koth) then draw:=true; { KYSEENALAINEN! }
*)

{  draw:=true;
   cjumper:=true; }


(*
  if (not cjumper) and (jcup) then statsvictim:=index+((pel-1)*4); { toivottavasti tekee saman }
*)
                             { NumPl+1-pel+4*(team-1) }
  temp:=random(80);   { 120 }
  dec(temp,random(24*pel)); { 34,32, 30, 25,20, 13 ennen muutosta }
  dec(temp,random(12*pel));  { 17,16,15, 12, 8,  5  e.m. }
  dec(temp,random(10*pel)); { uusi }
  temp:=63-temp;           { 80,100,110,114,119,119  e.m. }

  skill:=17-round(nsqrt(temp)/4);

  if (skill>16) then skill:=16;

  reflex:=round((34+pel+random(10))/5);
{  reflex:=round((33+pel+random(8))/4); }
{  reflex:=round((45+pel+random(10))/5); }
{  reflex:=round((30+1+random(30))/5); }

  { floppihyppy }
  if (random(300-pel)=0) then skill:=17+random(3+pel div 25);

{  skill:=16; }

   GetNow(Now); { haetaan current time }

  Maki.X:=0;
  Maki.Y:=0;

 x:=0; y:=0; sx:=0; sy:=0; fx:=0; fy:=0;  { Former X & Y }
 hp:=0;
 paras:=0; { treenijuttuja }

 KeulaY:=Profiili(KeulaX);  { helpottaa vaan }

 pl:=acthill.plsave;  { plsave on m„enparametreja }
 maxspeed:=acthill.vxfinal; { n„in voidaan lavaa vaihtaa... }

{ pl:=0.34;  temps }

{ vxfinal:=150;  lopullinen nopeus pit„is olla GLOBAL tai jotain }

  tyylip[1]:=195;  { ennen 200, v3.0 195 }
  tyylip[6]:=200;
  tyylip[7]:=0; { tyylip[6] => pienin, [7] => suurin }

 qx:=KeulaX+0.5; { emme halua, ett„ se toteaa keulalla matkan>0 }

 wrx:=0; wry:=0; goalx:=0; goaly:=0;
 matka:=0;

 { haetaan m„kienkkakepille mesta! }

 temp:=0;
 if (nytmaki<=NumWcHills) then temp:=loadgoal(nytmaki);

 if (draw) then
   repeat
    matka:=matka+1;

    x:=round(matka+qx);
    kor:=Profiili(x);
    kkor:=kor-KeulaY;
    hp:=round(nsqrt((matka*matka)+(kkor*kkor))*acthill.pk*0.5)*5;

    if (hp>=HRLen(nytmaki)) and (HRLen(nytmaki)>0) and (wrx=0) then
     begin wrx:=x; wry:=round(kor)-9; end;

    if (hp>=temp) and (temp<>0) and (goalx=0) then
     begin goalx:=x; goaly:=round(kor)-7; end;

   until (x>1024);


  hp:=0;
  kkor:=0;

  matka:=-KeulaX+10;
   qx:=KeulaX+0.5; { emme halua, ett„ se toteaa keulalla matkan>0 }

  x:=round(matka+qx);

  kor:=Profiili(x);  { alasp„in on positiivinen }

  y:=round(kor);

(*
  qy:=-Profiili(KeulaX);  { x & y kompensaatteja n„ytt”„ varten }
  *)

  ponnistus:=0; Out:=False; Ok:=True;  { OK to be used w/ ei ponnistanut }
  height:=0; { „ij„n korkeus m„est„ }
(*  fheight:=0; { edellinen korkeus } *)
  for temp:=0 to 5 do DeltaH[temp]:=0;
  riski:=0; { kaatumisriski }

  landing:=0; { 0 - ei, 1 - telemark, 2 - tasajalka }
  clanding:=0; { tuleva lask. 0 - ei, 1 - tele, 2 - tasa }
  kupat:=0;   { 0 - ei, 1 - oma moka, 2 - huono s„k„ }

  ponnphase:=0;  { t„m„ m„„r„„ animaation asennon ukossa }


  py:=0; { vauhtia Y-akselin ei oo, tai on mutta summa=0 }

  px:=0;  { T„t„ kerrotaan pxk:lla, kunnes px = vxfinal; }
  pxk:=1.016; { hyv„ kerroin }

  t:=0;  { aika }

  kulma1:=0; { Žij„n kropan kulma }
 { kulmas:=900; } { Suksien kulma }
  kulmas:=0; { Suksien kulma }

  ssuunta:=0;  { sukset eiv„t liiku mihink„„n }

  replayname:='?'; replayfilename:='TEMP';

{ temp:=1; temp2:=0; }



{  Port[$3c8]:=15; Port[$3c9]:=63; Port[$3c9]:=33; port[$3c9]:=33; }

{  x:=round(matka)+qx;
   y:=Profiili(x); }


{  fillbox(0,9,319,16,10);

  for a:=0 to 11 do
   drawanim(10+a*20,20,a+87);

  writefont(1,10,1,'Ville Juhana K”n”nen 118.3 (165.5«)'); }

{  writefont(1,10,1,'ABCDEFGHIJKLMNOPQRSTUVXYZŽ™1234567890«"().:,''#*-+?!'); }

{  fillbox(100,100,200,183,240); oikea neliskantti 320x200:ssa }

   Maki.Tulosta;

(*    FontColor(251); { p„„fonttiv„ri }  *)

  namestr:=nimet[pel];

(*
  if (jcup) then namestr:=nimet[NumPl+1-statsvictim]
   else if (treeni) then namestr:=nimet[NumPl+1];
*)

  str1:=namestr;

  if (wcup) then
   begin
    if (kierros=2) then str1:=str1+' ('+txt(index)+'.)';
    if (kierros=0) and (qual[pel]>0) then str1:=str1+' Q WC';
   end;

{   writefont(32,4,15,'NEXT '+nimet[51-pel]); }

  str2:=lstr(51);

  case kierros of
  -5..-1 : str2:=lstr(52)+' '+txt(abs(kierros));
   0..2 : str2:=lstr(53+kierros);
  end;

  if (kierros=2) and (wcup) and (draw) then fontcolor(241);

{
  writefont(200,10,'VXF '+txt(acthill.vxfinal));
  writefont(200,20,'PL '+txt(round(pl*100)));
  writefont(200,30,'PK '+txt(round(acthill.pk*100)));
}
  jarjesta5(index);

{  drawtop5info(index, pel); }

{  DrawScreen; }

{  cupslut:=waitforkey3(180,ch); }

  DeltaX:=Maki.X;
  DeltaY:=Maki.Y;

  laskuri:=0;  { t„t„ k„ytet„„n laskurina seuraavassa }

{  testspeed; }

 AsetaPaletti;

{ Tuulisafe:=Tuuli.value; }

 Tuuli.Hae;

 if (draw) and (ch<>#27) then
  repeat  { INFORUUTU LUUPPI! }

   inc(laskuri);

   Maki.Tulosta;

{   Tuuli.Hae; }

   DrawLumi(DeltaX-Maki.X,DeltaY-Maki.Y,Tuuli.Value,LMaara,true);

{   writefont(5,100,txtp(fourpts[pel])); }

{   writefont(100,100,txt(wrx));
    writefont(100,110,txt(wry));
     drawanim(100,90,68);
     drawanim(100,192,68); }

   DrawAnim(227,2,64);
   DrawAnim(3,150,65);

   FontColor(247);

   Writefont(12,160,str2);
   Writefont(12,172,lstr(56));

   if (treeni) then writefont(67+fontlen(lstr(58)),27,'(+/-)');

   if (jcup) then WriteFont(14+fontlen(lstr(56)),179,jnimet[team]);

   if (not cjumper) then FontColor(240);
{                else FontColor(240); }

   WriteFont(12+fontlen(lstr(56)),172,str1); { nimi ruutuun }


   if (treeni) then writefont(64,19,lstr(58));

   Fontcolor(241);

   if (kierros=2) and (wcup) then
     Writefont(14+fontlen(lstr(56)),179,txtp(pisteet[pel])+' ('+txtp(Cstats[1,pel])+'«)');
   Writefont(12,191,lstr(59));


   FontColor(246);

   if (treeni) then writefont(70+fontlen(lstr(58)),19,txt(startgate));
                                     {252}
   temp:=pel;
   if (jcup) then temp:=team;
    DrawInfo(laskuri, index, temp);

{   if (ex) then  balk(0); }

{    if (ex) then  balk(1); }

   DrawScreen;

   ch:=#1;

   if (SDLPort.KeyPressed) then
    begin
     SDLPort.WaitForKeyPress(ch,ch2);
     if (ch=#0) and (ch2=#68) then begin cupslut:=true; ch:=#27; end;
     if (upcase(ch)=lch(60,1)) then
      begin
       SetupMenu;
       ch:=#1;
       LoadSuit(Profile[actprofile].suitcolor,0);
       LoadSkis(Profile[actprofile].skicolor,0);
       mcliivi:=true;
       if (mcluett[1]<>pel) or (treeni) or (koth) then mcliivi:=false;
       if (not mcliivi) then SiirraLiiviPois;
       Tuuli.AsetaPaikka(windplace);
      end;

     if (treeni) then
      begin
       if (ch='+') then begin inc(startgate); ch:=#1; end;
       if (ch='-') then begin dec(startgate); ch:=#1; end;
       if (startgate<1) then startgate:=1;
       if (startgate>30) then startgate:=30;
      end;
    end;

  until (ch<>#1);

  if (treeni) then maxspeed:=maxspeed+(startgate-15);

(*
  if (keypressed) then
   begin
    ch:=readkey;
    if (ch=#0) then if (readkey=#68) then begin cupslut:=true; ch:=#27; end;
   end;
*)

  laskuri:=0;  { t„t„ ehk„ k„ytet„„n laskurina seuraavassa }
  Out:=false;

 if (draw) then
  begin
   MuutaLogo(6);
   AsetaPaletti;
  end;

  SkiAnim:=SuksiLaskussa(MakiKulma(x));
  JumperAnim:=164;

  KulmaLaskuri:=0; { k„ytet„„n t„t„ parruanimia }
  px:=0;

  if (draw) then FontColor(247);

  RstartX:=x;
  RstartY:=y;

 if (ch<>#27) and (draw) then  { ISTUU PARRULLA LUUPPI }
  repeat

   if (not treeni) then inc(laskuri);

   Tuuli.Hae;

   Maki.Tulosta;

{   PutPixel(KeulaX-Maki.X,Profiili(KeulaX)-Maki.Y,15); }

{   tempb:=SuksiAnim(x); }

   if (kulmalaskuri>3024) and (kulmalaskuri<4000) then
    begin
     temp:=kulmalaskuri-3024;
     sx:=x-Maki.X+4;
     sy:=y-Maki.Y-10;

     if (temp=1) then px:=0.6;
     px:=px+((tuuli.value-20)/10000);

     inc(sx,round(temp*px));
     inc(sy,(temp*temp) div 160);

     if (sy< profiili(sx)) then putpixel(sx,sy,225)
                           else kulmalaskuri:=0;

    end;

  if (laskuri<350) or (laskuri mod 40 > 19) then
   DrawAnim(x-Maki.X+60,y-Maki.Y-10,67); { liikennevalo1 }

   DrawAnim(x-Maki.X,y-Maki.Y-2,JumperAnim);
   DrawAnim(x-Maki.X,y-Maki.Y-1,SkiAnim);

   DrawLumi(DeltaX-Maki.X,DeltaY-Maki.Y,Tuuli.Value,LMaara,true);

{   Lumi.Update(Video,128,(DeltaX-Maki.X)*2,(DeltaY-Maki.Y)*2); }

{   Writefont(x-Maki.X,y-Maki.Y-20,1,txt(height)); }
{    Writefont(x-Maki.X,y-Maki.Y-15,txt(haalarit[statsvictim]));
    Writefont(x-Maki.X+15,y-Maki.Y-15,txt(statsvictim)); }
{    Writefont(x-Maki.X+15,y-Maki.Y-15,txt(index)); }

{  if (cjumper) then ewritefont(308,9,'(C)'); }
  if (cjumper) then writefont(x-Maki.X,y-Maki.Y-20,'C');

{  if (cjumper) and (laskuri mod 40 < 20) then
    ewritefont(308,9,'(COMPUTER)'); }

  if (windplace>10) then Tuuli.Tuo(x-Maki.X,y-Maki.Y);

  if (laskuri<700) then Tuuli.Piirra;

  if (eka) and (osakilpailu=1) and (not cjumper) then drawkeymap;

{  if (ex) then balk(0); }

 {    inc(Rturns); }

{  if (ex) then balk(1); }

  DrawScreen;

  ch:=#0; ch2:=#0;

  if (SDLPort.KeyPressed) then
   begin
    SDLPort.WaitForKeyPress(ch,ch2);
    ch:=upcase(ch);
    if (ch=#0) and (ch2=#68) then begin cupslut:=true; ch:=#27; end;
    if (not cjumper) and ((kword(ch,ch2)=K[2]) or (ch=#13)) then out:=true; { liikkeelle }
    if (ch=#0) and (ch2=#63) and (wcup) and (cupstyle=1) and
       (index=NumPl) and (kierros=1) and (osakilpailu=1) then begin Tuuli.Alusta(windplace); end;
    if (ch=#27) then out:=true;
   end;
     if (cjumper) and ((random(100)=0) or (laskuri>600)) then Out:=True;
   if (cjumper) and (random(100)=0) and (kulmalaskuri=0) then
    begin
     kulmalaskuri:=(random(3)+1)*1000;
     sx:=0; sy:=0;
    end;

   if (kulmalaskuri>0) then inc(kulmalaskuri);

   if (kulmalaskuri=0) and (not cjumper) then
    begin
     if (kword(ch,ch2)=K[3]) then kulmalaskuri:=3000;
     if (kword(ch,ch2)=K[4]) then kulmalaskuri:=2000;
     if (kword(ch,ch2)=K[1]) then kulmalaskuri:=1000;

     sx:=0;
     sy:=0;

    end;

   JumperAnim:=ParruAnim(kulmalaskuri);

   if (ch=#27) and (cjumper) then JumperAnim:=164; { emm„ haluu tsiigaa }

  until ((Out) and (JumperAnim=164)) or (laskuri>700);

  sx:=0;
  sy:=0;

  if (laskuri>700) then   { ei sitten kaveri l„htenytk„„n }
    begin
     if (beeppi) then beep(2);
     muutalogo(4); { vihre„ pois }
     asetapaletti;
     DrawAnim(x-Maki.X+60,y-Maki.Y-10,67); { liikennevalo }

     DrawAnim(3,150,65);

     fontcolor(240);
      writefont(12,160,namestr+' '+lstr(79));

     drawscreen;

     waitforkey;
     ch:=#27;
    end;

  Out:=False;

{  temp:=67; }

  laskuri:=0;
  px:=0;

 if (ch=#27) and (draw) and (cjumper) then  { emm„ haluukkaan tsiigata }
  begin
   draw:=false;
   ch:=#0;
  end;

{  pl:=0.10; }

 if (cjumper) and (not draw) then { nopeutetaan v„h„n :) }
  begin
   px:=acthill.vxfinal;
   matka:=-45;
   for temp:=1 to 100 do Tuuli.Siirra; { veivataan my”s tuulta v„h„n }
  end;

  kulmalaskuri:=200;
{  reflexlaskuri:=0; }
{
 writefont(100,100,'ch: '+txt(byte(ch)));
 writefont(100,110,'m: '+txt(round(matka)));
 drawscreen;
 readkey;
}

 if (ch<>#27) then { hyppy - main }
  repeat

   Tuuli.Hae;

{   tuuli:=-10; }

   matka:=matka+(px*0.01);

    fx:=x;  { former x & y }
    fy:=y;

   x:=round(matka+qx);

   if (Ch<>#27) then Ch:=#0;  { en tied„ muisteleeko se vanhoja }
   ch2:=#0;

   if (SDLPort.KeyPressed) then
      begin
       SDLPort.WaitForKeyPress(ch,ch2);
       ch:=upcase(ch);

{       if (cjumper) then ch:=#1; }

       if (ch=#0) and (ch2=#68) then
        begin
         cupslut:=true;
         ch:=#27;
         Out:=True;
        end;

       if (ch=#27) then
        begin

         if (cjumper) then
          begin
           Draw:=False;
           if (px<37) then px:=37;
          end
           else Out:=True;

        end;

        if (cjumper) then begin ch:=#0; ch2:=#0; end;

        if (ch='P') then SDLPort.WaitForKeyPress(ch,ch2);

      end;


{       if (ch='q') then kulma1:=49;
        if (ch='w') then kulma1:=51; }

{     if (matka=0) then beep(5); }

    if (matka>=0) then  { matka => 0 eli kun matka=0 ollaan jo lennossa }
     begin

      inc(laskuri);

      if (kulma1<kulmalaskuri) then kulmalaskuri:=kulma1;
{      if (LentoAnim(kulma1) > 107) and (landing=0) then inc(reflexlaskuri); }

      if (cjumper) then
       begin
         { automatic jumper angle differentiating }
        if (LentoAnim(kulma1) > 107) and (laskuri mod reflex = 0) then begin ch:=chr(hi(K[2])); ch2:=chr(lo(K[2])); end;
        if (LentoAnim(kulma1) < 107) and (laskuri mod reflex = 0) then begin ch:=chr(hi(K[3])); ch2:=chr(lo(K[3])); end;

        temp:=FindLanding(Makikulma(x));

        if (clanding=2) then temp:=round(temp*0.6); { ex (temp-temp div 4) }

{          WriteFont(280,50,'T'+txt(temp));
          WriteFont(280,60,'H'+txt(Height));
          WriteFont(280,70,'D'+txt(DeltaH[0] + DeltaH[1] + DeltaH[2])); }

{          WriteFont(280,70,'L'+txtp(hp));
          WriteFont(280,80,'T-H'+txt(temp-height));
          Writefont(250,90,'C'+txt(clanding)+' L'+txt(landing)); }

{           DrawScreen;
           ch:=readkey; }

         { kumpualastulovarmistus! }
        if (landing=0) and (matka>3) and (height<4) then begin { beep(2); } landing:=2; end;

        if (Landing=0) and (DeltaH[0] + DeltaH[1] + DeltaH[2] > 1) and (Height < temp) then
         begin

          if (clanding=2) then landing:=2;

          if (clanding=0) then { eka kertaa }
           if (random(250) < temp*(temp div 10)) then clanding:=2
                                                 else landing:=1;
         end;

       end; { if (cjumper) }

{       if (upcase(ch)='T') then Landing:=1;
       if (upcase(ch)='R') then Landing:=2; }
       if (kword(ch,ch2)=K[4]) then Landing:=1;
       if (kword(ch,ch2)=K[5]) then Landing:=2;

       if (kword(ch,ch2)=K[3]) and (kulma1<=600) then kulma1:=kulma1+round(kulma1/4);
       if (kword(ch,ch2)=K[2]) and (Landing=0) and (kulma1>0) then kulma1:=kulma1-round(kulma1/5);

{       if (ch='x') then pl:=0.1; }

        { ylirotaatio }
       if (kulma1<50) then begin pl:=pl+0.0001-((kulma1-50)/18000); {beep(1);} end;


{ orig. if (tuuli>0) then pl:=pl-((1-(kulma1/900))/1500)+(sqrt(sqrt(2*tuuli)))/52400
         else pl:=pl-((1-(kulma1/900))/1500)-(sqrt(sqrt(-2*tuuli)))/52400; }

      if (tuuli.value>0) then pl:=pl-((1-(kulma1/900))/1875)+(sqrt(sqrt(2*tuuli.value)))/65500
                   else pl:=pl-((1-(kulma1/900))/1875)-(sqrt(sqrt(-2*tuuli.value)))/65500;

{      px:=px-((kulma1/900)/19)+((sqrt(4*tuuli.value+245)-16)/360); } { "alkup." }
{      px:=px-((kulma1/900)/24)+((sqrt(4*tuuli.value+245)-16)/455); }
      px:=px-((kulma1/900)/20)+((nsqrt(4*tuuli.value+245)-16)/400);

      t:=t+0.01;

       { Satunnaispuuska }
       if (random(30000)<tuuli.windy+10+tuuli.voim) then
        begin

         laskuri:=0; { reflexi„ varten }

         if (random(2)=1) then tyylip[1]:=tyylip[1]-5;

         temp:=random(15);  { „ij„n kulman muutos... SŽŽDŽ TŽTŽ! }
         dec(temp,6);

         Kulma1:=kulma1+temp;

         if (temp>0) then
          begin { puuska tuo sukset yl”s }
           ssuunta:=3;
           pl:=pl-random(tuuli.voim+50)/15000;
          end;

         if (temp<0) then
          begin { puuska vie suksia alas }
           ssuunta:=6;
{           pl:=pl-random(tvoim+20)/6000+(tvoim/12000); } { vanha }
           pl:=pl+random(tuuli.voim+50)/15000;
          end;

        end;

      if (pl<0.105) then pl:=0.105; { leijuntaesto :) }

      kor:=kor+(t*t*pl)-((py-8)/100);

{       delay(600); }

     if (ssuunta>0) then  { SUKSIEN HEILUNTA - ponnistusfibat ja puuskat }
      begin

       case ssuunta of

       2 : begin { ponn my”h„ss„, k menossa alas }
            if (kulmas<0) then inc(kulmas,2); { 4, 3 }
            if (kulmas>0) then kulmas:=0;
           end;

       1 : begin { ponn my”h„ss„, k tulossa yl”s }

            if (kulmas=0) then
             begin { first strike }
              kulmas:=-51-(16-ponnistus)*6;
              if (kulmas<-105) then kulmas:=-105;

             end else dec(kulmas,4);

            if (kulmas < (ponnistus-16)*14) then ssuunta:=2;

           end;

       3 : begin { puuska, k saa iskua (ja tulee alas) }
            kulmas:=kulmas-random(50)-30;
            ssuunta:=2;
           end;


       5 : begin { ponn ajoissa, k tulossa yl”s }
            if (kulmas>0) then dec(kulmas,1);
            if (kulmas<0) then kulmas:=0;
           end;

       4 : begin { ponn ajoissa, k menee alas }

            if (kulmas=0) then
             begin { first strike }
              kulmas:=70+(ponnistus-16)*6;
              if (kulmas>130) then kulmas:=130; { ei nyt ihan „lyt”n }

             end else inc(kulmas,3);

            if (kulmas > (ponnistus-16)*14) then ssuunta:=5; { riitt„„ }

           end;

       6 : begin { puuska, k saa iskua (ja tulee yl”s) }
            kulmas:=kulmas+random(50)+30;
            ssuunta:=5;
           end;

       end; { case }

       if (kulmas=0) then ssuunta:=0;
      end;


      if (Landing>0) then  { alastulolis„ykset }
       if (kulma1<600) then
        begin
         kulma1:=kulma1+9+(landing-1)*5;

         if (pl<1) then pl:=pl+0.003;
        end;

      if (OK) then  { alkukulma... RUN ONCE (OK) }
       begin
        kulma1:=158; OK:=False;
        {  kulma1:=52; }

        if (ponnistus<16) then ssuunta:=1; { ponn liian my”h„„n - k„rjet yl”s}
        if (ponnistus>16) then ssuunta:=4; { ponn liian aikaisin - k„rjet alas }
        if (ponnistus=0) then ssuunta:=0; { ei sitten ponnistanut ollenkaan }
       end;

      JumperAnim:=LentoAnim(kulma1);

      if (Ponnphase<25) then JumperAnim:=PonnAnim(ponnphase);

      temp:=Height; { vanha korkeus }
      Height:=Profiili(x)-round(kor);

      if (Height<0) then Height:=0;

      DeltaH[laskuri mod 3]:=temp-Height;

      if (Height<6) { and (kulmas>-10) } and (matka>20) then
       begin  { j„nnitt„v„ m„en ennakointi! }
(*        ssuunta:=2; { suunta varmasti alas - lopettaa nollaan } *)
        if (kulmas=0) then ssuunta:=0; { meik„ m„„r„„ varmasti asennon }
        SkiAnim:=SuksiLaskussa(MakiKulma(x) div (Height+1));
       end
        else SkiAnim:=SuksiLennossa(kulmas);

      if (Height=0) then Out:=true; { the eagle has landed }

     End
    else

     begin  { matka < 0 }

       inc(laskuri);

        { mies ponnistaa jo... }
       If (Ponnistus>0) then inc(ponnistus);

        { start ponnistus! }
       If (kword(ch,ch2)=K[1]) and (matka>-40) and (ponnistus=0) then
        begin
         inc(Ponnistus);
         { SoundOn[1]:=StartSound(Sound[1],1,False);}
        end;

       { Automaattiponnistus }
        if (cjumper) and (matka>-(skill*px*0.01)) and (ponnistus=0) then inc(ponnistus);

      SkiAnim:=SuksiLaskussa(MakiKulma(x));

      JumperAnim:=LaskuAsento(SkiAnim);

      if (draw) and (laskuri<28) then
       begin
        JumperAnim:=165+Laskuri div 7;
        px:=37;
        if (laskuri<14) then px:=0;
       end;

      if (ponnistus>0) then JumperAnim:=PonnAnim(ponnphase);

         { Pudotetaan „ij„ }

      kor:=Profiili(x);

      px:=px*pxk;  { Hanaa... }

      if (px>maxspeed) then begin px:=maxspeed; {beep(2);} end;

      if (ponnistus>0) then
       begin
         { ponnistuslis„ys }
         px:=px+0.21;
         py:=py+1.21;
         { pl:=pl-(5*0.01); }
         kulma1:=kulma1+12;

        if (ponnistus>16) then { Ponnistus liian aikaisin }
         begin

          if (ponnistus=17) then
           begin
            pl:=pl+0.023;
            if (not cjumper) and (beeppi) then beep(1);
           end;

          pl:=pl+0.013;
          py:=py-1;
          

          if (kierros>0) then stats[statsvictim,osakilpailu].Reason[kierros]:=1;

          kulma1:=158;  { onko tarpeellinen?? }

         end;
       end;


     end;  { end matkariippuvaiset }

   x:=round(matka+qx);
   y:=round(kor);

 if (draw) then
  begin

   DeltaX:=Maki.X;
   DeltaY:=Maki.Y;

   if (x>=160) and (x<864) then inc(sx,x-fx);
   if (y>=100) and (y<412) then inc(sy,y-fy);

   Maki.X:=sx;
   Maki.Y:=sy;

   if (Maki.X>704) then Maki.X:=704;
   if (Maki.Y>312) then Maki.Y:=312;

   Maki.Tulosta;

   DrawLumi(DeltaX-Maki.X,DeltaY-Maki.Y,Tuuli.Value,LMaara,true);

   if (goals) and (goalx>0) then DrawAnim(goalx-Maki.X,goaly-Maki.Y,66); { tavoitekeppi }
   if (wrx>0) then DrawAnim(wrx-Maki.X,wry-Maki.Y,68); { m„kienkkakeppi }

   DrawAnim(x-Maki.X,y-Maki.Y-2,JumperAnim);
   DrawAnim(x-Maki.X,y-Maki.Y-1,SkiAnim);

   if (cjumper) then writefont(x-Maki.X,y-Maki.Y-20,'C');

{   PutPixel(KeulaX-Maki.X,Profiili(KeulaX)-Maki.Y,15); }

{   tempb:=SuksiAnim(x); }

{   Lumi.Update(Video,128,(DeltaX-Maki.X)*2,(DeltaY-Maki.Y)*2); }

{   Writefont(x-Maki.X+20,y-Maki.Y-20,txt(round(px))); }
{   Writefont(x-Maki.X,y-Maki.Y-25,txt(round(pl*100))); }
{   Writefont(x-Maki.X-20,y-Maki.Y-20,txt(round(py))); }

{    Writefont(x-maki.x,y-maki.y-25,txt(deltah[0]));
    Writefont(x-maki.x,y-maki.y-19,txt(deltah[1]));
    Writefont(x-maki.x,y-maki.y-13,txt(deltah[2])); }

{   Writefont(x-Maki.X-20,y-Maki.Y-20,txt(round(kulma1))); }

{   Writefont(x-Maki.X+20,y-Maki.Y-20,txt(round(kulmas)));
    Writefont(x-Maki.X,y-Maki.Y-20,txt(ssuunta)); }
{   Writefont(x-Maki.X,y-Maki.Y-20,txt(makikulma(x))); }
{   Writefont(x-Maki.X,y-Maki.Y-20,txtp(hp)); }

{   if (ponnistus>0) then
     begin
      Writefont(x-Maki.X,y-Maki.Y-40,txt(ponnistus));
      Writefont(x-Maki.X+30,y-Maki.Y-40,txt(kulmas));
     end;
}

    if (windplace>10) then Tuuli.Tuo(x-Maki.X,y-Maki.Y);

    Tuuli.Piirra;

{    if (ex) then balk(0); }

     RD[0,RTurns]:=byte(128+x-fx);
     RD[1,RTurns]:=byte(128+y-fy);
     RD[2,RTurns]:=JumperAnim;
     RD[3,RTurns]:=SkiAnim;
     RD[4,RTurns]:=byte(Tuuli.value+128);
     if (matka<0) then RFlstart:=Rturns else RFlstop:=Rturns;

     inc(RTurns);

{    if (ex) then balk(1); }

{   if (matka>0) then writefont(10,10,1,'!'); }

    DrawScreen;

{    if (matka<0) then delay(500); }

{  if (ponnistus>0) then ch:=readkey;

   if (ch=#13) then out:=true; }

{  if (matka>-5) then ch:=readkey; }

{  if (height<8) and (matka>=0) then ch:=readkey; }

  end; { if draw }

(*
   if (x>1015) then begin draw:=false; out:=true; end; { lent„„ ulos ruudusta u nou }
*)

  until (Out);   { ***  LENTO LOPPUU  *** }

   kkor:=kor-KeulaY;
   hp:=round(nsqrt((matka*matka)+(kkor*kkor))*acthill.pk*0.5)*5;

   if (ch=#27) then { painoi ESCi„ }
    begin
     hp:=0;
     score:=0;
     landing:=1;
     if (kierros >= 0) then
      begin
       CStats[kierros,pel]:=hp;
       stats[statsvictim,osakilpailu].RoundPts[kierros]:=score;
       stats[statsvictim,osakilpailu].RoundLen[kierros]:=hp;
      end
    end else
     begin
      inc(Profile[actprofile].totaljumps);

      grade:=0;
      if (kr<>0) then grade:=round(hp/kr)*10;

      temp:=MakiKulma(x);
      height:=round((temp*1.34) + (kulma1/10));

      riski:=jumprisk(temp);
       if (hp<20/3*kr) then riski:=1; { lyhyiden hyppyjen riski? }

      if (height<63) then riski:=round(riski*(1+((63-height)*0.075)));

{      laskuri:=round(2.5*sqr(sqr(sqr(sqr(sqr(((hp/10)/kr))))))+((hp/10)/kr*2)-1); }

{     riski:=10 * riski; }

      if (landing=0) or (height < 56) then
       begin
        if (kierros>0) then stats[statsvictim,osakilpailu].Reason[kierros]:=2;
        kupat:=2;
        if (landing=0) then kupat:=1;
       end;

      if (landing=1) then { telemark-juttuja }
       begin
        inc(riski,2*riski);
{        inc(laskuri,3*laskuri); }

        if (height<60) then dec(tyylip[1],5);
        if (height<64) then dec(tyylip[1],5);
       end;


{      writefont(270,10,txt(round(makikulma(x)))); }

{     writefont(270,20,txt(round(kulma1/10)));
      writefont(270,30,txt(round((makikulma(x)*1.34) + (kulma1/10)))); }

{      writefont(260,40,'K'+txt(round(temp)));
      writefont(260,20,'OLD-R'+txtp(laskuri)); }
{       writefont(260,30,'NEW-R'+txtp(riski)); }

{      writefont(270,30,'L'+txt(kulmalaskuri)); }
{      writefont(260,40,'H'+txt(height)); }

{      drawscreen;
       readkey; }

      if (random(1000)<riski) then { liian longa hyppy tai vaan kehno sk„g„ }
       begin
        if (kierros>0) then stats[statsvictim,osakilpailu].Reason[kierros]:=3;
        kupat:=3;
       end;

      for temp:=1 to round((kr+(kr/20)-(hp/10))/6) do
       tyylip[1]:=tyylip[1]-5;

      if (kupat>0) then tyylip[1]:=tyylip[1]-100
       else
        if (landing=2) then dec(tyylip[1],15+random(2)*5); { tasajalka tuomarirokotus }

      for temp:=2 to 5 do
       begin
        temp2:=random(4);
        tyylip[temp]:=tyylip[1];
        tyylip[temp]:=tyylip[temp]-(temp2-1)*5; { ennen temp2-2 }
       end;

      for temp:=1 to 5 do
       begin
        if (tyylip[temp]>200) then tyylip[temp]:=200;
        if (tyylip[temp]<0) then tyylip[temp]:=0;
        if (tyylip[temp]>tyylip[7]) then tyylip[7]:=tyylip[temp];
        if (tyylip[temp]<tyylip[6]) then tyylip[6]:=tyylip[temp];
       end;

      if (kupat>0) then inj[pel]:=injured; { LOUKKAANTUMINEN!!! }

{    if (kupat=1) then inj[pel]:=1;
    if (kupat=2) then inj[pel]:=3;
     if (kupat=3) then inj[pel]:=6; }

      score:=0;

{   splitscreen(60);
   waitraster; }

{if (ch<>#27) then}

      for temp:=1 to 5 do inc(score,tyylip[temp]);

      dec(score,tyylip[6]);  { pienin ja suurin pois }
      dec(score,tyylip[7]);

      if (kr<>0) then { vanha tyyli }
       inc(score,round(((hp/10)-(kr*2/3))*(180/kr)*10));  { pituuspisteet }

(*
      if (kr<>0) then { uusi fis:in mukainen }
       inc(score,round((hp-(kr*10))*(lengthpoint(kr)/10)+600));  { pituuspisteet }

      if (kr>=160) then inc(score,600); { lentom„ist„ saa isot pisteet }
*)

      if (score>paras) then { harjoituskamaa }
       begin
        paras:=score;
       end;

      if (kierros=-10) then pisteet[NumPl+1]:=score;

      if (not jcup) and (kierros>=0) then
       begin
        inc(pisteet[pel],score); { Oma pelaajan pisteet }
        CStats[kierros,pel]:=hp;

(*        if (ex) then Cstats[kierros,pel]:=height*10+landing; *)

(*        Cstats[kierros,pel]:=ponnistus*10; { yl”svaan } *)
       end;

      if (jcup) then inc(pisteet[team],score);

      if (kierros>=0) then
       begin
        stats[statsvictim,osakilpailu].RoundPts[kierros]:=score;
        stats[statsvictim,osakilpailu].RoundLen[kierros]:=hp;
       end;

      for temp:=1 to 5 do inc(tyylip[temp],10000);

      hillrecord:=false;

      if (wcup) and (cupstyle=0) and (hp > Profile[actprofile].bestwcjump) then
       begin      { vain real world cup }
        Profile[actprofile].bestwcjump := hp;
        Profile[actprofile].bestwchill := nytmaki;
       end;

      if (hp > Profile[actprofile].bestjump) then
       begin
        Profile[actprofile].bestjump := hp;
        Profile[actprofile].besthill := nytmaki;
        Profile[actprofile].besthillfile:='HILLBASE';
        if (nytmaki>NumWCHills) then
         Profile[actprofile].besthillfile:=hillfile(nytmaki-NumWCHills);
       end;

      if (not koth) and (kupat=0) and (not treeni) and (hp > HRLen(nytmaki)) then
       hillrecord:=true;

      if (cjumper) and (not comphrs) then hillrecord:=false; { ei saa }

      if (hillrecord) then
       begin
        {
        dwritefont(200,24,'NEW HILLRECORD!!!');
        dwritefont(200,32,'NEW: '+txtp(hp)+'«');
        writefont(270,32,7,'('+txtp(MEPituus[nytmaki])+'«)'); }

        if (cjumper) then namestr:=namestr+'ÿ';

        SetHRinfo(nytmaki,namestr,hp,dayandtime(Today,Now));

{        HR[nytmaki].len:=hp; }
{        HR[nytmaki].name:=namestr; }
{        HR[nytmaki].time:=dayandtime(Today,Now); }

        if (kierros>0) then stats[statsvictim,osakilpailu].Reason[kierros]:=5;

        ThisIsAHillRecord:=(kierros*1000)+pel;

       end;
{
      fillbox(100,100,300,180,1);
      writefont(110,110,1,'PONN '+txt(ponnistus));
      writefont(110,120,1,'HP '+txtp(hp));
      Maki.Paivitaruutu;
      putsaa;
      ch:=readkey;       }

      laskuri:=0;
      startanim:=100; { start "nousepa yl”s"-kuvio }

      OK:=boolean(random(2)); { if OK then sukset j„„ kiinni }

      if (landing=2) then dec(startanim,50);

      umatka:=matka; { ukon koordinaatit, jos sukset l„htee alta... }
      ukor:=kor;
      upx:=px;

    {  if (gdetail=0) or (not cjumper) then} FontColor(247);

      Out:=False;

{     kupat:=3; }

      if (kupat>0) then grade:=kupat;

     if (draw) then
      repeat                 { ***  LASKU  *** }

       Tuuli.Hae;

       inc(laskuri);

       matka:=matka+(px*0.008);
       umatka:=umatka+(upx*0.008);

       if (OK) then matka:=umatka;

       fx:=x;
       fy:=y;

       x:=round(matka+qx);
       ux:=round(umatka+qx);

       kor:=Profiili(x);
       ukor:=Profiili(ux);

      { if (x<1010) then}

       SkiAnim:=SuksiLaskussa(MakiKulma(x));

       JumperAnim:=LaskuAnim(SkiAnim, landing); { t„t„ voi my”s sitten muuttaa jos haluaa }

       if (laskuri<7) and (landing>0) then JumperAnim:=113+landing; { esilaskeutuminen }

       if (kupat>0) then
        begin

         if (laskuri>50) and (upx>0) then upx:=upx-0.8;
         if (upx<0) then
          begin
           upx:=0;
           if (OK) then Out:=True;
          end;

         case kupat of
         1,2 : begin { ei alastuloa, „ij„ suoraan turvalleen }

                temp:=2-(kulma1 div 80);
                if (temp<0) then temp:=0;

                tempb:=142+laskuri div 10+temp;

                if (kupat=2) then tempb:=142+(laskuri-6) div 10+temp;

                if (tempb>145) then
                 begin
                  tempb:=144;
                  case (SuksiLaskussa(MakiKulma(ux))-71) of
                    4   : tempb:=145;
                    5   : tempb:=146;
                    6   : tempb:=147;
                  7..12 : tempb:=148;
                  end; { case }
                 end;

                if not ((kupat=2) and (laskuri<6)) then JumperAnim:=tempb;

               end;

         3 : if (laskuri>14) then { liian pitk„ - esilaskeut. & v„h„n norm. laskua }
              begin

               tempb:=151+(laskuri-14) div 10;

               if (tempb>155) then
                begin
                 tempb:=163;
                 case (SuksiLaskussa(Makikulma(ux))-71) of
                  3..4  : tempb:=162;
                  5..6  : tempb:=161;
                  7..12 : tempb:=160;
                 end; { case }
                end else if (landing=2) then inc(tempb,5);

                JumperAnim:=tempb;
               end;

         end; { case }

        end else
         begin { ei kaatuna }

          if (laskuri>startanim) then
           begin
            temp:=(laskuri-startanim) div 12;
            if (temp>6) then temp:=6;

            case temp of
            0 : tempb:=122+(landing*6);
            1 : tempb:=123+(landing*6);
            2 : tempb:=136;
            3..6 : begin
                    tempb:=136; { peruslasku }
                    case grade of
                    0..75  : begin       { h„pe„ v„h„n }
                              tempb:=137;
                              { if (temp>4) and (grade<50) then tempb:=138; }
                             end;

                    105..200 : begin       { yeah! }
                                tempb:=139;
                                if (temp>3) then
                                 if (grade>114) then tempb:=141 else tempb:=140;

{                                if (temp>4) and (grade>114) then tempb:=141; }
                               end;

                   end; { case grade }

                  end;
            end; { case }

            JumperAnim:=tempb;

           end;

         end;

        Ch:=#0;

        if (SDLPort.KeyPressed) then
         begin
          SDLPort.WaitForKeyPress(ch,ch2);
          ch:=upcase(ch);
         end;
        if (ch=#0) and (Ch2=#68) then begin cupslut:=true; ch:=#27; end;
        if (Ch=#27) or (Ch=#13) then Out:=True;
        if (Ch='P') then SDLPort.WaitForKeyPress(ch,ch2);

        DeltaX:=Maki.X;
        DeltaY:=Maki.Y;

        x:=round(matka+qx);
        y:=round(kor);

        if (x>=160) and (x<864) then inc(sx,x-fx);
        if (y>=100) and (y<412) then inc(sy,y-fy);

        Maki.X:=sx;
        Maki.Y:=sy;

        if (Maki.X>704) then Maki.X:=704;
        if (Maki.Y>312) then Maki.Y:=312;

        Maki.Tulosta;

{       PutPixel(KeulaX-Maki.X,Profiili(KeulaX)-Maki.Y,15); }
{       tempb:=SuksiAnim(x); }
{       Writefont(x-maki.x,y-maki.y-15,txt(SkiAnim-71)); }
{       Writefont(x-Maki.X,y-Maki.Y-20,txt(makikulma(x))); }
{       Writefont(x-Maki.X+15,y-Maki.Y-15,txt(kulma1)); }
{       DrawAnim(x-Maki.X,y-Maki.Y-2,JumperAnim); }

{   Writefont(10,192,'LJA: '+txt(JumperAnim));
   Writefont(60,192,'LSA: '+txt(SkiAnim)); }

{   if (JumperAnim>NumofAnims) or (SkiAnim>NumofAnims) or
      (JumperAnim<1) or (SkiAnim<1) then
    begin
     beep(1);
     writefont(100,80,'LASKU!');
     writefont(100,100,'JAnim: '+txt(JumperAnim));
     writefont(100,120,'SAnim: '+txt(SkiAnim));
     maki.paivitaruutu;
     ch2:=readkey;
    end;
}
        DrawLumi(DeltaX-Maki.X,DeltaY-Maki.Y,Tuuli.Value,LMaara,true);

        if (goals) and (goalx>0) then DrawAnim(goalx-Maki.X,goaly-Maki.Y,66); { tavoitekeppi }
        if (wrx>0) then DrawAnim(wrx-Maki.X,wry-Maki.Y,68); { m„kienkkakeppi }

        DrawAnim(ux-Maki.X,round(ukor)-Maki.Y-2,JumperAnim);
        DrawAnim(x-Maki.X,y-Maki.Y-1,SkiAnim);

{       Lumi.Update(Video,128,(DeltaX-Maki.X)*2,(DeltaY-Maki.Y)*2); }

(*      drawanim(297,5,59);  { sapluuna } *)
{       drawanim(300,60,59); }

{       drawanim(298,9,59); }

        if (cjumper) then writefont(x-Maki.X,y-Maki.Y-20,'C');

        if (x>1050) then Out:=True;

        DrawAnim(227,2,64); { hillrec sapluun }

        ewritefont(308,9,namestr);

{       temp2:=311; }
        temp2:=308;
{       if (kierros=2) then temp2:=280; }

        ewritefont(temp2,33,txtp(hp)+'«');

        if (hillrecord) and (not Out) then
         begin
          if (laskuri mod 30 < 15) then writefont(260,33,'HR!');
{         writefont(279+random(3),71+random(3),txtp(hp)+'«'); }

          if (random(2)=0) then ewritefont(temp2-1+random(3),32+random(3),txtp(hp)+'«');

{         writefont(280,72,txtp(hp)+'«'); }
         end;

        { tyylipisteet ruutuun }

        temp:=random(5)+1;
         if (random(20)=1) and (tyylip[temp]>9999) then dec(tyylip[temp],10000);

        for temp:=1 to 5 do
         if (tyylip[temp]<9999) then
          ewritefont(308-(temp-1)*24,21,txtp(tyylip[temp]));
  {       ewritefont(304,25+(temp-1)*11,txtp(tyylip[temp])); }

{       ewritefont(304,8,namestr); }

{        if (ex) then balk(0); }

         RD[0,RTurns]:=byte(128+x-fx);
         RD[1,RTurns]:=byte(128+y-fy);
         RD[2,RTurns]:=JumperAnim;
         RD[3,RTurns]:=SkiAnim;
         RD[4,RTurns]:=byte(Tuuli.value+128);

         inc(RTurns);

{        if (ex) then balk(1); }

        DrawScreen;

{       delay(500); }

       until (Out);  { LASKU LOPPUU }

{  StopSound(5);
  StopSound(4); }

       fx:=0; { k„ytet„„n effektiivisten tyylipisteiden l”yt„miseen :) }
       fy:=0;

       for temp:=1 to 5 do     { tyylipisteet n„ytt””n ja poisj„„v„t tummaksi }
        begin

         if (tyylip[temp]>9999) then dec(tyylip[temp],10000);

         if (draw) and ((gdetail=0) or (not cjumper)) then fontcolor(247);

         if (tyylip[temp]=tyylip[6]) and (fx=0) then
          begin if (draw) and ((gdetail=0) or (not cjumper)) then fontcolor(252); inc(fx); end;

         if (tyylip[temp]=tyylip[7]) and (fy=0) then
          begin if (draw) and ((gdetail=0) or (not cjumper)) then fontcolor(252); inc(fy); end;

{        ewritefont(304,25+(temp-1)*11,txtp(tyylip[temp])); }
         if (draw) then ewritefont(308-(temp-1)*24,21,txtp(tyylip[temp]));

        end;

       if (jcup) then
        begin
         if (draw) and ((gdetail=0) or (not cjumper)) then FontColor(241);

         if (draw) then EWritefont(302,14,jnimet[team]);
{        EWritefont(302-FontLen(namestr),9,jnimet[16-pel]); }
        end;

       if (draw) and ((gdetail=0) or (not cjumper)) then FontColor(240);

       if (draw) then EWriteFont(308,9,namestr)
                 else
                  begin
                   EWriteFont(296,9,lstr(57));
                   EWriteFont(308,9,txt(index)); { computers jumping... }
                  end;

{
       WriteFont(160,9,'P'+txt(ponnistus));
       WriteFont(160,21,'R'+txtp(riski));
       Writefont(160,45,'RL'+txt(reflexlaskuri div 5)); }

       if (draw) and ((gdetail=0) or (not cjumper)) then FontColor(247);

{       drawscreen;
       readkey; }

       fx:=0; { seuraavassa: osallistujat }
       fy:=0; { - " - : sijoitus }

       temp2:=0;

       if (not koth) and (kierros>=0) then  { komea "monesko olen nyt?"-laskuri! }
        begin

         fx:=NumPl;
         if (jcup) then fx:=NumTeams;

         for temp:=1 to fx do
          begin
           if (jcup) then temp2:=pisteet[team] { omat pisteet }
                     else temp2:=pisteet[pel];

           if (temp2 >= pisteet[temp]) then inc(fy);
          end;

         if (draw) then ewritefont(255,45,'($'+txt(fx-fy+1)+'.)');

        end;

       fx:=308;

       if (draw) and (hillrecord) then
        begin
         writefont(260,33,'HR!');
         fontcolor(246);
        end;

       if (draw) then ewritefont(fx,33,txtp(hp)+'«');

       if (draw) and ((gdetail=0) or (not cjumper)) then fontcolor(246);

       temp2:=score;

       if (jcup) then temp2:=pisteet[team];
       if (wcup) or (koth) then temp2:=pisteet[pel];

       if (wcup) and (kierros<0) then temp2:=score;

       if (draw) then
        begin
         ewritefont(308,45,txtp(temp2)); { score }
         if (gdetail=0) or (not cjumper) then fontcolor(241);

         if (draw) and (kierros=2) and (wcup) then
          begin
           ewritefont(255,33,txtp(CStats[1,pel])+'«');
           ewritefont(311,55,'('+txtp(score)+')');
          end;

         if (jcup) and (index*kierros>1) then
          begin
           ewritefont(311,55,'('+txtp(score)+')');
          end;

         if (inj[pel]>0) and (wcup) then
          begin
           fontcolor(239);
{        str1:='LEGS.';
         if (inj[pel]=1) then str1:='LEG.';
         writefont(12,176,'WILL MISS NEXT '+txt(inj[pel])+str1); }

           str1:=txt(inj[pel])+' '+lstr(76);

           case inj[pel] of
           1 : str1:=lstr(77);
           2 : str1:=lstr(78);
           end;

         { ewritefont(212,33,'INJ-'+txt(inj[pel]-1)); }
           ewritefont(311,64,lstr(75)+' '+str1);

          end;
         end;

       if (not draw) and (gdetail=0) then
        begin
{         tuuli.value:=tuulisafe; }
         DrawLumi(DeltaX-Maki.X,DeltaY-Maki.Y,tuuli.value,LMaara,false); { pakko piirt„„ }
        end;

       if (draw) and (not cjumper) and (grade>0) and
          (Profile[actprofile].cstyle>0) then DoCoachCorner(height,kulmalaskuri,grade,ponnistus,Profile[actprofile].cstyle);

{      if (landing=2) then writefont(160,45,'TASA');
       WriteFont(160,33,'K'+txt(height)); }

       dec(RTurns); { niit„ on yksi liikaa }

{       Writefont(100,100,'T'+txt(RTurns)); }
{$IFDEF REG}
       if (not cjumper) and (draw) then EWritefont(308,73,lstr(298));
{$ENDIF}

       DrawScreen;

{       delay(100); }

      if (draw) then
       begin
        Putsaa;
        cupslut:=WaitForKey2;

       end
        else
         if (SDLPort.KeyPressed) then
          begin
           SDLPort.WaitForKeyPress(ch,ch2);
           if (ch=#0) and (ch2=#68) then cupslut:=true;
          end;
      end;

{  if (ch=#68) then begin cupslut:=true; ch:=#27; end; }

  Maki.Lopeta;

{  AsetaMoodi($3); }

 { KIRJOITA REPLAY! }

{$IFDEF REG}
  if (draw) and (not cjumper) then
   begin
    str1:=profile[actprofile].realname;
    if (str1='') then str1:=profile[actprofile].name;

    if (upcase(ch)=lch(298,2)) then
     begin
      temp:=replayinfo(replayfilename, str1, replayname, nytmaki, hp);
      if (temp=0) then temp:=writereplay(str1, replayname);
      resultbox(1,temp);
     end;

    if (hillrecord) and (automatichrr) then
     begin
      replayfilename:='HR-'+copy(acthill.name,1,3);
      replayname:='HILL RECORD AT '+acthill.name+' K'+txt(acthill.kr);
      writereplay(str1,replayname);
     end;
   end;
{$ENDIF}

{ if (ex) then
  begin

   fontcolor(240);
   writefont(60,10,'Normaali lopetus');

   writefont(60,20,'KeulaX: '+txt(keulaX));
   writefont(60,30,'KeulaY: '+txt(profiili(keulaX)));
   writefont(60,40,'Ponn: '+txt(ponnistus));

   drawscreen;
   readkey;

  end;
}

end;







procedure showstats;
var count : longint;
    temp, yy, xx, kierros : integer;
    player, team, cup : integer;
    str1 : string;
    col : array[0..20] of integer;

 procedure WS(cln,clr:byte;str2:string);
  var color : byte;
  begin
   if (clr=0) then
    begin
     color:=240+(cln mod 2)*6;
(*     case cln of
     1,3,5 : color:=246;
     0,2,4,6,8,10 : color:=240;
     7,11 : color:=247;
     9,12 : color:=249;
     end; { case } *)
    end else color:=clr;

   FontColor(color);
   if (cln=1) then Writefont(col[cln],yy,str2)
              else EWritefont(col[cln],yy,str2);

  end;


begin

if (jcup) then

 for team:=0 to jmaara-1 do
  begin

   NewScreen(1,5);

   FontColor(240);
   writefont(30,6,lstr(93)+' '+jnimet[15-team]);

   count:=0;

   col[0]:=11;
   col[1]:=12;
   col[2]:=62;
   col[3]:=90;
   col[4]:=103;

   xx:=0;

   for temp:=1 to 3 do
    begin
     inc(xx,70);
     col[(temp*3)+2]:=col[2]+xx;
     col[(temp*3)+3]:=col[3]+xx;
     col[(temp*3)+4]:=col[4]+xx;
    end;

   yy:=23;

   fontcolor(241);

   Writefont(col[1],yy,lstr(106));

   for temp:=0 to 3 do
    begin
     ewritefont(col[2+temp*3],yy,lstr(108));
     ewritefont(col[3+temp*3],yy,lstr(109));
     ewritefont(col[4+temp*3],yy,'?');
    end;

   fontcolor(247);
   inc(yy,7);

   for temp:=1 to 4 do
    begin
     writefont(col[2+(temp-1)*3]-15,yy,nsh(nimet[NumPl+1-(team*4)-temp],64));
    end;

   inc(yy,7);

  for cup:=1 to osakilpailu do
   begin
    WS(0,240,txt(cup)+'.');

    temp:=HillOrder[cup];

    WS(1,246,copy(hillname(temp),1,3)+' '+txt(hillkr(temp)));

     for player:=1 to 4 do { b on player, a on cup, d on team }
      begin
{       if Stats[b+d*4,a].RoundLen[1]=1 then textcolor(15) else textcolor(11); }
       temp:=player+(team*4);
       xx:=(player-1)*3;

       yy:=(cup-1)*21+37;

       for kierros:=1 to 2 do
        begin
         WS(2+xx,246,txt(Stats[temp,cup].RoundLen[kierros])+'.');
         WS(3+xx,240,txtp(Stats[temp,cup].RoundPts[kierros]));
         WS(4+xx,247,makeletter(Stats[temp,cup].Reason[kierros]));
         inc(yy,7);
        end;

      end;

      if (Stats[team,cup].CompPos<9) then inc(count,TeamPoints[Stats[team,cup].CompPos]);
{      if Stats[b+d*4,a].CompPos=1 then textcolor(15) else textcolor(14); }

      fontcolor(247);
      writefont(col[1],yy,lstr(107));
      ewritefont(82,yy,lstr(108));
      fontcolor(246);
      ewritefont(100,yy,txt(Stats[team,cup].CompPos)+'.');

      fontcolor(247);
      ewritefont(122,yy,lstr(110));
{      if Stats[d,a].WCPos=1 then textcolor(31) else textcolor(15); }
      str1:='- ';
      if (count>0) then str1:=txt(Stats[team,cup].WCPos)+'.';

      fontcolor(246);
      ewritefont(140,yy,str1);

      fontcolor(247);
      ewritefont(162,yy,lstr(109));
      fontcolor(246);
      ewritefont(186,yy,txt(count));

      inc(yy,7);

   end;

  DrawScreen;
  cupslut:=Waitforkey2;

 end else

 begin

  player:=1;

  str1:=lstr(89);

  ResetList(pmaara,NumPl,7,str1,InvBack);

 repeat

  FontColor(240);

  writefont(36+fontlen(lstr(89)),6,nsh(nimet[NumPl+1-player],110));

  count:=0;

  col[0]:=15;
  col[1]:=16;
  col[2]:=70;
  col[3]:=90;
  col[4]:=110;
  col[5]:=140;

  col[6]:=170; { R1 }
  col[7]:=210; { m }
  col[8]:=230; { pos after R1 }
  col[9]:=240;
 col[10]:=268; { R2 }
 col[11]:=308; { m }
 col[12]:=316;

  yy:=23;

  fontcolor(247);

{  EWritefont(col[0],yy,'#'); }
  Writefont(col[1],yy,lstr(106));
  EWritefont(col[2],yy,lstr(108));
  EWritefont(col[3],yy,lstr(109));
  EWritefont(col[4],yy,lstr(98));
  EWritefont(col[5],yy,lstr(97));
  EWritefont(col[6],yy,'R 1');
  EWritefont(col[8],yy,lstr(108));
  EWritefont(col[9],yy,'?');
  EWritefont(col[10],yy,'R 2');
  EWritefont(col[12],yy,'?');

  FontColor(246);

  yy:=25;

  for cup:=1 to osakilpailu do
   begin
    inc(yy,7);

    WS(0,0,txt(cup)+'.');

    WS(1,0,copy(hillname(cup),1,3)+' '+txt(hillkr(cup)));

    str1:='dq'; { didn't qualify }

    temp:=Stats[player,cup].CompPos;

    if (temp>0) and (temp<51) then str1:=txt(temp)+'.';

    WS(2,0,str1);  { Kisa Pos }

    str1:='0';

    if (temp>0) and (temp<31) then
     begin
      str1:=txt(WCpoints[temp]);
      inc(count,WCpoints[temp]);
     end;

    WS(3,0,str1);   { Kisasta pisteit„ }

    str1:='-';
    if (count>0) then str1:=txt(Stats[player,cup].WCPos)+'.';

    WS(4,0,str1);   { WC sija t„n skaban j„lkeen }

    if (temp>0) and (temp<51) then
     begin
      WS(5,0,txtp(Stats[player,cup].RoundPts[1]+Stats[player,cup].RoundPts[2]));

      WS(6,0,txtp(Stats[player,cup].RoundPts[1]));

      str1:='('+txtp(Stats[player,cup].RoundLen[1])+'«)';
      WS(7,247,str1);

      WS(8,0,txt(Stats[player,cup].Round1Pos)+'.');

     end;

     temp:=Stats[player,cup].RoundPts[2];

     if (temp>0) then
      begin
       WS(10,0,txtp(temp));
       WS(11,247,'('+txtp(Stats[player,cup].RoundLen[2])+'«)');
      end;


     temp:=Stats[player,cup].Reason[1];
     if (temp>0) then WS(9,247,makeletter(temp));

     temp:=Stats[player,cup].Reason[2];
      if (temp>0) then WS(12,247,makeletter(temp));

      if (cup=12) and (osakilpailu<>12) then
       begin
        inc(yy,7);

        if (not InvBack) then
         begin
          fillbox(0,yy,319,yy+6,245);
          fillarea(0,yy,319,yy+6,63);
         end;

        fontcolor(240);
        writefont(col[1],yy,lstr(99));

        Ewritefont(col[2],yy,txt(Stats[player,0].CompPos)+'.');

        Ewritefont(col[5],yy,txtp(Stats[player,0].RoundPts[1]));
       end;

    end;


  inc(yy,8);
{  fillline(15,'-'); }

  fillbox(2,yy,316,yy,241);
  fillbox(3,yy+1,317,yy+1,242);

  inc(yy,3);

  WS(1,0,lstr(100));

{  if (Stats[d,a].WCPos=1) then textcolor(31) else textcolor(15); }
  WS(3,0,txt(count));

 if (count>0) then WS(4,0,txt(Stats[player,cup].WCPos)+'.');

 count:=0;
 for cup:=1 to osakilpailu do
  inc(count,Stats[player,cup].RoundPts[1]+Stats[player,cup].RoundPts[2]);
  FontColor(251);
  EWritefont(col[5],yy,txtp(count div osakilpailu));

 count:=0;
 for cup:=1 to osakilpailu do
  inc(count,Stats[player,cup].RoundPts[1]);
  FontColor(241);
  EWriteFont(col[6],yy,txtp(count div osakilpailu));

 count:=0;
 for cup:=1 to osakilpailu do
  inc(count,Stats[player,cup].RoundPts[2]);
  EWritefont(col[10],yy,txtp(count div osakilpailu));

{  writefont(300,180,txt(player));
    drawscreen; delay(1000); }

  str1:='X';

  if (player=pmaara) then str1:='L';
   player:=Entry(player,0,0,'',0,0,0,str1);

  if (player=-2) then cupslut:=true;

{  writefont(300,180,txt(player));
   drawscreen; delay(1000); }

 until (player<0) or (player>pmaara);

{  DrawScreen;

  CupSlut:=waitforkey2(ch); }

 end;


end;




procedure dokothrecords(high:byte);
var temp,yy : integer;
    col : array[1..4] of integer;
    str1 : string;
begin

 col[1]:=30;
 col[2]:=55;
 col[3]:=175;
 col[4]:=290;

 fontcolor(240);
 writefont(30,6,lstr(160));

{ fontcolor(251);
 writefont(col[1]+12,23,'CHALLENGE'); }

{
 fontcolor(241);
 writefont(col[2],30,'WHO?');
 writefont(col[3],30,'WHEN?');
 writefont(col[4]-40,30,'HOW MANY TIMES?'); }

 yy:=12;

 for temp:=1 to 6 do
  begin

   inc(yy,18);

   fontcolor(246);

   writefont(col[1],yy,kothtitle(temp));

   inc(yy,10);

   fontcolor(241);
   str1:=lstr(161);

   if (top[temp+35].score>0) then
    begin

     writefont(col[3],yy,top[temp+35].time);

     if (high=0) or (high=temp) then fontcolor(240);
     str1:=top[temp+35].name;
     writefont(col[4],yy,txt(top[temp+35].score)+' X'); { times completed }

    end;

     writefont(col[2],yy,str1);

  end;

 DrawScreen;

end;



procedure dolist(high,phase:byte);  { h0 = main menusta,muuten kertoo mik„ highlightataan }
var temp,yy : integer;
    entries, start, sortby : byte;
    str1 : string;
    col : array[0..5] of integer;

    Hi : Hiscore;
    NumCustoms : integer;
    Files : array [0..MaxCustoms] of FileStr;

begin

   yy:=6;

   col[0]:=30;
   col[1]:=146;
   col[2]:=173;
   col[3]:=215;

   fontcolor(240);
   sortby:=0; { 0-WC, 1 - Total points }

   case phase of
    0 : begin
         str1:=lstr(163);
         entries:=20; start:=1;
        end;
    1 : begin
         str1:=lstr(164);
         entries:=10; start:=21;
        end;
    2 : begin
         str1:=lstr(165);
         entries:=5; start:=31;
         if (high=0) then yy:=126;
         sortby:=1;
        end;
   else
    begin

     FindCustoms(NumCustoms, Files);
     str1:=lstr(162);
     start:=(phase-3)*20;
     entries:=NumCustoms-start;
     if (entries>20) then entries:=20;
     col[0]:=50;
     col[1]:=157;
     col[2]:=184;

    end;

   end; {case}

   writefont(30,yy,str1);

   inc(yy,17);

   fontcolor(246);

   if (phase>2) then
    begin
     writefont(5,yy,lstr(173)); { file }
     writefont(col[0],yy,lstr(171)); { name -> who? }
     ewritefont(col[1]+10,yy,lstr(167));
     writefont(col[2]+9,yy,lstr(109)); { points -> pts }
    end
     else
      begin { muutoin normaalisti }
       writefont(col[0],yy,lstr(166));
       writefont(col[1],yy,lstr(167));
       writefont(col[2],yy,lstr(168));
      end;

   writefont(col[3],yy,lstr(169));

    for temp:=start to start+entries-1 do
     begin

      inc(yy,8);

      hi:=top[temp];

      if (phase>2) then
       begin
        loadcustom(files[temp-start+1],sortby,hillorder,cuphills);
        hi:=top[42];
       end;

      if (high=0) then
       begin
        fontcolor(246);
        if (phase<3) then ewritefont(24,yy,txt(temp-start+1)+'. ');

        fontcolor(240);
        if (hi.name[length(hi.name)]='ÿ') then fontcolor(247);
       end else
        begin
         fontcolor(241);
         if (temp-start+1=high) then fontcolor(240);
         ewritefont(24,yy,txt(temp-start+1)+'. ');
        end;

      writefont(col[0],yy,nsh(hi.name,110));
      ewritefont(col[1]+14,yy,txt(hi.pos)+'.');

      str1:=txt(hi.score);
      if (sortby=1) then str1:=txtp(hi.score);
      ewritefont(col[2]+24,yy,str1);

      fontcolor(241);
      writefont(col[3],yy,hi.time);
      if (phase>2) then writefont(5,yy,files[temp-start+1]);

     end;

   DrawScreen;

end;


procedure dohillrec(phase:byte);
 { phase: 0 - normals, 1...  - extras }
var aa,yy : integer;
    start, loop, apu1 : integer;
    str1 : string;
    col : array [0..5] of integer;
    ahi, laskuri : longint;

 begin

   col[0]:=3;
   col[1]:=71;
   col[2]:=183;
   col[3]:=200;
   col[4]:=216;

   start:=phase*20;

   fontcolor(240);

   str1:=lstr(156);

   ahi:=0;

   if (phase=0) then str1:=lstr(170);

   loop:=NumWCHills+NumExtraHills - start;
   if (loop>20) then loop:=20;

   writefont(30,6,str1);

   writefont(col[0],23,lstr(106));
   writefont(col[1],23,lstr(171));
   ewritefont(col[2],23,lstr(172));
   writefont(col[3],23,'(K)');
   writefont(col[4],23,lstr(169));

    for aa:=1 to Loop do
     begin
      yy:=(aa-1)*8+32;

      fontcolor(246);
      writefont(col[0],yy,nsh(hillname(aa+start),64));

      fontcolor(240);
      str1:=HRname(aa+start);

      apu1:=HRLen(aa+start);

      if (str1[length(str1)]='ÿ') then
       begin
        fontcolor(247);
        apu1:=hillkr(aa+start)*10;
       end;

      inc(ahi,longint(apu1));

      writefont(col[1],yy,nsh(str1,80));
      if (str1[length(str1)]<>'ÿ') then fontcolor(246);
      ewritefont(col[2],yy,txtp(HRlen(aa+start)));
      ewritefont(col[3]+11,yy,'('+txt(hillkr(aa+start))+')');

      fontcolor(241);

      writefont(col[4],yy,HRtime(aa+start));

     end;

 if (phase=0) then
  begin
   laskuri:=0;
    for apu1:=1 to NumWChills do inc(laskuri,longint(hillkr(apu1)*10));

   ahi:=round((ahi/laskuri)*10000);
   str1:=txt(ahi);
   insert('.',str1,length(str1)-1);
   str1:=str1+' %';

   writefont(130,192,'A.H.I.');
   ewritefont(197,192,str1);
  end;

  DrawScreen;

{  Waitforkey2(ch); }

end;



procedure showtops(phase:byte);
 { phase: 0 - hiscores, 1 - hillrecs+extras, 2 - just hillrecs }
var index, num, numcustoms : integer;
    str1 : string;
    good, leave : boolean;
{    tempch, tempch2 : char; }
    filenames : array [0..maxcustoms] of Filestr;


begin

  index:=1;
  num:=4;

  if (phase=0) then FindCustoms(NumCustoms,Filenames);

  case phase of
  0 : if (numcustoms>0) then num:=(NumCustoms-1) div 20+4
                        else num:=3;
  1 : { num:=2; }
      num:=(NumExtraHills-1) div 20+2;
  2 : num:=1;
  end;


 repeat

 case phase of
 0 : case index of
      1 : begin
           NewScreen(1,0);
           dolist(0,0);
           end;
      2 : begin
           NewScreen(4,0);
           dolist(0,1);
           dolist(0,2);
          end;
      3 : begin
           NewScreen(1,2);
           dokothrecords(0);
          end;
      else
       begin
        NewScreen(1,0);
        dolist(0,index-1);
       end;
     end;

 1 : if (index=1) then
      begin
       NewScreen(1,0);
       dohillrec(0);
      end else
       begin
        NewScreen(1,5);
        dohillrec(index-1);
       end;
 2 : begin
      NewScreen(1,0);
      dohillrec(0);
     end;
 end;

  fontcolor(241);
  if (index>1) then ewritefont(319,5,'(-'+lstr(246));

  str1:=lstr(247);
  if (index=num) then str1:=lstr(248);

  ewritefont(319,13,str1+'-)');

  DrawScreen;

  leave:=false;

 repeat

  good:=false;

  SDLPort.WaitForKeyPress(ch,ch2);
{  ch2:=#1; }

  case ch of
  #27 : begin index:=-1; good:=true; end;

  ' ',#13 : begin inc(index); good:=true; end;
  #3 : begin index:=-2; good:=true; end; { CTRL-C }

  end; { case }

  if (ch=#0) then
  case ch2 of
  #68, #45 : begin index:=-2; good:=true; end; { ALT-X, F10 }

  #77,#81 : begin inc(index); good:=true; end; { PgDn, A_Right }

  #71 : if (index>1) then { HOME }
         begin
          index:=1;
          good:=true;
         end;

  #73,#75 : if (index>1) then { PgUp, A_Left }
              begin
               dec(index);
               good:=true;
              end;

  end; { case }

  until (good);

  if (index<0) or (index>num) then leave:=true;

 until (leave);


(*

 NewScreen(1,0);
 dolist(0,0);

 waitforkey2(ch);
 NewScreen(4,0);

 dolist(0,1);
 dolist(0,2);

 waitforkey2(ch);

 NewScreen(1,2);

  dokothrecords(0);

 waitforkey2(ch);

*)

end;




function donewheader(vaihe:byte):string; { vaiheet: 0 - WCquali  1 - WC   2 - 4hills }
var out,str1, str2 : string;
    temp3 : integer;
begin

{  if (vaihe=2) then newscreen(1,4) else newscreen(1,0); }

{  fontcolor(240); }

 out:='';

  case vaihe of
  4 : begin
       if (osakilpailu=CupHills) then out:=lstr(90)+' '+lstr(27+cupstyle)
        else
         begin
          (*  for temp:=1 to pmaara do begin {sija[g]:=51-g;} Stats[temp,osakilpailu].WCPos:=NumPl; end;
           *)
          out:=lstr(27+cupstyle)+' '+lstr(87)+' '+txt(osakilpailu)+' '+lstr(8)+' '+txt(CupHills);
         end;

  end;

  3 : begin
       case cupstyle of
       0,2 : if (osakilpailu=12) or (osakilpailu=CupHills) then out:=lstr(85)
              else
               begin
                temp3:=osakilpailu;
                if (osakilpailu>4) then temp3:=osakilpailu-8; { joko yksin„„n tai osana WC:t„ }
                str1:=txt(temp3)+' '+lstr(83)+' - '+acthill.name+' K'+txt(acthill.kr);
                out:=lstr(84)+' '+str1;
               end;
       1 : if (osakilpailu=CupHills) then out:=lstr(90)+' '+lstr(28)
            else out:=lstr(28)+' '+lstr(87)+' '+txt(osakilpailu)+' '+lstr(8)+' '+txt(CupHills);
       end;
      end;

  0,1,2 : begin
           str1:=lstr(81);
           if (vaihe=0) then str1:=lstr(82);
           str2:=txt(osakilpailu)+' '+lstr(8)+' '+txt(CupHills);
           if (cupstyle=2) then str2:=txt(osakilpailu)+' '+lstr(83);
           str2:=str2+' - '+acthill.name+' K'+txt(acthill.kr);
           if (kierros>0) then str2:=str2+' - R '+txt(kierros);
           out:=str1+' '+str2;
          end;
  end;

{    fillline(15,'-'); }

{  if (vaihe=2) then textbackground(0) else textbackground(1); }

{    b:=1;c:=3; }

 donewheader:=out;

end;



procedure compactsign;
begin

 fontcolor(241);
 writefont(30,190,lstr(86));

end;



procedure updatestats(what:byte);
                    { what: 0 - WCStats, 1 - normal, 2 - 4H }

var temp, who, victim : integer;
    str1 : string;

begin

 for temp:=1 to NumPl do
  begin
   who:=luett[temp];
   if (what=0) then who:=mcluett[temp];

   if (who > NumPl-pmaara) then { oma j„tk„ }
    begin
     victim:=Numpl+1-who;

     case what of
     0 : if (cupstyle=0) then
          begin { WC pohjaisia statseja }
           Stats[victim,osakilpailu].WCPos:=sija[who];
           if (osakilpailu=CupHills) then
           begin
            if (sija[who]=1) then inc(Profile[profileorder[victim]].WCswon);
            inc(Profile[profileorder[victim]].WCs);
           end;

           if (mcpisteet[who] >= Profile[profileorder[victim]].bestpoints) then
           begin
            Profile[profileorder[victim]].bestpoints:=mcpisteet[who];
            str1:='-';
            if (osakilpailu=CupHills) then str1:=txt(sija[who])+'.';
            Profile[profileorder[victim]].bestresult:=
            txt(mcpisteet[who])+' ('+str1+')';
           end;

         end;

     1 : begin { perus kisanaikaisia statseja }
          Stats[victim,osakilpailu].Comppos:=sija[who];
          if (kierros=1) then Stats[victim,osakilpailu].Round1Pos:=sija[who];
          if (cupstyle=0) and (kierros=2) and (sija[who]=1) then inc(Profile[profileorder[victim]].legswon);
         end;
     2 : begin
          Stats[victim,0].RoundPts[1]:=fourpts[who]; { fourhills tulos talteen }
          Stats[victim,0].CompPos:=sija[who];
         end;

     end;


    end;

  end;

end;



function sorthighs(vaihe:byte):byte;
          { vaihe: 0 - WC, 1 - TC, 2 - 4H, 3 - KOTH, 4 - CC_MC, 5 - CC_4P }

          { highstart: 0 - WC, 20 - TC, 30 - 4H, 35 - KOTH, 41 - CC  }

var t1,t2,t3,t4 : integer;
    localnosamename, leave : boolean;
    who, players : integer;
    pts : longint;
    highstart,highlength : byte;
    victimname : string;
    return : byte;
{    ch,ch2 : char; }
    datestr : string;

begin

   highstart:=0;
   highlength:=20;
   players:=pmaara;
   return:=0;
   localnosamename:=nosamename;
   datestr:=dayandtime(Today,Now);

   case vaihe of
   1 : begin
        players:=jmaara;
        highstart:=20;
        highlength:=10;
       end;
   2 : begin
        highstart:=30;
        highlength:=5;
       end;
   4,5 : begin
          highstart:=41;
          localnosamename:=true; { ei milloinkaan useampia nimi„ }
         end;
   end;

    for t1:=1 to players do
     for t2:=1 to highlength do
      begin
       who:=NumPl+1-t1;
       victimname:=nimet[who];

       if (vaihe=1) then
        begin
         who:=NumTeams+1-t1;
         victimname:=jnimet[who];
        end;

       case vaihe of
       0,1,4 : pts:=mcpisteet[who];
         2,5 : pts:=fourpts[who];
       end;

      if (pcomp(pts,sija[who]) > pcomp(top[t2+highstart].score,top[t2+highstart].pos)) then
        begin

         leave:=true; { tekeek” nimet vai ei }

         if (localnosamename) then
          begin
           for t3:=1 to t2-1 do
            if (top[t3+highstart].name = victimname) then leave:=false;

           if (leave) then { ei ollut parempaa samaa nime„ }
            begin

             for t3:=t2 to highlength do
              if (top[t3+highstart].name = victimname) then
               begin
                for t4:=t3 to highlength-1 do
                 begin
                  top[t4+highstart].score:=top[t4+highstart+1].score;
                  top[t4+highstart].name:=top[t4+highstart+1].name;
                  top[t4+highstart].pos:=top[t4+highstart+1].pos;
                  top[t4+highstart].time:=top[t4+highstart+1].time;
                 end;
                t3:=highlength;
               end;
            end;

          end;

         if (leave) then
          begin
           if (t2<highlength) then
            for t3:=highlength downto t2+1 do
             begin
              top[t3+highstart].score:=top[t3+highstart-1].score;
              top[t3+highstart].name:=top[t3+highstart-1].name;
              top[t3+highstart].pos:=top[t3+highstart-1].pos;
              top[t3+highstart].time:=top[t3+highstart-1].time;
             end;

           if (vaihe>3) and (cuphills=1) then
            datestr:='('+txtp(Stats[t1,1].RoundLen[1])+'m-'+txtp(Stats[t1,1].RoundLen[2])+'m)';

           top[t2+highstart].score:=pts;
           top[t2+highstart].name:=victimname;
           top[t2+highstart].pos:=sija[who];
           top[t2+highstart].time:=datestr;

           return:=t2; { pyrkii palauttamaan lis„tyn pelaajan sijan }

           if (vaihe<4) then
            begin
             NewScreen(1,0);
             dolist(t2,vaihe);
             waitforkey3(305,6,ch);
            end;

          end; { if leave }

          t2:=highlength;

         end;
      end; { end top }

 sorthighs:=return;

end;


procedure updaterecords(sortby:byte);
var final, cscreen : boolean;
    str1 : string;
    t1, who, temp2 : integer;
    oldhi : Hiscore;


begin

 final:=false; cscreen:=false;

 if (osakilpailu=CupHills) then final:=true;

 for t1:=1 to pmaara do
  begin
   who:=NumPl+1-t1;

   { pari profilesin parasta tulosta }

   if ((cupstyle=0) and (osakilpailu=12)) or ((cupstyle=2) and (final)) then
    begin
     if (fourpts[who] >= Profile[profileorder[t1]].best4points) then
      begin
       Profile[profileorder[t1]].best4points:=fourpts[who];
       str1:=txt(sija[who])+'.';
       Profile[profileorder[t1]].best4result:=
       txtp(fourpts[who])+' ('+str1+')';
      end;
    end;

   if (cupstyle=0) and (mcpisteet[who] >= Profile[profileorder[Numpl+1-who]].bestpoints) then
      begin
       Profile[profileorder[Numpl+1-who]].bestpoints:=mcpisteet[who];
       str1:='-';
       if (final) then str1:=txt(sija[who])+'.';
       Profile[profileorder[Numpl+1-who]].bestresult:=
        txt(mcpisteet[who])+' ('+str1+')';
      end;

   if (cupstyle=1) and (final) then
    begin
     LoadCustom(SetFile,sortby,hillorder,cuphills);
     oldhi:=top[42];
     temp2:=sorthighs(4+sortby);

     if (temp2 = 1) and (SetFile<>'TEMP') then cscreen:=true;

     if (temp2 > 0) then WriteCustom(SetFile,sortby,HillOrder,CupHills);
    end;

(*
     pts:=mcpisteet[who];
     if (sortby=1) then pts:=fourpts[who];

     if (pts > temphi.score) then
      begin
       oldhi:=temphi;
       temphi.name:=nimet[who];
       temphi.pos:=sija[who];
       temphi.score:=pts;
       temphi.time:=dayandtime(Today,Now);
       WriteCustomRecord(SetFile,temphi);
       cscreen:=true;
      end;
*)

  end;

 if (not cupslut) then
  case cupstyle of
  0 : begin
       if (osakilpailu=12) then sorthighs(2);
       if (final) then sorthighs(0);
      end;
  1 : if (cscreen) then NewCRecordScreen(SetFile,top[42],oldhi,sortby);
  2 : if (final) then sorthighs(2);
  end;

end;


procedure lista(vaihe:byte);
          { oldvaiheet: 0 - WCquali  1 - WC, 2 - 4hills }
          { newvaiheet: 0 - WCquali, 1 - WCk1, 2 - WCk2, 3 - 4H, 4 - MClista }
          { monta :         kaikki,    qualit,    qualit,  >4pts     >MCpist }

var t1,t2, pts : longint;
    valiviiva, leave : boolean;
    who, prev, next, temp, temp2 : integer;
    shown, needtoshow : integer;
    extra : string;
    oknow : boolean;
    templuett : array[0..NumPl+1] of byte;

function shouldishow(player:integer):byte;
var outbyte : byte;
    who2 : integer;
    pts2 : longint;

begin
 outbyte:=0; { ei t„t„ pit„isi n„ytt„„, ei oo oma }
 who2:=templuett[player];

 case vaihe of
 0,1,2 : pts2:=pisteet[who2];
     3 : pts2:=fourpts[who2];
     4 : pts2:=mcpisteet[who2];
 end;

 if (who2 > NumPl-pmaara) Then { oma j„tk„ }
  case vaihe of
    0 : outbyte:=1;
  1,2 : if (qual[who2]>0) then outbyte:=1;
  3,4 : if (pts2>0) then outbyte:=1;
  end; { case }

 shouldishow:=outbyte;

end;

 begin

  needtoshow:=0; { monta omaa j„tk„„ on edes tarkoitus n„ytt„„ }

   for temp:=0 to NumPl+1 do templuett[temp]:=0;

   for temp:=1 to NumPl do { t„„ll„ k„ytet„„n templuettia }
    if (vaihe=4) then templuett[temp]:=mcluett[temp]
                 else templuett[temp]:=luett[temp];

   for temp:=1 to NumPl do inc(needtoshow,shouldishow(temp));

  temp:=0;

  case vaihe of
  1,2 : temp:=1;
  3 : temp:=2;
  4 : temp:=3;
  end;

  resetlist(pmaara, NumPl, temp, donewheader(vaihe), InvBack);
  if (compactlist) then compactsign;

  leave:=false;
  valiviiva:=false; { ei ole sit„ piirretty viel„ }

  temp:=1;
  shown:=0;

  repeat

   who:=templuett[temp];
   prev:=templuett[temp-1];
   next:=templuett[temp+1];

   extra:='X';  { ett„ extra[1] on jotain j„rkev„„ }

   temp2:=0;

   oknow:=false;

   if (compactlist) then  { compakti tuloslista. }
    repeat

     who:=templuett[temp];
     prev:=templuett[temp-1];
     next:=templuett[temp+1];

(*
     if (sija[who]>10) and (sija[prev]<=10) and (shown<needtoshow)
      then temp2:=entry(0,0,2,'...',0,0,0,'X');  { v„liviiva }
*)

     if (shouldishow(temp)=1) then  { t„„ mun pitikin n„ytt„„ }
      begin
       inc(shown);
       oknow:=true;
      end
       else  { muu j„tk„, mutta kympin sis„ll„ on my”s ok }
        if not (sija[who]>10) then oknow:=true;

     if (shown=needtoshow) and (sija[next]>10) then { kaikki omat n„ytetty ja seuraava ei kuulu en„„ t„nne }
      begin
       oknow:=true;
       extra:='L';
      end;

      if (not oknow) then inc(temp);

    until (oknow);

     if (sija[who]>30) and (not compactlist) and
        (sija[prev]<=30) and (vaihe=1)
         then temp2:=entry(0,0,2,'- - -',0,0,0,'X'); { 1. kierros v„liviiva }

   if (temp2>=0) then
    begin

     case vaihe of
      0,1,2 : begin t1:=pisteet[who]; t2:=pisteet[templuett[1]]; end;
          3 : begin t1:=fourpts[who]; t2:=fourpts[templuett[1]]; end;
          4 : begin t1:=mcpisteet[who]; t2:=mcpisteet[templuett[1]]; end;
     end;

     pts:=t1;

     if (diff) and (temp>1) then pts:=t1-t2;

     if (vaihe=0) and (qual[who]>0) then
       begin
        extra:=extra+'Q';
        if (sija[who]>50) then extra:=extra+'W';
       end;

     if (vaihe<2) and (sija[who]<=30) then extra:=extra+'Q';

     if (inj[who]>0) and (vaihe<3) then extra:=extra+'I'+txt(inj[who]-1);

     if (vaihe<3) and (thisisahillrecord = (kierros*1000)+who)
      then extra:=extra+'R';

    case vaihe of { ett„ tiedet„„n loppuiko tulostettavat }
     0   : if (temp>=NumPl) then extra:='L'+extra;
     1,2 : if (qual[next]=0) then extra:='L'+extra;
     3   : if (fourpts[next]=0) then extra:='L'+extra;
     4   : if (mcpisteet[next]=0) then extra:='L'+extra;
    end;

    if (next=0) or (next>NumPl) then extra:='L'+extra;

    case vaihe of
    0   : temp:=entry(temp,sija[who],who,nimet[who],pts,Cstats[0,who],0,extra);
    1,2 : temp:=entry(temp,sija[who],who,nimet[who],pts,Cstats[1,who],Cstats[2,who],extra);
    3   : temp:=entry(temp,sija[who],who,nimet[who],pts,0,0,extra);
    4   : if (mcpisteet[who]>0) then temp:=entry(temp,sija[who],who,nimet[who],pts,0,0,extra);
    end;


    if (compactlist) and (not valiviiva) then
       if (sija[next]>10) and (sija[who]<=10) then
          begin
          valiviiva:=true;
          temp2:=entry(0,0,2,'...',0,0,0,'X');  { v„liviiva }
          end;
       end;

    if (temp<0) or (temp2<0) then leave:=true;

  until (leave);

{  DrawScreen; }

  if (temp=-2) then cupslut:=true;

{  cupslut:=waitforkey2(ch); }

{$IFDEF REG}
 if (not cupslut) and (cupstyle=0) and (ch<>#27) and (vaihe=4) and
    ((LCT) or (osakilpailu=NumWCHills)) then showstats;
{$ENDIF}

  end;


procedure jlista(num:integer); { num - monesko hypp„„j„ }
var str1 : string;
    temp, who, pts : integer;
    extra : string;
    ldiff, leave : boolean;
 begin

 temp:=5;
 ldiff:=diff;
 str1:=lstr(81)+' '+txt(osakilpailu)+' '+lstr(8)+' 6 - R '+txt(kierros)+' - '+lstr(88)+' '+txt(num);

 if (num=0) then { cuplista }
  begin
   temp:=6;
   ldiff:=diffwc;
   str1:=lstr(91)+' '+txt(osakilpailu)+' '+lstr(8)+' 6';
   if (osakilpailu=6) then str1:=lstr(92);
  end;

 ResetList(jmaara,NumTeams,temp,str1,InvBack);

 leave:=false;

 temp:=1;

 repeat

  who:=luett[temp];
  if (num=0) then who:=mcluett[temp];

  extra:='X';
  if (temp=15) then extra:='L';
  if (num=0) then
   begin
    if (mcpisteet[mcluett[temp+1]] = 0) then extra:='L';
    Stats[NumTeams,osakilpailu].WCPos:=sija[NumTeams]; { ?? }
    Stats[NumTeams-1,osakilpailu].WCPos:=sija[NumTeams];
   end;

  if (who > 15-jmaara) Then
   begin
    sija[0]:=sija[who];
    if (num=0) then Stats[15-who,osakilpailu].WCPos:=sija[who]
     else
      begin
       Stats[(num+(15-who)*4),osakilpailu].RoundLen[kierros]:=sija[who];
       Stats[15-who,osakilpailu].CompPos:=sija[who];
      end;
   end;

  pts:=pisteet[who];
  if (num=0) then pts:=mcpisteet[who];

   if (ldiff) and (temp>1) then
    begin
     if (num=0) then pts:=pts-mcpisteet[mcluett[1]]
                else pts:=pts-pisteet[luett[1]];
    end;

  temp:=entry(temp,sija[who],who,jnimet[who],pts,0,0,extra);

  if (temp<0) then leave:=true;

 until (leave);

  if (temp=-2) then cupslut:=true;

  if (num=0) then
   begin
{$IFDEF REG}
    if (ch='s') or (ch='S') or (LCT) then
     if (not cupslut) then showstats;
{$ENDIF}
    if (osakilpailu=6) then sorthighs(1);
   end;

 end;


procedure jarjestys(fromarray,toarray,num:byte);
                    { from: 0 - MCpist, 1 - fourpts, 2 - pisteet }
                    { to: 0 - mcluett, 1 - luett }

var score1,score2 : longint;
    t1,t2,t3 : integer;
    templuett : array[0..NumPl+1] of byte;

begin

 for t1:=1 to NumPl+1 do  { kaikki nolliin }
  begin
   templuett[t1]:=0;
   sija[t1]:=0;
  end;

  for t1:=1 to Num do   { Jokainen hypp„„j„ k„yd„„n l„pi }
   begin
    t2:=1;
    repeat   { Verrataan jokaiseen }

     case fromarray of
     0 : begin score1:=mcpisteet[t1]; score2:=mcpisteet[templuett[t2]]; end;
     1 : begin score1:=fourpts[t1]; score2:=fourpts[templuett[t2]]; end;
     2 : begin score1:=pisteet[t1]; score2:=pisteet[templuett[t2]]; end;
     end;

     if (score1 > score2) then
      begin
        for t3:=Num downto t2 do
         templuett[t3]:=templuett[t3-1];

         templuett[t2]:=t1;
         t2:=100;
      end else
      if (t2=Num) then templuett[t1]:=t1;

     inc(t2);

    until (t2>Num);

   end;

  for t1:=1 to Num do     { k„„nteistaulukko eli sija[pelaaja]? }
   sija[templuett[t1]]:=t1;

  for t1:=2 to Num do     { tasapiste-sijoittelija }
   begin
     case fromarray of
     0 : begin score1:=mcpisteet[templuett[t1]]; score2:=mcpisteet[templuett[t1-1]]; end;
     1 : begin score1:=fourpts[templuett[t1]]; score2:=fourpts[templuett[t1-1]]; end;
     2 : begin score1:=pisteet[templuett[t1]]; score2:=pisteet[templuett[t1-1]]; end;
     end;

    if (score1=score2) then sija[templuett[t1]]:=sija[templuett[t1-1]];

   end;

 case toarray of
 0 : for t1:=1 to Num do mcluett[t1]:=templuett[t1];
 1 : for t1:=1 to Num do luett[t1]:=templuett[t1];
 end;

end;


procedure kothjarj;
var t1,t2,t3 : integer;
    players, score1, score2 : integer;
begin

 players:=kothmaara+pmaara;

  for t1:=1 to players do   { Jokainen hypp„„j„ k„yd„„n l„pi }
   begin
    t2:=1;
    repeat   { Verrataan jokaiseen }

    score1:=pisteet[mcluett[t1]]; score2:=pisteet[luett[t2]];

    if (mcpisteet[mcluett[t1]]>0) then { pelaaja on jo laulukuorossa }
     score1:=-mcpisteet[mcluett[t1]]*100;

    if (mcpisteet[luett[t2]]>0) then { pelaaja on jo laulukuorossa }
     score2:=-mcpisteet[luett[t2]]*100;

      if (score1 > score2) then
       begin
         for t3:=players downto t2 do
          luett[t3]:=luett[t3-1];

         luett[t2]:=mcluett[t1];
         t2:=100;
       end else
       if (t2=players) then luett[t1]:=mcluett[t1];

      inc(t2);

    until (t2>players);

   end;

end;


procedure jcupluettelo;
var loop1 : integer;
 begin

  for loop1:=1 to NumTeams do
   if (sija[loop1]<9) then inc(mcpisteet[loop1],Teampoints[sija[loop1]]);

  jarjestys(0,0,NumTeams);

   jlista(0);

 end;


procedure kothlista;
var temp, temp2 : integer;
    who,players : integer;
    leave : boolean;

    extra,str1 : string;

begin

{ fillline(14,'"'); }

 kothjarj;

 players:=kothmaara+pmaara;

 for temp:=1 to players-1 do  { tasapisteiss„ arvotaan }
  begin
   if (pisteet[luett[temp]] = pisteet[luett[temp+1]]) and (random(2)=0) then
    if (mcpisteet[luett[temp]]=0) and (mcpisteet[luett[temp+1]]=0) then
    begin
{     beep(2); }
     temp2:=luett[temp];
     luett[temp]:=luett[temp+1];
     luett[temp+1]:=temp2;
    end;
  end;

 temp:=players+1-mcpisteet[0];

  mcpisteet[luett[temp]]:=temp;

 for temp:=1 to NumPl+1 do luett[temp]:=0;

  kothjarj;

{  for a:=1 to 50 do pisteet[a]:=1000; }

  str1:=' '+lstr(95);

  if (players-mcpisteet[0]=1) then str1:='!';

  resetlist(pmaara,NumPl,4,lstr(31)+str1, InvBack);

  temp:=1;

   repeat

{    DrawScreen;
    ch:=readkey; }

     temp2:=0;
     extra:='X';

     if (temp = players+1-mcpisteet[0]) then
      begin
       str1:=lrstr(101,105);

       temp2:=entry(0,0,3,str1,0,0,0,'X');

{       drawscreen; readkey; }
      end;

    if (temp2>=0) then
     begin

      if (temp>=players) then extra:='L'; { vikaa vied„„n }

      if ((temp=1) and (players-mcpisteet[0]=1)) then
       extra:=extra+'K'; { is KING OF THE HILL }

      who:=luett[temp];

      temp:=entry(temp,temp,who,nimet[who],pisteet[who],Cstats[1,who],Cstats[2,who],extra);

      leave:=false;

     end;

      if (temp<0) or (temp2<0) then leave:=true;

    until (leave);

{     DrawScreen; }

     if (temp=-2) then cupslut:=true;

     if (players-mcpisteet[0]=1) and (luett[1] > NumPl-pmaara) and
        (kothpack>0) and (not cupslut) then
      begin  { completion! }
       inc(top[35+kothpack].score);
       top[35+kothpack].name:=nimet[luett[1]];
       top[35+kothpack].time:=dayandtime(Today, Now);

       temp2:=Profile[profileorder[Numpl+1-luett[1]]].kothlevel;

       if (temp2=0) or (kothpack < temp2) then
        Profile[profileorder[Numpl+1-luett[1]]].kothlevel:=kothpack; { profilen kothlevel }

       NewScreen(1,2);

       dokothrecords(kothpack);

       Waitforkey3(305,6,ch);

      end;

end;

procedure showpairs(phase:byte); { 0-esittely, 1-tuloksien kanssa }
var temp,temp2,who : integer;

 procedure drawstuff(column,row,item:byte);
  var xx,yy,plus:integer;
      extra : string[5];
  begin
   xx:=145+(column*30);
   yy:=17+(row*7);
   plus:=fontlen(nsh(nimet[who],100))+5;
   if (plus>105) then plus:=105;

   extra:='';
   if (qual[who]=1) then extra:='Q';
   if (qual[who]=2) then extra:='LL';

   case item of
   0 : ewritefont(xx,yy,nsh(nimet[who],100));
   1 : writefont(xx,yy,nsh(nimet[who],100));
   2 : ewritefont(xx-plus,yy,'('+txt(qual[who])+')');
   3 : writefont(xx+plus,yy,'('+txt(qual[who])+')');
{   4 : ewritefont(xx-plus,yy,txtp(pisteet[who]));
   5 : writefont(xx+plus,yy,txtp(pisteet[who])); }
   4 : ewritefont(40,yy,txtp(pisteet[who]));
   5 : ewritefont(303,yy,txtp(pisteet[who]));

   6 : ewritefont(12,yy,extra);
   7 : writefont(308,yy,extra);

   10 : writefont(154,yy,'vs.');

   end;

  end;

begin

 newscreen(1,0);
 fontcolor(240);
  writefont(30,6,lstr(94));
 fontcolor(241);

 for temp:=25 downto 1 do
   for temp2:=0 to 1 do
    begin
     who:=luett[51-temp];
     if (temp2=1) then who:=luett[temp];

     if (kierros=1) and (who>Numpl-pmaara) then Stats[NumPl+1-who,osakilpailu].Round1Pos:=sija[who];

     fontcolor(241);
     drawstuff(temp2,26-temp,10); { vs. }
{     if (who>Numpl-pmaara) then fontcolor(240); }
     if (phase=1) then case qual[who] of
     1 : fontcolor(251); { tummankeltainen }
     2 : fontcolor(252);
     end;

     if (who>Numpl-pmaara) then fontcolor(240);

     drawstuff(temp2,26-temp,temp2); { nimi ruutuun }
     if (phase=1) then
      begin
{       if (who>Numpl-pmaara) and (qual[who]>0) then fontcolor(246); }
       drawstuff(temp2,26-temp,temp2+4);
       drawstuff(temp2,26-temp,temp2+6);
      end else drawstuff(temp2,26-temp,temp2+2); { qual }

    end;

 cupslut:=Waitforkey3(305,6,ch);

end;





procedure jumpalku;
var temp : integer;
 begin
{  maki:=osakilpailu mod mmaara; }

{  nytmaki:=osakilpailu; }  { t„m„ tehd„„n paikallisesti ennen jumpalkua }

{  kr:=kri[nytmaki]; } { t„m„ luetaan LoadInfon avulla }

  LoadInfo(nytmaki,ActHill);

(*
  if jcup then mctil[0,osakilpailu,1]:=maki;     { Miss„ m„ess„ hyp„ttiiin... }
  *)

  for temp:=1 to NumPl+1 do
   begin
    pisteet[temp]:=0;
    luett[temp]:=0;
    mcluett[temp]:=0;
    cstats[0,temp]:=0;
    cstats[1,temp]:=0;
    cstats[2,temp]:=0;
   end;

  ThisIsAHillRecord:=0;

 end;




function selecthill(phase:byte):byte; { 0 - train, 1 - koth, 2 - morehills, 3 - morehills KOTH }
                                      { uusi: 0 - train, 1 - koth }
var temp, gothill : integer;
    hill : integer;
    str1 : string;
    items : integer;
    leave : boolean;
    start : integer;

begin

 start:=0;

 repeat

  NewScreen(2,0);

{  if (start=0) then NewScreen(2,0)
               else NewScreen(2,5); }

  fontcolor(240);

  writefont(30,31,lstr(151));
  writefont(30,41,lstr(152));
  writefont(30,51,lstr(153));

  items:=NumExtraHills+NumWCHills-start;
  if (items>20) then items:=20;

  for temp:=1 to items do
   begin
    hill:=temp+start;

    fontcolor(246);
    ewritefont(130,(temp-1)*8+10,txt(temp)+'.');

    fontcolor(247);
    writefont(145+fontlen(hillname(hill)),(temp-1)*8+10,'K'+txt(hillkr(hill)));
    fontcolor(240);
    writefont(140,(temp-1)*8+10,hillname(hill));
   end;

  if (NumExtraHills>0) then { * more hills * }
   begin
    inc(temp); inc(items);
    fontcolor(247);
    writefont(140,(temp-1)*8+10,lstr(156));
    fontcolor(240);
   end;

  inc(temp,2);
   ewritefont(130,(temp-1)*8+10,'0.');
   str1:=lstr(154);
    if (phase=1) then str1:=lstr(155);
   writefont(140,(temp-1)*8+10,str1);

   DrawScreen;

  gothill:=MakeMenu(110,11,170,8,items,1,243,0,0);

  leave:=true;

  if (gothill=items) and (NumExtraHills>0) then
   begin
    inc(start,20);
    if (start>=NumExtraHills+NumWCHills) then start:=0;
    leave:=false;
   end;

 until (leave);

 temp:=gothill+start;

 if (gothill<=0) then temp:=gothill;

 selecthill:=temp;

end;



procedure training;
begin

 osakilpailu:=0;
 kierros:=-10;
 treeni:=true;
 cupslut:=false;
 ch:=#1;
 startgate:=15;

  repeat

   eka:=true;

   nytmaki:=selecthill(0);

   if (nytmaki=0) then cupslut:=true;

   if (nytmaki>0) then jumpalku;

   { kr:=kri[nytmaki]; }
   if (ch<>#27) and (nytmaki>0) then
    repeat
     Tuuli.Alusta(windplace);

     hyppy(1,NumPl+1,0);

     eka:=false;
    until (ch=#27) or (cupslut);

    ch:=#1;

   until (cupslut);

  treeni:=false;
  startgate:=0; { varmuuden vuoksi }

end;




procedure getkoth;
var temp : integer;
begin

 case kothpack of
   1   : begin
          kothmaara:=20;
          for temp:=1 to kothmaara do kothpel[temp]:=temp;
          kothwind:=false;
          kothrounds:=2;
          kothmaki:=0;
         end;
   2   : begin
          kothmaara:=14;
          for temp:=1 to kothmaara do kothpel[temp]:=temp*3-1;
          kothwind:=true;
          kothrounds:=1;
          kothmaki:=0;
         end;
   3   : begin
          kothmaara:=10;
          for temp:=1 to kothmaara do kothpel[temp]:=temp*4-1;
          kothwind:=false;
          kothrounds:=2;
          kothmaki:=0;
         end;
   4   : begin
          kothmaara:=8;
          for temp:=1 to kothmaara do kothpel[temp]:=temp*5+1;
          kothwind:=true;
          kothrounds:=1;
          kothmaki:=0;
         end;
   5   : begin
          kothmaara:=7;
          for temp:=1 to kothmaara do kothpel[temp]:=temp*6+13;
          kothwind:=false;
          kothrounds:=2;
          kothmaki:=0;
         end;
   6   : begin
          kothmaara:=6;
          for temp:=1 to kothmaara do kothpel[temp]:=temp*7+15;
          kothwind:=true;
          kothrounds:=1;
          kothmaki:=0;
         end;

{   7   : begin
          kothmaara:=random(9)+1;
          for temp:=1 to 9 do
           begin
            kothpel[temp]:=random(60)+1;
             for b:=1 to a-1 do
              if kothpel[temp]=kothpel[b] then dec(a);
           end;
          kothwind:=boolean(random(2));
          koth1r:=boolean(random(2));
         end;  }
    end; { case }
end;

procedure startkoth;
var temp, index : integer;
    realindex : integer;
begin

   koth:=true;
   cupslut:=false;
   startgate:=0;

   if (kothmaki=0) then nytmaki:=random(NumWCHills)+1 else nytmaki:=kothmaki;

   if (nytmaki>0) then jumpalku;

   if (kothwind) then Tuuli.Alusta(windplace) else tuuli.voim:=0;

{  if (not cupslut) and (preview1) then preview(nytmaki); }

  for temp:=1 to kothmaara do
    mcluett[temp]:=kothpel[temp];

  for temp:=1 to pmaara do
    mcluett[kothmaara+temp]:=NumPl+1-temp;

  for temp:=1 to NumPl do
    mcpisteet[temp]:=0;

  eka:=true;

 if (not cupslut) then
  for mcpisteet[0]:=1 to kothmaara+pmaara-1 do   { kisaluuppi }
   begin
    for temp:=1 to kothmaara+pmaara do
     if (mcpisteet[mcluett[temp]]=0) then pisteet[mcluett[temp]]:=0;

   for temp:=1 to NumPl do
    luett[temp]:=0;

{  eka:=true; } { kaivanvertanen„st„ }
  kierros:=1;
  realindex:=0; { monta „ij„„ oikeasti hyp„nnyt }

   for index:=1 to kothmaara+pmaara do
    if (mcpisteet[mcluett[index]]=0) then
     if (not cupslut) then
      begin
       inc(realindex);
       hyppy(index,mcluett[index],realindex);
       eka:=false;
      end;

{    eka:=true;  } { TSEKKAA TŽMŽ!!! }

  realindex:=0;

  if (kothrounds=2) then
   begin
    kierros:=2;

    for index:=1 to kothmaara+pmaara do
     if (mcpisteet[mcluett[index]]=0) then
      if (not cupslut) then
       begin
        inc(realindex);
        hyppy(index,mcluett[index],realindex);
        eka:=false;
       end;

   end;

  if (not cupslut) then kothlista;

{    textcolor(1);
    for a:=1 to kothmaara+pmaara do
     writeln(a,'. ',mcpisteet[mcluett[a]],' ',nimet[mcluett[a]],mcluett[a],'  ',pisteet[a]);
    readln; }

   end;

{   readln; }

 koth:=false;

end;



procedure choosekoth;
var temp, y : integer;
{    ch2 : char; }

begin
 kothmaara:=0;

 fillbox(170,0,319,199,243);
 fillarea(170,0,319,199,63);

 fontcolor(240);
 writefont(180,2,lstr(138));

 fontcolor(241);
 writefont(180,9,lstr(139));
 writefont(180,16,lstr(140));

 fontcolor(247);
 writefont(180,24,lstr(141));
 writefont(295,24,lstr(142));

 repeat

  inc(kothmaara);

   repeat

    y:=kothmaara*8+25;

    fillbox(178,y-2,315,y+8,243);
    fontcolor(240);
    writefont(180,y,nsh(nimet[kothpel[kothmaara]],110));
    ewritefont(310,y,'#'+txt(kothpel[kothmaara]));

    DrawScreen;

    SDLPort.WaitForKeyPress(ch,ch2);

     if (ch=#13) then { tsekataan ettei sit„ pelaajaa ole jo }
      begin
       for temp:=1 to kothmaara-1 do
                if kothpel[temp]=kothpel[kothmaara] then
                 begin
                  if (kothpel[kothmaara]<NumPl-pmaara) then inc(kothpel[kothmaara]);
                  if (beeppi) then beep(2);
                  ch:=#1;
                 end;
              end;

     if (ch=#0) then
      begin
       if (ch2=#71) then kothpel[kothmaara]:=1;
       if (ch2=#79) then kothpel[kothmaara]:=NumPl-pmaara;
       if ((ch2=#72) or (ch2=#75)) and (kothpel[kothmaara]>1) then dec(kothpel[kothmaara]);
       if ((ch2=#80) or (ch2=#77)) and (kothpel[kothmaara]<NumPl-pmaara) then inc(kothpel[kothmaara]);
       if (ch2=#73) and (kothpel[kothmaara]>10) then dec(kothpel[kothmaara],10);
       if (ch2=#81) and (kothpel[kothmaara]<NumPl-9-pmaara) then inc(kothpel[kothmaara],10);
      end;

     if (ch=#9) then ch:=#27;

   until (ch=#13) or (ch=#27);

    if (ch=#27) then dec(kothmaara);
    if (ch=#13) then
     begin
      fontcolor(246);
      writefont(180,y,nsh(nimet[kothpel[kothmaara]],110));
      ewritefont(310,y,'#'+txt(kothpel[kothmaara]));
     end;

  until (ch=#27) or (kothmaara=20);

end;



procedure newkingofthehill;
var temp,x,y : integer;
    col1,col2 : byte;
    str1 : string;
    index : integer;
begin

 getkoth;

 repeat

 NewScreen(3,0);

 fontcolor(246);

 if (kothmaara>0) then
  for temp:=1 to kothmaara do
   begin
    writefont(180,20+temp*8,nsh(nimet[kothpel[temp]],110)+' #'+txt(kothpel[temp]));

   end else writefont(180,30,lstr(9));

  x:=10; y:=10;

  fontcolor(240);

  writefont(180,10,lstr(120));


  col1:=240; col2:=246;
  if (kothpack>0) then begin col1:=241; col2:=241; end;

  writefont(x,y,'1 - '+lstr(121)); inc(y,10);

  writefont(x,y,'2 - '+lstr(122)); inc(y,10);

   fontcolor(col1);
  writefont(x,y,'3 - '+lstr(123)); inc(y,10);

  writefont(x,y,'4 - '+lstr(124));
   fontcolor(col2); writefont(x+70,y,nsh(hillname(kothmaki),80)); inc(y,10);
   fontcolor(col1);

  writefont(x,y,'5 - '+lstr(125));
   str1:=lstr(7); if (kothwind) then str1:=lstr(6);
   fontcolor(col2); writefont(x+70,y,str1); inc(y,10);

   fontcolor(col1);
  writefont(x,y,'6 - '+lstr(126));
   fontcolor(col2); writefont(x+70,y,lstr(kothrounds)); inc(y,20);

   fontcolor(240);
  writefont(x,y,'0 - '+lstr(127));

  kothchallenge(x,kothpack);

  DrawScreen;

  index:=MakeMenu(10,10,160,10,6,1,245,0,3);

  case index of
  1 : startkoth;
  2 : begin { select challenge }
       kothchallenge(x,255); { kaikki esiin }
       DrawScreen;

       temp:=kothpack;
       kothpack:=MakeMenu(10,121,160,8,6,1,244,0,254);
{$IFNDEF REG}
       if ((kothpack<1) or (kothpack>6)) then kothpack:=temp;
{$ENDIF}

       getkoth;
      end;
{$IFDEF REG}
  3 : begin
       kothpack:=0;
       choosekoth;
      end; { else if (beeppi) then beep(2); }
  4 : begin
       kothpack:=0;
       kothmaki:=selecthill(1);
      end; { else if (beeppi) then beep(2); }
  5 : begin
       kothpack:=0;
       kothwind:=not kothwind;
      end; { else if (beeppi) then beep(2); }
  6 : begin
       kothpack:=0;
       case kothrounds of
       1 : kothrounds:=2;
       2 : kothrounds:=1;
       end;
      end;{ else if (beeppi) then beep(2);}
{$ENDIF}

  end; { case }

 until (index=0){ or (index=1)};

{  if (index=1) then startkoth; }

 WriteConfig; { kirjoitetaan muutokset levylle }

end;



procedure getteam(num:byte); { 0 - tekee ekan, 1 - tokan... }
var xx, temp : integer;
begin

 xx:=30;

 if (num=1) then xx:=160;

{ FontColor(240); }

{ Writefont(xx,38,'TEAM'+txt(num+1)); }
{ Writefont(xx,0,jnimet[15-num]); }

 FontColor(246);

  for temp:=1 to 4 do
   begin
    Writefont(xx+13,(temp-1)*10+56,Nimet[NumPl+1-(num*4)-temp]);
   end;

 FontColor(240);

  Writefont(xx,30,lstr(113)+' '+txt(num+1)+':');
{  FillBox(40,65,200,81,243); }

{ Fontcolor(240); }

  DrawScreen;

  jnimet[15-num]:=GetStr(xx,42,120,jnimet[15-num],242);

  FillBox(xx-10,30,xx+124,54,243);
  FillArea(xx-10,30,xx+124,54,63);

  FontColor(241);

   WriteFont(xx,30,lstr(114)+' '+txt(num+1)+':');

  fontcolor(240);
   WriteFont(xx,42,Jnimet[15-num]);

end;

procedure teamsready;
var temp, temp2 : integer;
begin

 NewScreen(1,1);

 FontColor(240);
 Writefont(30,6,lstr(111));

{ FontColor(247); }

 WriteFont(30,110,lstr(112));

 for temp:=1 to 40 do
  HillOrder[temp]:=temp;

 HillOrder[1]:=random(NumWCHills)+1;

   for temp:=2 to 6 do
    begin
     HillOrder[temp]:=random(NumWCHills)+1;

     for temp2:=1 to temp-1 do
      if (HillOrder[temp] = HillOrder[temp2]) then dec(temp);

    end;

 FontColor(246);

  for temp:=1 to 6 do
    WriteFont(30,(temp*10)+114,txt(temp)+'. '+hillname(HillOrder[temp]));

{ Writefont(30,36,'THE TEAM LINEUPS ARE:'); }

  GetTeam(0);

  if (jmaara>1) then GetTeam(1);

{  ShowTeam(0);

 if (jmaara>1) then ShowTeam(1);

  FontColor(240); }

  for temp:=1 to 4 do
   TeamLineup[14*4+temp]:=NumPl+1-temp;

 if (jmaara>1) then
  for temp:=1 to 4 do
   TeamLineup[13*4+temp]:=NumPl-3-temp;

 DrawScreen;

 CupSlut:=WaitForKey3(305,180,ch);

{ ReadKey; }

end;




procedure startteam;
var temp, temp2, index, team : integer;
    teamorder : array[1..15] of integer;

 procedure ShowTeams;
 var x,y, t1,t2,t3 : integer;
  begin
   newscreen(1,1);
   writefont(30,6,lstr(111));
   x:=5;
   y:=24;

   for t1:=15 downto 1 do
    begin
     team:=teamorder[t1];
     fontcolor(240);
     writefont(x,y,nsh(jnimet[team],95));

     if (team > 15-jmaara) then fontcolor(246)
                           else fontcolor(241);

     for t2:=1 to 4 do
      begin
       t3:=teamlineup[(team-1)*4 + t2];
       writefont(x+4,y+1+(t2*6),nsh(nimet[t3],90));
      end;

     inc(x,102);
     if (x>240) then begin x:=5; inc(y,35); end;
     drawscreen;

    end;


   cupslut:=waitforkey3(305,6,ch);

  end;


 procedure swap(var i1,i2:integer);
 var temp : integer;
  begin
   temp:=i1;
   i1:=i2;
   i2:=temp;
  end;


begin

 osakilpailu:=0;
 startgate:=0;

 for temp:=1 to 15 do begin mcpisteet[temp]:=0; teamorder[temp]:=16-temp; end;

 for temp2:=1 to 3 do
  for temp:=1 to 14 do
   if (random(2)=0) then swap(teamorder[temp],teamorder[temp+1]);

    ResetStats;

    ShowTeams;

   repeat

    Tuuli.Alusta(windplace);

    inc(osakilpailu);

    nytmaki:=HillOrder[osakilpailu];

    jumpalku;

{    Stats[0,osakilpailu].Reason[1]:=nytmaki; }

{    if (preview1) then preview(nytmaki); }

    kierros:=1;

 {  team:=1; }

   eka:=true;

     for index:=1 to 4 do { jumpers 1..4 }
      begin

       for temp:=1 to 15 do
        luett[temp]:=0;

{       eka:=true; }

      { if (not cupslut) then jmuidenhypyt(index); }

       for temp2:=1 to NumTeams do
        begin

         team:=teamorder[temp2];

         temp:=teamlineup[(team-1)*4 + index];

{         temp:=round((5-index)*2.5+(team*1.5)-3);
         if (team > NumTeams-jmaara) then temp:=NumPl+1-(15-team)*4-index; }

         if (not cupslut) then hyppy(index, temp, team);

         eka:=false;
        end;

       jarjestys(2,1,NumTeams);
       if (not cupslut) then jlista(index);

      end;

    inc(kierros);

{    eka:=true; }  { hullu! }

    if (ch<>'S') and (ch<>'s') then { 2. kierros }
     for index:=1 to 4 do
      begin

       for temp:=1 to 15 do
        luett[temp]:=0;

{       eka:=true; }  { TARKASTA! (OK) }

       for temp2:=1 to NumTeams do
        begin

         team:=teamorder[temp2];
         temp:=teamlineup[(team-1)*4 + index];

{        temp:=round((5-index)*2.5+(team*1.5)-3);
         if (team > NumTeams-jmaara) then temp:=NumPl+1-(15-team)*4-index; }

         if (not cupslut) then hyppy(index, temp, team);
         eka:=false;

        end;

       jarjestys(2,1,NumTeams);
       if (not cupslut) then jlista(index);
      end;

{       eka:=true; }

      if (ch='S') or (ch='s') then { skippaus (?) }
       begin
        for temp:=1 to 15 do
         luett[temp]:=0;
        jarjestys(2,1,NumTeams);
        jlista(index);
       end;

    if (not cupslut) then jcupluettelo;

   until (cupslut) or (osakilpailu>=6);

 { end; }

end;



procedure teamcup;
begin
 jcup:=true;
{ textbackground(1);
  clrscr; }
 cupslut:=false;
 startgate:=0;

{ putsaa; }
 if (pmaara=4) or (pmaara=8) then  { Ehk„ v„h„n turha }
  begin
   LoadNames(namenumber,jmaara,TeamLineup,false);

   teamsready;

   if (not cupslut) then startteam;

 end
 else
  begin

   if (beeppi) then beep(1);

    teamwarning;

  end;

  jcup:=false;

  LoadNames(namenumber,jmaara,TeamLineup,true);

end;




procedure cup;  { cupstyle: 0 - SJ3 WC, 1 - Custom WC, 2 - Just 4Hills }
var temp,temp2,index : integer;
    sortby, skipquali : byte;  { sortby: 0 - WC, 1 - t_points }
    fourhills, dokosystem, skip : boolean;

begin

 wcup:=true;

 osakilpailu:=0;
 startgate:=0;

 cupslut:=false;
{ team:=1; }

 for temp:=0 to NumPl+1 do
  begin
   mcpisteet[temp]:=0;
   fourpts[temp]:=0;
   inj[temp]:=0;
  end;

 ResetStats;

 case cupstyle of
 0 : begin
      for temp:=0 to 40 do
       HillOrder[temp]:=temp;
      CupHills:=NumWCHills;
      sortby:=0;
     end;
 1 : begin
      SelectCustomHills(sortby,CupHills,HillOrder,SetFile);
     end;
 2 : begin
      for temp:=0 to 4 do
       HillOrder[temp]:=temp+8;
      CupHills:=4;
      sortby:=1;
     end;
 end;

 if (CupHills=0) then CupSlut:=true;

 ch:=#1;

 repeat

    inc(osakilpailu);

    fourhills:=false; dokosystem:=false; { saadaan yhteen muuttujaan se }
    if (cupstyle=2) or ((cupstyle=0) and (osakilpailu>8) and (osakilpailu<13)) then fourhills:=true;
    if (fourhills) and (kosystem) then dokosystem:=true;

    nytmaki:=HillOrder[osakilpailu];

    Tuuli.Alusta(windplace);
    jumpalku;

    kierros:=0;

    for temp:=1 to NumPl do                 { uusi skaba alkaa, v„hennet„„n inj }
     if (inj[temp]>0) then dec(inj[temp]);

    jarjestys(sortby,0,Numpl); { tehd„„n eka j„rkk„ mcluettiin }

     for temp:=0 to NumPl do qual[temp]:=0;

     if (osakilpailu>1) then
      for temp:=1 to NumPl do    { suoraan MC pisteill„ sis„„n }
       if (sija[temp]<11) and (inj[temp]=0) then
        begin             { and (inj[temp]<2 }
         qual[temp]:=2;
         inc(qual[0]);
        end;

      eka:=true;

      { TRAINING ROUNDS (kierros-1,-2,-3) }

     if (not CupSlut) and (trainrounds>0) then

       for temp:=1 to trainrounds do
        begin

         kierros:=-temp;

         for index:=NumPl downto 1 do
          if (inj[mcluett[index]]=0) then  { onko loukkaantunut? }
            if (not cupslut) then
             begin
              hyppy(index,mcluett[index],0);
              eka:=false;
             end;

        end;
     if not (cupstyle=1) then  { v3.13 - customissa skipataan quali }
     begin

          kierros:=0;

          { QUAL ROUND  kierros:=0; }

          if (not CupSlut) then { NEW! }
             for index:=NumPl downto 1 do
                 begin
                 skip:=false;
                 if (mcluett[index] > NumPl-pmaara) then
                 begin
                      skipquali:=Profile[profileorder[Numpl+1-mcluett[index]]].skipquali;
                      if (skipquali=2) or ((not fourhills) and (skipquali=1)) then skip:=true;
                 end;

                 if (inj[mcluett[index]]=0) and (not cupslut) then
                 if not ((mcluett[index] > NumPl-pmaara) and (skip) and
                    (qual[mcluett[index]] > 0)) then  { skipquali mahis }
                 begin
                   hyppy(index,mcluett[index],0);
                   eka:=false;
                 end;
        end;

        jarjestys(2,1,Numpl);

        if (not cupslut) and (osakilpailu>1) then { ei eka kisa }
        begin
             temp2:=1;

             for temp:=1 to 50-qual[0] do  { yleens„ 30 }
             begin
                 while ((qual[luett[temp2]]>0) or (inj[luett[temp2]]<>0)) and (temp2<NumPl) do inc(temp2);
                 qual[luett[temp2]]:=1;
             end;

             if (not dokosystem) then { ko systeemiss„ tarvitaan tasan 50. }
                for temp:=51-qual[0] to NumPl do
                    if (sija[luett[temp]]=sija[luett[temp2]]) and (inj[luett[temp]]=0) then qual[luett[temp]]:=1;

        end else
        begin { * eka kerta * }

              if (dokosystem) then
              begin
                   for temp:=1 to 50 do
                       qual[luett[temp]]:=3; { vain tasan 50 tarvitaan KO systeemiin }
              end else
                  for temp:=1 to NumPl do    { 50 parasta qualifieria, ei v„li„ vaikka loukkaant. }
                      if (sija[temp]<51) then qual[temp]:=1;

       end;

{       for a:=50 to NumPl do
        if (sija[luett[a] }

{      for a:=1 to NumPl do luett[a]:=0; }

      temp2:=1;

      if (dokosystem) then
       for temp:=1 to 50 do { pit„isi tehd„ parit }
        begin
         while (qual[luett[temp2]]=0) and (temp2<NumPl) do inc(temp2);
         qual[luett[temp2]]:=temp; { qualista tulikin l„ht”j„rjestysnumero }
         inc(temp2);
        end;

      if (not cupslut) then { karsinnan tulokset }
       begin
        jarjestys(2,1,NumPl);
        lista(0);
       end;

      if (not cupslut) and (dokosystem) then
       begin
        for temp:=1 to NumPl do   { tehd„„n l„ht”j„rjestyslista }
         luett[qual[temp]]:=temp;
        showpairs(0);
       end;


     end { cupstyle <> 1 }
     else
     begin
          for temp:=1 to NumPl do qual[temp]:=1;
     end;

     for temp:=0 to NumPl do
      pisteet[temp]:=0;

     for temp:=1 to NumPl do
      if (qual[temp]=0) then pisteet[temp]:=-5555;  { pistet„„n niille niin huonot pisteet ettei ne kummittele }

      kierros:=1;

     if (dokosystem) then                  { *** 1. KIERROS *** }
      for temp:=25 downto 1 do
       for temp2:=0 to 1 do
        begin
         index:=51-temp;
         if (temp2=1) then index:=temp;

         if (inj[luett[index]]=0) and (not cupslut) then
          begin
           hyppy(index,luett[index],0);
           eka:=false;
          end;

       end else
      for index:=NumPl downto 1 do
       if (qual[mcluett[index]]>0) and (inj[mcluett[index]]=0) and (not cupslut) then
        begin
         hyppy(index,mcluett[index],0);
         eka:=false;
        end;

    if (not dokosystem) and (not cupslut) then { 1. kierroksen tulokset }
     begin
      jarjestys(2,1,NumPl);
      updatestats(1);
      lista(1);
     end;

     for temp:=0 to NumPl do qual[temp]:=0;

    if (not dokosystem) then { tavallinen }
     begin
      for temp:=1 to NumPl do
      if (sija[temp]<31) then qual[temp]:=1; { n„m„ ovat luettelon j„lkeen, ett„ siell„ tiedet„„n koska hypp„„j„t loppuu }
     end else
      begin                 { ko system }
       for temp:=25 downto 1 do
        if (pisteet[luett[temp]] >= pisteet[luett[51-temp]]) then
         qual[luett[temp]]:=1 else qual[luett[51-temp]]:=1;
       for temp:=1 to NumPl do
        mcluett[temp]:=luett[temp]; { laitetaan talteen l„ht”j„rjestys }

       jarjestys(2,1,NumPl); { tehd„„n pisteist„ j„rkk„ }
       temp2:=1;
       for temp:=1 to 5 do     { 5 lucky loseria }
        begin
         while (qual[luett[temp2]]<>0) and (temp2<NumPl) do inc(temp2);
         qual[luett[temp2]]:=2;
        end;

       for temp:=1 to NumPl do
        luett[temp]:=mcluett[temp]; { palautetaan l„ht”j„rjestys }

       if (not cupslut) then showpairs(1);

       jarjestys(0,0,Numpl); { ett„ mcliivi on oikealla miehell„ }
       jarjestys(2,1,NumPl); { taas pisteist„ j„rkk„ n„et toinen kierros normaali on }

      end;

     kierros:=2;

     if (not cupslut) then        { *** 2. KIERROS *** }
      for index:=NumPl downto 1 do
       if (inj[luett[index]]=0) and (qual[luett[index]]>0) and (not cupslut) then
        begin
         hyppy(index,luett[index],0);
         eka:=false;
        end;

      ch:=#1; { ettei hypyn keskeytt„minen sotke liikaa }
{
      for temp:=1 to pmaara do
       if (sija[NumPl+1-temp]>30) then stats[temp,osakilpailu].Reason[2]:=4;}  { Ei selvinnyt tokalle }

         eka:=true;

    if (cupstyle>0) or (fourhills) then
     for temp:=1 to NumPl do { custom tai fourhills }
      if (pisteet[temp]<>-5555) then inc(fourpts[temp],pisteet[temp]);

    if (not cupslut) then { 2.kierros tulokset }
     begin
      jarjestys(2,1,NumPl);
      updatestats(1);
      lista(2);
     end;

    if (not cupslut) and (sortby=0) then { MC tulokset, jos niist„ kisataan }
     begin

      for temp:=1 to NumPl do
       if (sija[temp]<31) then inc(mcpisteet[temp],WCPoints[sija[temp]]);

      jarjestys(0,0,NumPl);
      updatestats(0);
      lista(4);

     end;

{     for temp:=1 to NumPl do
       if (inj[temp]>0) then dec(inj[temp]); }

    for temp:=0 to NumPl+1 do luett[temp]:=0;

    for temp:=1 to NumPl do if (pisteet[temp]=-5555) then pisteet[temp]:=0;

    if (not cupslut) and ((sortby=1) or (fourhills)) then { ja yhteispiste tulokset }
     begin
      jarjestys(1,1,NumPl);
      updatestats(2);
      lista(3);
     end;

    updaterecords(sortby); { enn„tystauluja jos tarvis }

  until (osakilpailu=CupHills) or (Ch=#27) or (cupslut);

  mcpisteet[15]:=0;  { ????? mik„ 15? }

  wcup:=false;

  { testing alleolevia! }

  WriteProfiles;
  WriteRecords;
  MakeSendMe;

end;





procedure CheckParam;
var str1 : string;
begin

 str1:=paramstr(1);

 if (length(str1) > 1) then
 begin
   case str1[2] of
  { 'x' : ex:=true; }
  { 't' : StartTest; }
   'r' : ResetHiscore(1);
   'z' : ResetHiscore(0);
   'c' : ResetConfig;
   end;
 end;

end;


procedure drawfullmain;
begin
 drawmainmenu;

{$IFDEF REG}
  newregtext(regname,regnumber);
{$ELSE}
  newunregtext;
{$ENDIF}

end;

procedure JumpMenu;
var index : integer;

begin

 index:=1;

 repeat

  MainMenuText(1,version_full);

  index:=MakeMenu(11,97,108,12,6,index,8,4,0);

  case (index) of
   1 : begin cupstyle:=0; cup; end;
   2 : begin cupstyle:=1; cup; end;
   3 : begin cupstyle:=2; cup; end;
{$IFDEF REG}
   4 : teamcup;
{$ENDIF}
   5 : newkingofthehill;
   6 : training;
  end;

  if (index<>0) then drawfullmain;

 until (index=0);

end;


procedure MainMenu;
var index : integer;

begin

 AsetaMoodi($13);
 FillBox(0,0,319,199,0);

 index:=1;

 if (languagenumber=255){  or (random(2)=0) } then
  begin
   WelcomeScreen(languagenumber);
   Replays(true,version,gdetail);
  end;

{  TestAnims;

  Halt; }

 repeat

  drawfullmain;

  MainMenuText(0,version_full);

{  index:=MakeMenu(30,69,110,10,8,index,243,0,6); }

  index:=MakeMenu(11,97,108,12,6,index,8,4,2);

  case index of
   1 : jumpmenu;
   2 : { signupplayers; }
       begin
        LoadNames(namenumber,jmaara,TeamLineup,false);
        profiles;
        if (pmaara=8) then jmaara:=2 else jmaara:=1;
         jnimet[NumTeams-1]:='Team 2';
        LoadNames(namenumber,jmaara,TeamLineup,true);
       end;
   3 : setupmenu;
   4 : showtops(0);
   5 : if (NumExtraHills>0) then showtops(1)
                            else showtops(2);
   6 : replays(false,version,gdetail);

{    testanims; }

{   1 : begin justfourhills:=false; cup; end;
   2 : begin justfourhills:=true; cup; end;
   3 : teamcup;
   4 : newkingofthehill;
   5 : training;
   6 : signupplayers;
   7 : setupmenu;
   8 : showtops; }
  end; { case }

  if (index=0) then index:=quitting(0);

 until (index=0);

{ TestAnims; }

 AsetaMoodi($3);

{ Textmode(CO80); }

{  for a:=1 to 50 do write(index,' '); }

{  readln; }

end;




procedure alku;
begin

 writeln('Ported to SDL2 by Suomipelit (https://suomipelit.github.io)');
 writeln('');
 writeln('New shortkeys:');
 writeln(' * Alt+Enter          : Toggle fullscreen');
 writeln(' * Alt+(Keypad) Plus  : Increase window size');
 writeln(' * Alt+(Keypad) Minus : Decrease window size');
 writeln(' * Alt+R              : Reset window if stretched');
 writeln(' * Alt+A              : Toggle 4:3 aspect ratio');
 writeln('');
 writeln('-------');
 writeln('');
 writeln('SJ3 v',version,' by Ville Könönen 2011');

 write('- Loading ANIM.SKI');
  LoadAnim('ANIM.SKI');

(*
  for temp:=1 to MaxOwnPl do
   haalarit[temp]:=temp mod 7; { hyppypuvun v„ri kaikille erilainen }
*)

  eka:=true;

   jcup:=false;
   wcup:=false;
   koth:=false;
   cupstyle:=0;

   CheckParam;

 write(', HISCORE.SKI');
  ReadRecords;

 write(', CONFIG.SKI');
  ReadConfig;

 write(', PLAYERS.SKI');
  LoadProfiles;

 writeln(', NAMES',namenumber,'.SKI');
  LoadNames(namenumber,jmaara,TeamLineup,true);

{ write(', TEAMS',teamnumber,'.SKI');
   LoadTeams(teamnumber,jmaara,NumTeams,Jnimet); }

 write('  LANGBASE.SKI');
  if (languagenumber<>255) then LoadLanguage(languagenumber);

{
  writeln('Kieli: ',lnames[1]);  writeln('Kieli„: ',numlanguages);
  for a:=1 to 15 do
   writeln(lstr(temp));
  readln;
}

 CheckExtraHills; { lukee ylim. SJH:t ja kirjoittaa MOREHILL.SKI:n }

 write(', MOREHILL.SKI');
 LoadHillInfo; { mnimet[],kri[] ja NumExtraHills kuntoon }

 write(', Extra Hillrecords');
 if (NumExtraHills>0) then ReadExtras;

 Maki.Alusta;

(*
 SetFile:='TEMP'; { custom setin tiedosto }
*)

{ LoadFonts; }
{ tuuli:=-70;}

end;

procedure loppu;
begin

 writeln('SJ3 v',version,' by Ville Könönen 2013');

 GetNow(Now);

 write('- Writing HISCORE.SKI');
 WriteRecords;

 write(', CONFIG.SKI');
 WriteConfig;

 write(', PLAYERS.SKI');
 WriteProfiles;

 if (NumExtraHills>0) then
  begin
   write(', Extra Hillrecords');
   WriteExtras;
  end;

 putsaa;

 MakeSendMe;

 write(', SENDME.TXT.');

 textbackground(0);
 clrscr;

  DoWindow(1,2,80,14,7);
{$IFDEF REG}
 regendtext(regname,regnumber);
{$ELSE}
 unregendtext;
{$ENDIF}

 lopputext(version_full,Start,Now);

 repeat
  SdlPort.Wait(10);
 until Crt.KeyPressed

end;

procedure Close;
begin
  SDLPort.DeinitGraphics;

  Loppu;

  SDLPort.Deinit;
end;

procedure CloseAndHalt;
begin
  Close;
  Halt;
end;

begin  { MAIN }

 sj3lang.Init;
 sj3list.Init;
 sj3unit.Init;
 tuuli.Init;
 sj3info.Init;
 lumi.Init;

 randomize;

 getdate(Today.Year,Today.Month,Today.Day,Today.DayofWeek);
 getnow(start);

 version:='3.13';
 version_full:=version+'-'+SdlPort.GetVersion;

(* ex:=true;    { expert-mode } *)

{$IFDEF REG}
 reg:=true;   { registered wai no }
{$ELSE}
 reg:=false;
{$ENDIF}

{  reg:=boolean(random(2)); }

{ if (paramstr(1)='U') then reg:=false; }

{ regname:='THIS IS A PRIVATE VERSION';
  regnumber:='1234A'; }

 SDLPort.Init;
 SDLPort.SetCloseCallback(CloseAndHalt);

 alku;

{
  Init;
  LoadSounds;
  SetSamplingrate(13000);  }

{  boole:=StartSound(Sound[0],0,True); }

{ ResetHiscore(1); }

  MainMenu;

{  Valikko; }

  Close;

(*
  CloseFont;  { vapautetaan niiden k„ytt„m„ muisti }
  CloseAnim; *)

(*  freemem(p,65528); *)

{   StopSound(0); }

{  ShutDown;

  FreeSounds;   }

{ for a:=232 to 239 do
  begin
   write(paletti[a,0]:4);
   write(paletti[a,0]:4);
   writeln(paletti[a,0]:4);
  end; }

end.
