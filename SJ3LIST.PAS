Unit SJ3List;

interface

type Res_type = record
      Pos, Who : integer;
      Name : string[30];
      Pts, Len1, Len2 : integer;
     end;

procedure Init;
procedure ResetList(omat,kaikki,tyyli:integer;header:string;inv:boolean);
{procedure ResetList(omat,kaikki,tyyli:integer;header:string); }

{function wisekey(num:integer):integer; }
{function wisekey(phase:byte):byte;}
{procedure Entry(Pos, Who:integer; Name:string; Pts, Len1, Len2:integer;Extra:string); }
function Entry(Num, Pos, Who:integer; Name:string; Pts:longint; Len1, Len2:integer;Extra:string):integer;

{function whatnow(num:integer;state:byte):integer;}

implementation

uses sj3unit, sj3graph, sj3help, sj3pcx, sj3lang, sdlport;

var X,Y,LastPos,Page, Plus, OwnPlayers, Players, Phase : integer;
    columns : byte;
    setcol1,setcol2,setcol3 : byte;
    status : integer;
    InvBack, { FirstEntry, }FirstPage : boolean;
    HeaderStr : string;

{
const column : array[1..5] of integer =
      (15,20,125,130,160);
}
const columnX : array[1..2,1..6] of integer =
      ((24,32,184,199,252,275),
{      (19,23,144,145,150,0)); ? }
{      (19,23,148,149,150,0)); v3.10 }
      (19,23,153,154,155,0));
      startY : integer = 23;

function pluspossibility:integer;
var temp : integer;
begin

 temp:=170 div (players+2);

 if (temp<6) then temp:=6;
 if (temp>12) then temp:=12;

 pluspossibility:=temp;

end;

procedure NewPage;
var color : byte;

begin

 case phase of
 0 : begin   { Quali }
      columns:=1;
      plus:=7;
      color:=0;
     end;

 1 : begin   { Scoreboard }
      columns:=1;
      plus:=8;
      color:=0;
     end;

 2 : begin   { 4hills }
      columns:=2;
      plus:=8;
      color:=4;
     end;

 3 : begin     { WCStandings }
      columns:=2;
      plus:=8;
      color:=3;
     end;

 4 : begin   { king of the hill }
      columns:=1;
{      plus:=pluspossibility; }
       plus:=8;
      color:=2;
      setcol3:=246; { ei turkoosia t„nne }
     end;

 5 : begin     { Team Cup Standings }
      columns:=1;
      plus:=10;
      color:=1;
     end;

 6 : begin     { Team Cup WC standings }
      columns:=1;
      plus:=10;
      color:=3;
     end;

 7 : begin     { Stats screens (kokeilu) }
      columns:=1;
      plus:=200; { vaikuttaa paljon! }
      color:=5;
     end;

 end; {case}

 if (phase>=0) then
  begin

   if (InvBack) then { tota pit„„ tsiigata viel„... }
    begin

     DrawHillScreen;

    if (FirstPage) then
     begin
      SiirraStandardiPaletti;
      TallennaAlkuosa(0);
      SavytaPaletti(0,40);
      AsetaPaletti;
      FirstPage:=False;
     end;

     DrawAnim(5,2,62); { logo kehiin }

    end
     else NewScreen(1,color);

{   NewScreen(1,color); }

   fontcolor(240);
   writefont(30,6,HeaderStr);

  end;

 LastPos:=0;
{ FirstEntry:=True; }

end;


procedure ResetList(omat,kaikki,tyyli:integer;header:string;inv:boolean);
{procedure ResetList(omat,kaikki,tyyli:integer;header:string); }
begin

 X:=0;
 Y:=startY;
{ LastPos:=0; }
 OwnPlayers:=omat;
 Players:=kaikki;
 Phase:=tyyli;
 HeaderStr:=header;

 InvBack:=inv;

 FirstPage:=True;

 Page:=1;
 Plus:=7;

 setcol1:=240;
 setcol2:=246;
 setcol3:=247;

 columns:=1;   { montako saraketta per sivu }

 NewPage;

end;


procedure WaitForKey(from:byte); { 0 - LEAVING, 1 - PAGE_END }
var { tempch, tempch2:char; }

    temp : integer;
    good : boolean;
    str1 : string;

begin

 fontcolor(241);

  if (page>1) then ewritefont(319,5,'(-'+lstr(246));

 str1:=lstr(247);
 if (from=0) then str1:=lstr(248);

