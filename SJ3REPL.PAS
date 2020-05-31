Unit SJ3Repl;

interface

procedure replays(start:boolean;version:string;gdetail:byte);

implementation

uses {crt,} WinDos,SJ3Unit, SJ3info, SJ3Help, SJ3PCX, SJ3Graph, Tuuli, Maki, Lumi, SJ3lang;


procedure replays;
var filenames : array[0..500] of string[12];
    numreplays : integer;
    f1 : text;
    oldindex, temp, index : integer;
{    tempch,tempch2 : char; }
    intro:boolean;

    result : byte;

    Acthill : hill_type;

    StartX, StartY, MaxTurns, Nytmaki,
    Lmaara, Realhp, FLStart, FLStop, HRx, HRy, startgate : integer;
    suitcolor, skicolor : byte;
    Author, Name : NameStr;
    When : TimeStr;
    HillFilename : string[12];
    laskuri,check,mycheck : longint;
    RD : array[0..4,0..1000] of byte;
    mcliivi : boolean;

{    TempVideo : EPtr; }


 procedure playreplay;
 var temp, JumperAnim, SkiAnim, hp : integer;
     wind, Rturns : integer;
     Mode, OldMode : integer;
     speed : byte;
     place : word;
     move : shortint;

     str1 : string;

     x, y, fx, fy, sx, sy, deltax, deltay : integer;
     keulax, keulay : integer;

     kr : integer;

     XY : array[0..1,0..1000] of integer;
{     ch, ch2 : char; }

  function txts(phase:byte):string;
  var str1 : string;
  begin
   str1:=lstr(343);
   case phase of
   1 : str1:='50%';
   2 : str1:='75%';
   3 : str1:='100%';
   4 : str1:='150%';
   5 : str1:='200%';
   end;

   txts:=str1;
  end;

  procedure introbox(phase:byte);
  var ix,iy : integer;
   {   newch, newch2 : char; }
  begin

   ix:=30;
   iy:=30;

   case phase of
   0,1,2,3 : iy:=140;
   end;

{   fillbox(ix-3,iy-4,ix+245,iy+35,254); }
   fillbox(ix-7,iy-7,ix+261,iy+32,248);
   fillbox(ix-6,iy-6,ix+260,iy+31,243);
{   fillarea(ix-6,iy-6,ix+260,iy+31,63); }

   fontcolor(246);
   writefont(ix,iy,lstr(360+phase*2));
   writefont(ix,iy+10,lstr(361+phase*2));

   waitforkey3(ix+246,iy+21,ch);

  end;

 begin

 if (IOResult=0) then
  begin

   { LoadInfo(nytmaki,ActHill); }

   kr:=acthill.kr;

   ch:=#1;

   X:=StartX;
   Y:=StartY;

   for temp:=0 to MaxTurns do
    begin
     X:=X+RD[0,temp]-128;
     Y:=Y+RD[1,temp]-128;
     XY[0,temp]:=X;
     XY[1,temp]:=Y;
    end;

   Speed:=3; { normaali nopeus }
   Place:=0;
   RTurns:=0;

   Mode:=3; { 0 - pause, 1 - play fwd, 2 - play rew,
              3 - play once then pause
              4 - thru once (speed change)
              5 - one step forward }

{   LStyle:=Random(2)*Random(2);
   LStyle:=1; }

   if (gdetail=1) then LMaara:=0;

   VieLmaara(Lmaara);

   if (intro) then mode:=1;

   LoadHill(temp,nytmaki,Acthill);

   Maki.X:=0;
   Maki.Y:=0;

   DrawHillScreen;

   SiirraStandardiPaletti;
   if (LMaara>1000) then TummaLumi;

   Loadsuit(suitcolor,0);
   Loadskis(skicolor,0);

   if (not mcliivi) then SiirraLiiviPois;

   MuutaReplay(mode);

   AsetaPaletti;

   sx:=0; sy:=0; fx:=0; fy:=0;

   KeulaX:=XY[0,FLStart];
   KeulaY:=XY[1,FLStart];

   X:=StartX;
   Y:=StartY;
   JumperAnim:=RD[2,RTurns];
   SkiAnim:=RD[3,RTurns];
   Wind:=RD[4,RTurns]-128;

   repeat { replayluuppi }

    if (mode>0) then
     begin

      fx:=x;
      fy:=y;

      ch:=#1; ch2:=#1;

