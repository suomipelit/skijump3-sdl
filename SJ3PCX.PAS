Unit SJ3PCX;

interface

procedure AsetaPaletti;
procedure SiirraStandardiPaletti;
procedure SiirraLiiviPois;
procedure MuutaLogo(col:byte);
procedure MuutaReplay(mode:byte);
procedure MuutaMenu(index,col:byte);
procedure TummaLumi;
procedure SavytaPaletti(alue,bkbright:byte);
procedure SpecialMainPaletti;
procedure TallennaAlkuosa(alue:byte);
procedure TakaisinAlkuosa(alue:byte);
procedure LoadSkis(col,phase:byte);
procedure LoadSuit(col,phase:byte);
{procedure startsuit;}

const NumSkis = 4;
      NumSuits = 8;


function LataaPCX(name:string;picsize:longint;Page:word;mirror:byte):boolean;

implementation

uses Maki, SDLPort;

const BufSize=2048;
      ReplaceMenu : array[0..6*2*3] of byte =
(*        ( 0, 0,47, 10,10,54,  { sininen tausta}
         47, 0, 0, 54,10,10,  { punainen " }
          0,30, 0, 10,35,10,  { vihre„   " } *)  { standardissa }
        (20,20,20, 26,26,26,  { harmaa   " }
         10,10,10, 15,15,15,  { l„hes musta }
(*         30, 0,30, 37, 7,37,  { violetti } *)

          28, 8,24, 34,13,28,  { uusi violetti }
          0,24,24,  6,30,30,  { turkoosi }
          0,25, 0,  5,30, 5,  { KOTH }
         47, 0, 0, 54,10,10,  { punainen }
         0);

         ReplaceLogo : array[0..6*4] of byte =
         (46,46,63, 32,32,63,  { sininen logo }
          51,51,51, 38,38,38,  { harmaa logo }
          54,10,10, 47, 0, 0,  { punainen valo! }
          10,54,10,  0,47, 0,  { vihre„ valo! }
           0);

        Suits : array[0..NumSuits-1,0..3] of byte =
        ((0,53,17,53), { Violetti }
         (0,55,33,11), { Oranssi }
         (0,11,48,18), { Vihre„ }
         (0,24,28,63), { Sininen }
         (0,63,17,17), { Punainen }
         (0,33,33,33), { Harmaa }
         (1,10,10,10), { Musta, feidi yl”s }
         (0,45,17,63)); { Lila }

        Skis : array[0..NumSkis-1,0..2] of byte =
        ((63,63,32), { keltainen default }
         (60,60,60), { valkoiset }
         (33,60,33), { vihre„t }
         (63,43,43)); { punaiset }

        StandardiPaletti : array[0..40*3] of byte =

        (53,17,53, 63, 0, 0, 43,12,43, 63, 0, 0,           { 216..219 }
         49,45, 0, 34,31, 0, 63, 0, 0, 56,54,54, { puvut }
         63,63,21, 54,52,10, 42,42,42, 42,20,10,           { 224..227 }
         21,21,21, 57,45,38, 63, 0, 0, 63,63,32, { muut }
                                      {23,48,48}

(*         32,32,32, 43,43,43, 52,52,52, 63,63,63, { lumet } *)
         40,40,41, 48,48,49, 55,55,56, 63,63,63, { lumet }

         56,13,13, 13,53,13, 23,23,63, 63,23,23, { tuulet ja m„et }

(*         63,63,63, 31,31,31,  0, 0, 0, 63,63,63,
         46,46,46, 31,31,63, 63,31,31, 63,63,63,
         63,63,46, 31,31,31, 54,52, 0, 25,25,25,
         57,45,38, 44,12,44, 63,17,63,  0, 0, 0, 0); { muu paletti } vanha *)

                                      { 0, 0,47 }
         63,63,63, 44,44,44,  0, 0, 0, 18,13,34,
         34,13,18, 20,20,20, 63,57, 9,  9,57,63,
        {47, 0, 0,  0,30, 0,}
         23,16,43, 43,16,23, 26,26,26, 52,47, 0,
        {10,10,54, 54,10,10, 10,35,10 }
          0,47,52, 51,51,51, 38,38,38, 63,63,63, 0);

var   Paletti:SDLPort.TPalette;
      PelastaAlkuosa:Array[0..255*3] of byte;


procedure AsetaPaletti;
begin
 SDLPort.SetPalette(Paletti);
end;


procedure TallennaAlkuosa(alue:byte);
var len : byte;
begin

 len:=240;

 if (alue=1) then len:=64;

 move(Paletti,PelastaAlkuosa,len*3);

end;


procedure TakaisinAlkuosa(alue:byte);
var len : byte;
begin

 len:=240;

 if (alue=1) then len:=64;

 move(PelastaAlkuosa,Paletti,len*3);

 Paletti[0,0]:=0;

end;


procedure SiirraLiiviPois;
var temp : byte;
begin

 for temp:=0 to 2 do
  Paletti[220,temp]:=Paletti[216,temp];

 for temp:=0 to 2 do
  Paletti[221,temp]:=Paletti[218,temp];

end;

procedure TummaLumi;
var temp, temp2 : byte;
begin

 for temp:=232 to 235 do
  for temp2:=0 to 2 do
   dec(Paletti[temp,temp2],round(0.4*(Paletti[temp,temp2]-32)));

end;

(*
procedure KorostaTeksti(phase:byte);
var temp1, temp2 : integer;
begin

 for temp1:=0 to 223 do
  for temp2:=0 to 2 do
   begin
    Paletti[temp1,temp2]:=Paletti[temp1,temp2]-;
    if (Paletti[temp1,temp2] > 63) then Paletti[temp1,temp2]:=63;
   end;



end;
*)

procedure MuutaReplay(mode:byte);
var temp, temp2, col : byte;
begin

 col:=249;

 case mode of
 1   : col:=250;
 2   : col:=253;
 4   : col:=251;
{ 5   : col:=252; }
 end;

 for temp:=249 to 253 do
  begin
   temp2:=byte(temp = col);

   Paletti[temp,0]:=10*temp2;
   Paletti[temp,1]:=63*temp2;
   Paletti[temp,2]:=20*temp2;
  end;

end;

procedure MuutaLogo(col:byte);
var temp1, temp2 : byte;
begin

 for temp1:=0 to 1 do
  for temp2:=0 to 2 do
   Paletti[253+temp1,temp2]:=ReplaceLogo[(col+temp1)*3+temp2];

end;

procedure MuutaMenu(index,col:byte);
var temp : byte;
begin

 for temp:=0 to 2 do
   Paletti[242+index,temp]:=ReplaceMenu[(col*2)*3+temp];

 for temp:=0 to 2 do
   Paletti[247+index,temp]:=ReplaceMenu[((col*2)+1)*3+temp];

end;


procedure SavytaPaletti(alue,bkbright:byte);
var temp1,temp2,start,fin : integer;
    r1 : single;
begin

 start:=0;
 fin:=239;

 if (alue=1) then begin start:=64; fin:=215; end;

 r1:=bkbright/100;

 for temp1:=start to fin do
  for temp2:=0 to 2 do
   begin
    Paletti[temp1,temp2]:=round(Paletti[temp1,temp2]*r1);
    if (Paletti[temp1,temp2] > 63) then Paletti[temp1,temp2]:=63;
   end;
end;

procedure LoadSkis(col,phase:byte);
var target : byte;
begin

  target:=231;
  if (phase>0) then target:=phase*5;
  if (col<0) or (col>NumSkis-1) then col:=0;

  Paletti[target,0]:=Skis[col,0];
  Paletti[target,1]:=Skis[col,1];
  Paletti[target,2]:=Skis[col,2];

end;

procedure LoadSuit(col,phase:byte);
var w1,w2,w3,target:byte;
    temp : integer;

const nums : array[0..1,0..3] of single =
      ((1,0.87,0.75,0.63),
       (1,1.50,2.00,2.50));

begin

 target:=215;
 if (phase>0) then target:=phase*5;

 if (col<0) or (col>NumSuits-1) then col:=0;

 w1:=Suits[col,1]; w2:=Suits[col,2]; w3:=Suits[col,3];

 for temp:=0 to 3 do
  begin
    Paletti[target+temp,0]:=round(nums[Suits[col,0],temp]*w1);
    Paletti[target+temp,1]:=round(nums[Suits[col,0],temp]*w2);
    Paletti[target+temp,2]:=round(nums[Suits[col,0],temp]*w3);
  end;

end;

(*
procedure startsuit;
var temp : integer;
    tempb : byte;
begin

 for tempb:=0 to 6 do
  begin
   LoadSuit(tempb,0);
   for temp:=0 to 2 do Paletti[209+tempb,temp]:=Paletti[216,temp];
   for temp:=0 to 2 do Paletti[202+tempb,temp]:=Paletti[218,temp];
  end;

 AsetaPaletti;

end;
*)

procedure SpecialMainPaletti;
begin

 Paletti[243,0]:=18;
 Paletti[243,1]:=13;
 Paletti[243,2]:=34;

 Paletti[248,0]:=23;
 Paletti[248,1]:=16;
 Paletti[248,2]:=43;

 MuutaMenu(3,0);

end;




procedure SiirraStandardiPaletti;
var temp1,temp2 : integer;
begin

 for temp1:=0 to 39 do
  for temp2:=0 to 2 do
   Paletti[216+temp1,temp2]:=StandardiPaletti[temp1*3+temp2];

end;


function LataaPCX(name:string;picsize:longint;Page:word;mirror:byte):boolean;

var   DiskBuffer:Pointer;
      dbp: pbyte;
      f:file;
      bp:integer;
      pc:word;
      wp:longint;
      i : integer;
      b1,b2:byte;

function PtrConversion(p:pointer):pbyte;
begin
  PtrConversion:={%H-}pbyte(p);
end;

function GetNextByte:byte;
begin
  if (bp>=BufSize) then
   begin
    bp:=0;
    if(Filesize(f)-filepos(f)<BufSize)
     then blockread(f,DiskBuffer^,Filesize(f)-filepos(f))
     else blockread(f,DiskBuffer^,BufSize);
   end;

 dbp:=PtrConversion(DiskBuffer+bp);
 GetNextByte:=dbp^;
 inc(bp);

end;

procedure PutByte(b:byte);
var x,temp : integer;
begin
 if (mirror>0) then
  begin
   temp:=(pc mod Maki.XSize);
   x:=671-temp;
   if (x<0) then x:=1024+x;
   Video[((pc div Maki.XSize)*Maki.XSize)+x]:=b;
  end else Video[pc]:=b;

  inc(wp);
  inc(pc);

  if (pc>=Maki.Sivukoko) then
   begin
    pc:=0;
    Maki.PaivitaKirjoitusSivu;
    inc(Page);
    Maki.LukitseKirjoitusSivu(Page);
   end;
end;


begin

 LataaPCX:=True;
{ GetMem(DiskBuffer,BufSize); }
 GetMem(DiskBuffer,65528);
 assign(f,name);
 {$I-}
 reset(f,1);
 {$I+}
 if (IOResult<>0) then
  begin
   FreeMem(Diskbuffer,65528);
   AsetaMoodi($3);
   writeln('SJ3 Error: Can''t find file ',name,'.  Exiting... ');
   Halt;
  end;

 seek(f,128);
  if (IOresult<>0) then LataaPCX:=false else
   begin
    wp:=0; { "write position" }
    bp:=BufSize; { "buffer position" }
    pc:=0; { "page counter" }
    Maki.LukitseKirjoitusSivu(Page);
     while(wp<picsize) do
      begin
       b1:=GetNextByte;
        if(b1>=192) then
         begin {pakkaus}
          b2:=GetNextByte;
           for i:=1 to b1-192 do PutByte(b2);
         end else PutByte(b1);
      end;

    GetNextByte;

    for pc:=0 to 767 do Paletti[pc div 3,pc mod 3]:=GetNextByte shr 2;

    close(f);
   end;

 Maki.PaivitaKirjoitusSivu;
 FreeMem(DiskBuffer,65528);

end;

end.

