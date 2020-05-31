
  Unit      Maki;

INTERFACE {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

  type      EPtr=Word; { "extended pointer" }

  const     XSize=1024;
            YSize=512;
            Alue=XSize*YSize; { m„en koko }
            Sivuja=16;
            SivuKoko:Word=Alue div Sivuja;

            Graffa:EPtr=0; { osoite m„en grafiikkaan }
            Video:EPtr=0; { osoite v„lipuskuriin }

            Lue:function(Osoite:LongInt):byte=nil; { lue tavu graffasta }
            Kirjoita:procedure(Osoite:LongInt;Arvo:byte)=nil; { }
            PaivitaRuutu:procedure=nil; { kopioi piirtobufferin n„yt”lle }
            PiirraSprite:procedure(SpriteData,X,Y:Word)=nil; { sprite }
            PaivitaKirjoitusSivu:procedure=nil;

  var       LinjanPituus:Array[0..YSize-1] of Word;
            ProfiiliY:Array[0..1300] of integer;

            X,Y:LongInt;

  procedure Tulosta;
  function  Alusta:Boolean;
  procedure Lopeta;
  procedure LukitseKirjoitusSivu(Sivu:LongInt);
  procedure AllocLarge(var P:EPtr;Size:Longint);

  procedure LaskeLinjat(var KeulaX:integer;kr:integer;pk:single);
  procedure AsetaMoodi(M:Word);
  function Profiili(x:integer):integer;


IMPLEMENTATION {ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}

  Uses      WinAPI; {GlobalAlloc}


  const     SiirtoOsoite:LongInt=0; { m„en piirt„mist„ varten }
            SivuPuskuri:pointer=nil; { -"- }

     procedure KopioiKirjoitusSivu;far;external;
     function  LueTavu(Osoite:LongInt):Byte;far;external;
     procedure KirjoitaTavu(Osoite:LongInt;Arvo:byte);far;external;
     procedure KopioiMaki(Osoite,Delta:LongInt);far;external;
     procedure Sprite(SpriteData,X,Y:Word);far;external;
     procedure KopioiRuutu;far;external;
     {$l makilow.obj}

  procedure LukitseKirjoitusSivu(Sivu:longint);
  begin     if (Sivu<Sivuja*2) then SiirtoOsoite:=(Sivu*SivuKoko);
            end;

  procedure Tulosta;
  var       a,b:longint;
  begin     a:=Y*XSize;
            b:=Alue-(X shr 1)-(Y shr 1)*XSize;
            KopioiMaki(a,b);
            end;

     procedure AllocLarge(var P:EPtr;Size:Longint);
     var    Selector:Word;
     begin  if (Size>$100000) then Size:=Size or $FFF;
            Selector:=GlobalAlloc(gmem_fixed, Size);
     asm    mov AX,$0008
            mov BX,[Selector]
            mov CX,word ptr [size+2]
            mov DX,word ptr [size]
            int $31
            jnc @End
            mov [Selector],0
     @end:  end;
            if (Selector=0) then RunError(203);
            P:=Selector;
            end;


procedure AsetaMoodi(M:Word);
assembler;asm mov ax,[M];int $10;end;

function Profiili(x:integer):integer;
var temp:integer;
begin

 temp:=0;
 if (x>0) and (x<1300) then temp:=ProfiiliY[x];

 Profiili:=temp;

end;

procedure LaskeLinjat;
{ linjojen pituudet voisi ladata nopeammin levylt„ ... }
var       Y,X:LongInt;
          paikka:LongInt;
          c : byte;
          FormerY : integer;
          hp,x2,y2 : longint;
begin

 KeulaX:=0;
 FormerY:=0;

 for Y:=0 to Maki.YSize-1 do
  begin
   LinjanPituus[Y]:=0;
    for X:=0 to Maki.XSize-1 do
     if(Lue((Y*Maki.XSize)+X)<>0) then
     LinjanPituus[Y]:=X+1;
  end;

(*          for Y:=0 to Maki.YSize-1 do
           begin
            for X:=0 to Maki.XSize-1 do
             begin
              LinjanPituus[Y]:=X;
               if (Lue((Y*Maki.XSize)+X)=0) then X:=Maki.XSize-1; { ULOS }
             end;
           end;  *)

 for X:=0 to Maki.XSize-1 do
  begin
   for Y:=0 to Maki.YSize-1 do
    begin
     ProfiiliY[X]:=Y;

     if (LinjanPituus[Y]>X) then Y:=Maki.YSize-1;
{    if (Lue((Y*Maki.XSize)+X)<>0) then Y:=Maki.YSize-1; } { ULOS }
    end;
  end;

 for X:=Maki.XSize to 1300 do
  begin
   ProfiiliY[X]:=ProfiiliY[Maki.XSize-1];
  end;


 for X:=0 to Maki.XSize-1 do
  begin
   Y:=ProfiiliY[X];

   if (Y-FormerY > 3) then KeulaX:=X;  { etsit„„n keulan paikka }
   FormerY:=Y;
  end;

  dec(KeulaX,1); { se mennee yhden liian pitk„ksi }

 for X:=KeulaX to Maki.XSize-10 do  { laskeutumisalueiden piirrot }
  begin

   x2:=X-KeulaX;  { suhteellinen keulan alap„„h„n X }

   y2:=ProfiiliY[X]-ProfiiliY[KeulaX];  { suhteellinen Y }

   hp:=round(sqrt((x2*x2)+(y2*y2))*pk*0.5)*5;  { +10? }

   if (hp>=(2/3*kr)*10) and (hp<=(kr*12)) then
    begin
     if (hp<kr*10) then c:=238 else c:=239;

{     Paikka:=LongInt((ProfiiliY[X]*Maki.XSize)+X);
     Kirjoita(paikka,Random(256)); }

{     Kirjoita(190*Maki.XSize+X,1); }

{     for Y:=0 to 4 do
      Kirjoita(((ProfiiliY[X]+(2*Y)+X mod 2)*Maki.XSize)+X,c); }

     for Y:=0 to 2 do
      Kirjoita(((ProfiiliY[X]+Y+1)*Maki.XSize)+X,c);

    end;

  end;



end;


(*

procedure LaskeLinjat;
{ linjojen pituudet voisi ladata nopeammin levylt„ ... }
var       Y,X,X2:LongInt;
begin     for Y:=0 to Maki.YSize-1 do begin
              LinjanPituus[Y]:=0;
              for X:=1 to Maki.XSize-1 do
                  if(Lue((Y*Maki.XSize)+X)<>0) then
                      LinjanPituus[Y]:=X+1;
              end;
          end;

*)


  function  Alusta:Boolean;
  begin     Alusta:=True;
            AllocLarge(Graffa,Alue*2+1024);
            if(MaxAvail>=64000) then GetMem(SivuPuskuri,64000)
               else RunError(203);
            Video:=Seg(SivuPuskuri^);
            PaivitaKirjoitusSivu:=KopioiKirjoitusSivu;
            Kirjoita:=KirjoitaTavu;
            PaivitaRuutu:=KopioiRuutu;
            PiirraSprite:=Sprite;
            Lue:=LueTavu;
            end;

  procedure Lopeta;
  begin     end;

end.
