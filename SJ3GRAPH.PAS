unit SJ3Graph; { SJ3:n grafiikkarutiineja }

interface

Procedure DrawScreen;
Procedure DrawHillScreen;
{procedure Splitscreen(korkeus:byte); }
procedure CloseGraph;
procedure Sprite(SpriteData:array of byte;X,Y:Word);
procedure DrawAnim(x,y:integer;num:byte);
procedure LoadAnim(filename:string);
procedure PutPixel(x,y,c:integer);
{procedure PutGPixel(x,y:integer;c:byte); }
{function GetPixel(x,y:integer):byte; }
function GetPixel(x,y:word):byte;

procedure EWriteFont(xx,yy:integer;s:string);
procedure WriteFont(xx,yy:integer;s:string);
function FontLen(s:string):word;
procedure fontcolor(col:byte);

Procedure FillArea(x1,y1,x2,y2:word;thing:integer);

procedure Fillbox(x,y,x2,y2:word;col:byte);
procedure Box(x,y,x2,y2:word;col:byte);
procedure Balk(st:byte);
procedure NewScreen(style,color:byte);
procedure alertbox;
procedure WriteVideo;

{ procedure angle(x,y,a,b,c:integer); }

function NumofAnims:byte;


implementation

uses Maki, SJ3PCX, SJ3Help, SDLPort;

var Anim : array[0..200] of array of byte;
    AnimP : array[0..200,0..1] of byte;
    NumAnim : byte;

function NumofAnims:byte;
begin
 NumofAnims:=NumAnim;
end;

Procedure DrawScreen;
begin
 SdlPort.WaitRaster;
 SdlPort.Render(Video);
end;

Procedure DrawHillScreen;
begin

 Maki.Tulosta;

 DrawScreen;

end;

procedure alertbox;
begin

 fillbox(59,79,261,131,242);
 fillbox(60,80,260,130,244);

 fillarea(60,80,260,130,63);

end;

procedure WriteVideo;
var index : LongInt;
begin
 for index:=0 to length(video) - 1 do
  Video[index]:=Graffa[index];
end;

procedure NewScreen(style,color:byte);
begin

   Fillbox(0,0,319,199,0);

{   DrawScreen; }

{ LataaPCX('menu.pcx',320*200,0,0);
  AsetaPaletti;
  Move(mem[Graffa:0],mem[Video:0],64000); }


   case style of
(*   0 : begin { main menu }
        Fillbox(0,0,158,199,243);
        Fillbox(160,0,319,118,244);
        Fillbox(160,120,319,199,245);
       end; *)
   1 : begin { highscores ym. }
        Fillbox(0,0,319,18,245);
        Fillbox(0,20,319,199,243);
       end;
(*   2 : begin { valitsem„ki ym. }
        Fillbox(0,0,78,199,244);
        Fillbox(80,0,319,199,243);
       end; *)
   2 : begin { valitsem„ki }
{        Fillbox(0,0,19,199,245);
        Fillbox(21,0,298,199,243);
        Fillbox(300,0,319,199,245); }

        Fillbox(0,0,10,199,245);
        Fillbox(12,0,307,199,243);
        Fillbox(309,0,319,199,245);

       end;

   3 : begin { kingofthehill }
        Fillbox(0,0,168,98,245);
        Fillbox(0,100,168,199,244);
        Fillbox(170,0,319,199,243);
       end;

   4 : begin { hiscore2 }
        Fillbox(0,0,319,18,245);
        Fillbox(0,20,319,118,243);
        Fillbox(0,120,319,138,245);
        Fillbox(0,140,319,199,243);
       end;

   5 : begin
        FillBox(0,0,319,199,243);
       end;

   6 : begin { welcomescreen }
      {  FillBox(40,11,279,189,243); }
        Fillbox(0,0,50,199,245);
        Fillbox(52,0,267,199,243);
        Fillbox(269,0,319,199,245);

       end;

   7 : begin
{        Fillbox(0,0,88,199,243);
        Fillbox(90,0,319,199,245); }
        Fillbox(0,0,158,199,243);
        Fillbox(160,0,319,199,244);

       end;

   end;

  FillArea(0,0,319,199,63);

  case style of  { LOGO }
  0 : DrawAnim(20,14,61);
  1 : DrawAnim(5,2,62);
  2 : DrawAnim(30,8,62);
  4 : begin
       DrawAnim(5,2,62);
       DrawAnim(5,122,62);
      end;
  6 : DrawAnim(80,6,61);
{  7 : DrawAnim(5,2,62); }
  end;

   SiirraStandardiPaletti;

   case style of
   0 : MuutaLogo(0); { logo sinisen s„vyiksi }
 1,2,4 : MuutaMenu(3,0); { menu3 harmaaksi }
   6 : MuutaLogo(0);
   end; { case }

   case color of
   1 : MuutaMenu(1,2);  { menu1 violetiksi }
   2 : MuutaMenu(1,4);  { menu1 ruskeaksi KOTH }
   3 : MuutaMenu(1,5);  { menu1 punaiseksi WCRES }
   4 : MuutaMenu(1,1);  { menu1 mustaksi 4HILLS }
   5 : MuutaMenu(1,3);  { menu1 turkoosiksi? STATS }
   end; { case }

  AsetaPaletti;

  DrawScreen;