{
 writefont(250,1,'FR'+txt(from));
 writefont(250,7,'ST'+txt(status));
 writefont(250,13,'PG'+txt(page)); }

  ewritefont(319,13,str1+'-)');

 DrawScreen;

 repeat

  temp:=status;
  if (from=0) then temp:=-1;

  good:=false;

  SDLPort.WaitForKeyPress(ch,ch2);

  case ch of
  #13, #27 : begin status:=-1; good:=true; end;

  ' ' : begin inc(page); status:=temp; good:=true; end;

  #3 : begin status:=-2; good:=true; end; { CTRL-C }

  end; { case }

  if (ch=#0) then
  case ch2 of
  #68, #45 : begin status:=-2; good:=true; end; { F10, ALT-X }


  #77,#81 : begin inc(page); status:=temp; good:=true; end; { PgDn, A_Right }

  #71 : if (page>1) then { HOME }
         begin
          page:=1;
          status:=0;
          good:=true;
         end;

  #73,#75 : if (page>1) then { PgUp, A_Left }
              begin
               dec(page);
               case phase of
                0 : status:=(page-1)*25;
                1,4 : status:=(page-1)*22;
(*                1 : case page of
                    1 : status:=0;
                    2 : status:=22;
                    3 : status:=42; { ei tarvita, mutta olkoon }
                    end; *)
                2,3 : status:=(page-1)*44;
                7 : status:=page-1;
               end; { case }
               good:=true;
              end;

  end; { case }

 until (good);

 if (ch=#27) and (phase=3) then
  begin
   if (quitting(1)=0) then status:=-2 else ch:=#1;
  end;

 if (status>=0) then { we need a new screen }
  begin
   y:=startY;
   x:=0;
   NewPage;
  end;

end;


procedure addy(amount:integer);
begin

 if (amount=0) then inc(y,plus) else inc(y,amount);

 if (y>191) then { s„„d„ t„„!!! 192jees? }
  if (columns=2) and (x=0) then { nyy kolumni }
   begin
    y:=startY;
    x:=160;
   end else
    begin  { we want new page }

     WaitforKey(1);

    end;
end;



{procedure Entry(Pos, Who:integer; Name:string; Pts, Len1, Len2:integer;Extra:string); }
function Entry(Num, Pos, Who:integer; Name:string; Pts:longint; Len1, Len2:integer;Extra:string):integer;

var col1, col2, col3 : byte;
    str1 : string;
    slen1,slen2 : string[5];
    temp : integer;
begin

 col1:=241; col2:=setcol2+5; col3:=setcol3+5;

 if (Who > Players-OwnPlayers) then { meid„n j„tki„ }
  begin
   col1:=setcol1;
   col2:=setcol2;
   col3:=setcol3;
  end;

{
 if (extra[1]='K') then
  begin
   col1:=setcol1;
   col2:=setcol1;
   col3:=setcol3;
  end; }

 fontcolor(col1);

 status:=Num;

 if (Pos>0) then
  begin

   fontcolor(col2);

{   ewritefont(x+columnX[columns,1],y,txt(Num)+' '+txt(Pos)+'.'); }

   if (Pos <> LastPos) then
    ewritefont(x+columnX[columns,1],y,txt(Pos)+'.');

   LastPos:=Pos;

{     else
      if (FirstEntry) then
       begin
        fontcolor(241);
        ewritefont(x+columnX[columns,1],y,txt(Pos)+'.')
       end; }

{   FirstEntry:=False; }

   fontcolor(col1);

   if (columns=2) then Name:=nsh(Name,98);
   if (columns=1) then Name:=nsh(Name,122);

    writefont(x+columnX[columns,2],y,Name);

   fontcolor(col1);

   str1:=txtp(Pts);

   case phase of
   3,6 : str1:=txt(Pts);
   end;

   ewritefont(x+columnX[columns,3],y,str1);

   slen1:=txtp(Len1); while (length(slen1) < 5) do slen1:='$'+slen1;
   slen2:=txtp(Len2); while (length(slen2) < 5) do slen2:='$'+slen2;

   if (Len1 = 0) then str1:='' else
   if (Len2 = 0) then str1:='('+slen1+'«)'
                     else str1:='('+slen1+'-'+slen2+'«)';

   if (str1<>'') then
    begin
     fontcolor(col3);
     writefont(x+columnX[columns,4],y,str1);
    end;

   if (extra<>'') then
    for temp:=1 to length(extra) do
     begin
      case extra[temp] of
      'Q' : begin
             fontcolor(col2);
             writefont(x+columnX[columns,5],y,'Q');
            end;
      'W' : begin
             fontcolor(col3);
             writefont(x+columnX[columns,5],y,'Q WC');
            end;
      'I' : begin
             fontcolor(249);
             str1:=copy(extra,temp+1,length(extra)-temp+1);
             writefont(x+columnX[columns,6],y,'INJ-'+str1);
            end;
      'K' : begin
             fontcolor(col2);
             writefont(x+columnX[columns,6],y,lstr(143));
            end;
      'R' : begin
             fontcolor(col2);
             writefont(x+columnX[columns,6],y,'HR!');
            end;

      end; { case }

     end;

{     fontcolor(240);
   writefont(x+columnX[columns,6],y,extra); }

   if (extra[1]='L') then WaitforKey(0) else AddY(0);
       { LAST! }

  end else
   begin  { v„lihuomautus (ei nimi) tai muu s„hly }

    if (extra[1]='L') then WaitforKey(0) { tekosyy p„„st„ pois }
     else
      begin { tavallinen v„lihuomautus }

       if (Who>0) then Addy(plus div 2);

       if (status>=0) then { ei ole pois l„hd”ss„ }
        begin
         fontcolor(246);
         writefont(x+columnX[columns,2],y,Name);

         AddY(0);

         if (Who>1) and (status>=0) then AddY(plus div 2);

        end;
      end;
   end;

 if (Status>=0) then inc(status)
                else begin { pois l„hd”ss„ listalta }

                      if (invback) then
                       begin
                        TakaisinAlkuosa(0);
                        { SavytaPaletti(0,250); }
                        AsetaPaletti;
                       end;

                      FirstPage:=True;

                     end;

 Entry:=Status;

end;

procedure Init;
begin
 ResetList(1,NumPl,-1,'',FALSE);
end;

end.