{      temp:=0;

      case mode of
      1 : temp:=1;
      2 : temp:=-1;
      end;

      X:=X+temp*(RD[0,RTurns]-128);
      Y:=Y+temp*(RD[1,RTurns]-128); }

      if (intro) then
       case Rturns of
         1 : begin introbox(0); introbox(1); introbox(2); end;
       100 : introbox(3);
       223 : introbox(4);
       257 : introbox(5);
       420 : introbox(6);
       550 : begin introbox(7); introbox(8); introbox(9); end;
       822 : begin introbox(10); ch:=#27; end;
       end;

      X:=XY[0,RTurns];
      Y:=XY[1,RTurns];

      JumperAnim:=RD[2,RTurns];
      SkiAnim:=RD[3,RTurns];
      Wind:=RD[4,RTurns]-128;

      DeltaX:=Maki.X;
      DeltaY:=Maki.Y;

      if (x>=160) and (x<864) then sx:=x-160;
      if (y>=100) and (y<412) then sy:=y-100;

      Maki.X:=sx;
      Maki.Y:=sy;

      if (Maki.X>704) then Maki.X:=704;
      if (Maki.Y>312) then Maki.Y:=312;
      if (Maki.X<0) then Maki.X:=0;
      if (Maki.Y<0) then Maki.Y:=0;

      Maki.Tulosta;

      DrawLumi(DeltaX-Maki.X,DeltaY-Maki.Y,Tuuli.Value,LMaara,true);

      if (hrx>0) then DrawAnim(hrx-Maki.X,hry-Maki.Y,68); { m„kienkkakeppi }

      DrawAnim(x-Maki.X,y-Maki.Y-2,JumperAnim);
      DrawAnim(x-Maki.X,y-Maki.Y-1,SkiAnim);

{       EWritefont(308,69,'RTURNS '+txt(RTurns)); }

      if (not intro) then
       begin

        DrawAnim(227,2,64);

        Fontcolor(246);

        if { (mode=3) or } (rturns mod 30 > 15) then
         writefont(2,2,'R');

        FontColor(240);


        EWritefont(308,9,acthill.name+' K'+txt(acthill.kr));
        EWritefont(308,19,author);
{        Ewritefont(308,29,when); }


 {       EWritefont(308,29,'MTURNS '+txt(MaxTurns)); }

        DrawAnim(150,30,69);
{        DrawAnim(250,62,70); }

{        temp:=mode;  }

       if (mode<>oldmode) then MuutaReplay(mode);

        str1:='0.00'; hp:=0;

       if (Rturns>FLstart) then
        begin
         hp:=round(nsqrt(sqr(longint(X-KeulaX))+sqr(longint(Y-KeulaY)))*acthill.pk*0.5)*5;
         temp:=Rturns-FLstart;
         if (Rturns>FlStop) then
          begin
           temp:=FlStop-FLstart;
           hp:=realhp;
          end;
         str(round(temp*10/7),str1);

         while (length(str1) < 3) do str1:='0'+str1;
         insert('.',str1,length(str1)-1);

{    hp:=round(nsqrt((matka*matka)+(kkor*kkor))*acthill.pk*0.5)*5; }
        end;

       Fontcolor(247);

       EWritefont(309,29,lstr(340)+' '+str1);
       EWritefont(309,39,lstr(341)+' '+txtp(hp));
       EWritefont(309,49,lstr(342)+' '+txts(speed));
       str1:='';
       case startgate of
       1..5 : str1:=lstr(26+startgate);
       end;

       if (startgate>10) then str1:=lstr(58)+' '+txt(100-startgate);

       if (str1<>'') then EWritefont(309,59,str1);