end;


procedure CloseGraph;
begin
 AsetaMoodi($3);
end;

procedure Sprite(SpriteData:array of byte;X,Y:Word);
var ysize, xsize, yindex, xindex : byte;
    offset : integer;
begin
  ysize:=SpriteData[2] + (SpriteData[3] shl 8);
  xsize:=(length(SpriteData) - 4) div ysize;
  offset:=4;

  for yindex:=0 to (ysize - 1) do
  begin
    for xindex:=0 to (xsize - 1) do
     begin
       if (SpriteData[offset] <> 0) and (X+xindex < 320) then
       begin
         Video[X+xindex+(Y+yindex)*320]:=SpriteData[offset];
       end;
       inc(offset);
     end;
  end;
end;

procedure DrawAnim(x,y:integer;num:byte);
{var x1,y1 : integer; }
{ var xsize,ysize : word; }
  var ysize : integer;

begin

 x:=x-AnimP[num,0];
 y:=y-AnimP[num,1];

(*  xsize:=MemW[Anim[Num]:0]; { leveys } *)
 ysize:=0;

 if (num>0) and (num<=numanim) then
  begin
   ysize:=Anim[Num][2] + (Anim[Num][3] shl 8);

   if (x>=0)  and (y>=0) and
      (x<320) and (y<200-ysize) then Sprite(Anim[num],x,y);
  end;

end;

function ReadByte(var f1:text):byte;
{var ch:char; }
begin
 read(f1,ch);
 readbyte:=ord(ch);
end;


procedure LoadAnim(filename:string);
var f1 : text;
{    ch : char; }
    x,y,tempb,x2,y2 : byte;
    xx,yy,temp : integer;
begin

 assign(f1,filename);
 {$I-}
 reset(f1);
 {$I+}
 FileOk(IOResult,filename);

{ writeln;
 writeln('File opened.'); }

 NumAnim:=0;

 x:=ReadByte(f1);
 y:=ReadByte(f1);

 repeat

  inc(NumAnim);

{  writeln(x,' ',y,' ',numanim); }

  setLength(Anim[NumAnim],x*y+4); { varataan tilaa spritelle }

  Anim[NumAnim][0]:=x;
  Anim[NumAnim][1]:=x shr 8;

  Anim[NumAnim][2]:=y;
  Anim[NumAnim][3]:=y shr 8;

{  writeln('info written.'); }

  for yy:=0 to y-1 do
   for xx:=0 to x-1 do
    begin
     tempb:=ReadByte(f1);
     if (tempb=9) then tempb:=15; { suksen keskityspiste (kai?) }
     Anim[NumAnim][yy*x+xx+4]:=tempb;
    end;

  AnimP[numanim,0]:=ReadByte(f1);  { keskitt„misplussa x }
  AnimP[numanim,1]:=ReadByte(f1);  { -"- y }

  x:=ReadByte(f1);
  y:=ReadByte(f1);


  if (NumAnim=83) then  { invert skis! }
   for temp:=72 to 83 do
    begin
     inc(NumAnim);
     x2:=Anim[temp][0] + (Anim[temp][1] shl 8);
     y2:=Anim[temp][2] + (Anim[temp][3] shl 8);

     setLength(Anim[NumAnim],x2*y2+4); { varataan tilaa }

     Anim[NumAnim][0]:=x2;
     Anim[NumAnim][1]:=x2 shr 8;
     Anim[NumAnim][2]:=y2;
     Anim[NumAnim][3]:=y2 shr 8;

    for yy:=0 to y2-1 do
     for xx:=0 to x2-1 do
      Anim[NumAnim][yy*x2+xx+4]:=Anim[temp][(y2-yy-1)*x2+xx+4];

     AnimP[NumAnim,0]:=AnimP[temp,0];
     AnimP[NumAnim,1]:=y2-1-AnimP[temp,1];
   end;


 until (x=255) and (y=255);

 close(f1);

{ readln; }

end;

procedure PutPixel(x,y,c:integer);
var x1, y1 : word;
begin
 if (x>=0) and (x<320) and (y>=0) and (y<200) then
  begin
   x1:=x; y1:=y;
   video[(y1*320)+x1]:=c;
  end;

end;

procedure PutGPixel(x,y:integer;c:byte);
var temp : longint;
begin
 temp:=y*Maki.XSize+x;

 Kirjoita(temp,c);
end;

function GetPixel(x,y:word):byte;  { en tied„ toimiiko }
begin
 GetPixel:=video[y*320+x];
end;

procedure EWriteFont(xx,yy:integer;s:string);
begin
  writefont(xx-fontlen(s),yy,s);
end;


function DoFont(xx,yy:integer;s:string;draw:boolean):word;
var chh:char;
    i,t,increment : integer;
    p : word;
begin

 p:=0;  { siirtym„ }

 for i:=1 to length(s) do
   s[i]:=upcase(s[i]);

 for i:=1 to length(s) do
  begin

   t:=100;
   chh:=s[i];

   case chh of
(*   ' ','ÿ'  : inc(p,4);   { space ja 255 } *)
   ' '      : inc(p,4);   { vaan space! }
   '$'      : inc(p,5);   { % numeron pituinen space }
   '0'      : t:=29;
   '1'..'9' : t:=ord(chh)-19;
   'A'..'Z' : t:=ord(chh)-65;
   '†',''  : t:=26;
   '„','Ž'  : t:=27;
   '”','™'  : t:=28;
   ':'      : t:=39;
   '.'      : t:=40;
   '?'      : t:=41;
   '!'      : t:=42;
   '*'      : t:=43;
   '-'      : t:=44;
   '+'      : t:=45;
   ','      : t:=46;
   '('      : t:=47;
   ')'      : t:=48;
   '«'      : t:=49; { pieni m }
   '"'      : t:=50; { tuplaheittomerkki }
   ''''     : t:=51; { yksi”heittomerkki }
   '#'      : t:=52;
   '›',''  : t:=53; { norja ” eli o ja viiva halki }
   '','š'  : t:=54; { ber y }
   'á'      : t:=55; { stuit staffel }
   '/'      : t:=56;
   '’','‘'  : t:=57; { AE:t }
   '%'      : t:=58;
   end;

 if (t<>100) then
  begin
   inc(t);
   if (Draw) then drawanim(xx+p,yy,t); { t+? riippuu muista animeista! }
{   inc(p,memW[Anim[t]:0]+1); }  { vanhoilla fonteilla }
   increment:=Anim[t][0] + (Anim[t][1] shl 8);
   inc(p,increment);
  end;

 end;

 DoFont:=p;

end;


procedure WriteFont(xx,yy:integer;s:string);
begin

  if (xx>0) and (yy>0) then DoFont(xx,yy,s,True);

end;



function FontLen(s:string):word;
var temp:word;
begin

 temp:=DoFont(0,0,s,False);

 FontLen:=temp;

end;



procedure fontcolor(col:byte);
var temp,x,y,xx,yy : word;
    tempb : byte;
begin

 for temp:=1 to 60 do
  begin
   x:=Anim[temp][0] + (Anim[temp][1] shl 8);
   y:=Anim[temp][2] + (Anim[temp][3] shl 8);

    for yy:=0 to y-1 do
     for xx:=0 to x-1 do
      begin
       tempb:=Anim[temp][(yy*x)+xx+4];
       if (tempb <> 242) and (tempb <> 0) then
        Anim[temp][(yy*x)+xx+4]:=col;
      end;
  end;

end;


Procedure FillArea(x1,y1,x2,y2:word;thing:integer);
var temp1, temp2 : word;
    count : word;
    scr : word;
    ax,ay : word;
    col, new : byte;
    sizex,sizey : word;
    index : integer;

begin

 scr:=0;
 count:=0;

 index:=63;
 sizex:=19;
 sizey:=13;

 ax:=0;
 ay:=0;

  for temp1:=y1 to y2 do
   for temp2:=x1 to x2 do

    begin

     scr:=(temp1*320)+temp2;

     col:=Video[scr];
     new:=col;

     ax:=(scr mod 320) mod sizex;
     ay:=(scr div 320) mod sizey;

     if (thing=64) then
      begin
       ax:=((scr mod 320)+2) mod sizex;
       ay:=((scr div 320)+7) mod sizey;
      end;

     count:=(ay*sizex)+ax;

     if (new>242) and (new<246) and (Anim[index][count+4] <> 0) then inc(new,5);

{     inc(ax); if (ax>=19) then
      begin
       ax:=0;
       inc(ay);
       if (ay>=12) then ay:=0;
      end; }

{     inc(count); if (count>=19*12) then count:=0; }

     Video[scr]:=new;

   end;

end;


(*
procedure HLine(x,y:integer;length:word;col:byte);
begin
end;


procedure Vline(x,y:integer;length:word;col:byte);
begin
end;
*)
procedure Fillbox(x,y,x2,y2:word;col:byte);
var xx,yy : word;
begin
   for yy:=y to y2 do
    for xx:=x to x2 do
     video[xx + yy shl 8 + yy shl 6]:=col;
    {  mem[video:(yy*320)+xx]:=col; }

end;

procedure Box(x,y,x2,y2:word;col:byte);
var xx,yy : word;
begin

 for xx:=x to x2 do
  begin
   putpixel(xx,y,col);
   putpixel(xx,y2,col);
  end;

 for yy:=y to y2 do
  begin
   putpixel(x,yy,col);
   putpixel(x2,yy,col);
  end;

end;

procedure Balk(st:byte);
begin
  // Not needed in port
end;

(*
procedure angle(x,y,a,b,c:integer);
begin
 { ei skulaa, eik„ tule skulaamaan.  for compatibility }
end;
*)

end. { end unit }