{       EWritefont(309,59,txt(mode)); }

      end else Fontcolor(247); { tuulta varten vaan }

      Tuuli.Value:=wind;
      Tuuli.Piirra;

     end;

     if (mode=3) then mode:=0;
{     if (mode>3) then mode:=3; }

     OldMode:=mode;

     if (mode>3) then mode:=3;

     if (keypressed) then
      begin
       readkbd(ch,ch2);
       if {(ch2=#80) or (ch2=#72) or} (upcase(ch)='P') then mode:=3;
       if (ch2=#77) then if (mode=1) then mode:=3 else mode:=1;
       if (ch2=#75) then if (mode=2) then mode:=3 else mode:=2;
       if (ch2=#68) then ch:=#27;

       if (ch=' ') and (mode=0) then mode:=5;

      temp:=speed;
       if ((ch='+') or (ch2=#80)) and (speed<5) then inc(speed);
       if ((ch='-') or (ch2=#72)) and (speed>0) then dec(speed);

       if (temp<>speed) and (mode=0) then mode:=4;

       if (intro) then begin mode:=oldmode; speed:=temp; end;

      end;

     case mode of
{     1 : if (oldmode<>2) then inc(Rturns);
      2 : if (oldmode<>1) then dec(Rturns); }
     1 : if (oldmode<>2) then inc(Place);
     2 : if (oldmode<>1) then inc(Place);
     end;

     move:=0;

     temp:=speed;

     if (speed=0) then { custom speed }
      begin
       temp:=3;
{       if (Rturns > FLStart) then temp:=3; }
       if (abs(Rturns-FlStart) < 40) or
          (abs(Rturns-FlStop) < 40) then temp:=2;
       if (abs(Rturns-FlStart) < 20) { or
          (abs(Rturns-FlStop) < 15) } then temp:=1;
      end;


     case temp of
      1 : move:=byte(place mod 4 = 0);
      2 : move:=place mod 2;
      3 : move:=1;
      4 : move:=1 + place mod 2;
      5 : move:=2;
     end;

     if (place>999) then place:=0;

     case mode of
     1 : inc(Rturns,move);
     2 : dec(Rturns,move);
     5 : inc(Rturns);
     end;

     if (mode=5) then mode:=3; { one step }

     if (Rturns<0) then begin mode:=3; RTurns:=0; end;
     if (Rturns>MaxTurns) then begin mode:=3; RTurns:=MaxTurns; end;

      WaitRaster;

      AsetaPaletti;

      Maki.Paivitaruutu;

   until (ch=#27);

  end;

 clearchs;

end;




 procedure findreplays;
 var DirInfo : TSearchRec;
     Attr : word;
     temp : integer;
 begin

  NumReplays:=0;

  for temp:=0 to 100 do filenames[temp]:='';

  Attr:=0;

  FindFirst('*.SJR', Attr, DirInfo);

   while (DosError = 0) and (NumReplays < 100) do
    begin

     inc(NumReplays);

     temp:=0;

      while (DirInfo.Name[temp]<>'.') do
       begin
        filenames[NumReplays]:=filenames[NumReplays]+DirInfo.Name[temp];
        inc(temp);
       end;

     FindNext(DirInfo);

    end;

   DosError:=0;

 end;

 procedure readreplayinfo;
 var tempch : char; { ok1 }
     temp,temp2 : integer;
 begin

  readln(f1,startx); readln(f1,starty);

  readln(f1,maxturns);
  readln(f1,nytmaki);
  readln(f1,hillfilename);
  readln(f1,laskuri); { profile }
  readln(f1,lmaara);
  readln(f1,realhp);
  readln(f1,FLStart);
  readln(f1,FLStop);
  readln(f1,HRx); readln(f1,HRy);
  readln(f1,suitcolor); readln(f1,skicolor);

  readln(f1,author);
  readln(f1,name);
  readln(f1,when);

  readln(f1,temp);
   mcliivi:=boolean(temp);

  readln(f1,startgate);
  readln(f1,mycheck);

  tempch:=#1;

  while (tempch<>'*') do
   read(f1,tempch);

  for temp:=0 to 1000 do
   for temp2:=0 to 4 do
    begin
     read(f1,tempch);
     RD[temp2,temp]:=byte(tempch);
    end;

  close(f1);

 end;


 function countcheck:longint;
 var temp : longint;
 begin
  temp:=0;
  inc(temp,Startx*2+Starty);
  inc(temp,maxturns*3);
  if (nytmaki<=numwchills) then inc(temp,nytmaki*131);
  inc(temp,valuestr(hillfilename,3)*3);
  inc(temp,Acthill.profile);
  inc(temp,(realhp+2)*69);
  inc(temp,flstart+flstop);
  inc(temp,(HRx+HRy)*2);
  inc(temp,valuestr(author,2));
  inc(temp,startgate*1412);

  countcheck:=temp xor 3675433;
 end;


 procedure clearscreen;
 begin
  fillbox(145,50,319,199,243);
  fillbox(128,70,145,199,243);

  fillarea(128,70,145,199,64);
  fillarea(145,50,319,199,64);

  fontcolor(241);
  writefont(170,51,lstr(25)+':');
  writefont(150,185,lstr(146));
 end;

 procedure noreplays;
 begin
  clearscreen;
  fontcolor(246);
  writefont(170,80,lstr(290));
  getch(177+fontlen(lstr(290)),80,243,ch,ch2);
  DrawScreen;
 end;

{
 procedure savedscreen;
 begin

  move(mem[TempVideo:0],mem[Video:0],64000);
  TakaisinAlkuosa(0);
  SiirraStandardiPaletti;
  SpecialMainPaletti;
   AsetaPaletti;

 end;
}

begin

if (start) then
 begin
  assign(f1,'INTRO.SJR');
  {$I-}
  reset(f1);

  result:=0;

  intro:=true;

  if (IOResult<>0) then result:=1
                   else readreplayinfo;

  {$I+}
  if (result=0) then
   begin
    LoadInfo(nytmaki,Acthill);
    playreplay;
   end;

 end else
  begin

   FindReplays;

   oldindex:=0;


   {
   Alloclarge(TempVideo,64000);
   move(mem[Video:0],mem[TempVideo:0],64000);
   TallennaAlkuosa(0);
   }

   if (NumReplays>0) then
    begin

     index:=1;

     repeat

      if (oldindex<>index) then
       begin

        result:=0; intro:=false;

        assign(f1,filenames[index]+'.SJR');
        {$I-}
        reset(f1);

        if (upstr(filenames[index])='INTRO') then intro:=true;

        if (IOResult<>0) then result:=1
                         else readreplayinfo;

        {$I+}

        if (nytmaki>NumWCHills) and (result=0) then
         begin
          result:=2;
          temp:=0;

          if (NumExtraHills>0) then
           while (temp<NumExtraHills) do
            begin
             inc(temp);
             if (hillfile(temp) = hillfilename) then
              begin
               LoadInfo(temp+NumWCHills,Acthill);
               if (Acthill.profile = laskuri) then
                begin
                 temp:=NumExtraHills+1;
                 result:=0;
                end;
              end;
            end;
         end else if (result=0) then LoadInfo(nytmaki,Acthill);

        if (countcheck<>mycheck) then result:=3;

        if (result<>0) then
         begin
          author:='Unknown';
          name:='Not a valid replay.';
          when:='-';
          acthill.name:='?';
          case result of
          1 : acthill.name:='File didn''t open.';
          2 : acthill.name:='Extra Hill Not Found.';
          3 : acthill.name:='Checksum mismatch.';
          end;

          acthill.kr:=-1;
         end;

        clearscreen;

        writefont(272,85,txt(index)+'/'+txt(numreplays));

        writefont(150,106,lstr(291));
        writefont(150,126,lstr(292));
        writefont(150,146,lstr(294));
        writefont(150,71,lstr(293));
        writefont(170,163,when);

        if (acthill.kr > 0) then fontcolor(246)
                            else fontcolor(241);

        fillbox(163,78,257,98,248);
        fillbox(164,79,256,97,243);
        writefont(170,85,filenames[index]);
        fontcolor(240);
        writefont(170,115,author);
        writefont(170,135,name);
        if (acthill.kr > 0) then writefont(170,155,acthill.name+' K'+txt(acthill.kr))
                            else writefont(170,155,acthill.name);
{        writefont(170,168,txt(countcheck));
        writefont(170,173,txt(mycheck)); }

        drawscreen;

       end;

      ch:=#1; ch2:=#1; oldindex:=index;

      readkbd(ch,ch2);

      if (ch2=#77) or (ch2=#80) or (ch=' ') or (ch='+') then inc(index);
      if (ch2=#75) or (ch2=#72) or (ch='-') then dec(index);
      if (ch2=#68) then ch:=#27;

      if (ch=#13) and (result=0) then
       begin
        playreplay;
        oldindex:=0; { piirt„„ ruudun uudestaan sitten }
        drawmainmenu;
        mainmenutext(0,version);
        { savedscreen; }
       end;

      if (ch2=#83) then { delete! }
       begin
        if (mightdelete(filenames[index]+'.SJR') = 0) then
         begin
          FindReplays;
         end;
         ch:=#1;
         oldindex:=0;
         drawmainmenu;
         mainmenutext(0,version);

         if (numreplays=0) then
          begin
           noreplays;
           ch:=#27;
          end;
       end;

      if (index<1) then index:=NumReplays;
      if (index>NumReplays) then index:=1;

     until (ch=#27);

    end else
     begin
      noreplays;

     end;

  { freemem(TempVideo,64000); }
 end;

end;













begin


end.