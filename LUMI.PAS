Unit Lumi;


INTERFACE

procedure Init;

const LumiMax=256;

procedure VieLmaara(InLmaara:Word);
procedure Update(var Buffer:array of byte;DeltaX,DeltaY,Tuuli:Integer;Draw:boolean);


IMPLEMENTATION


const SineLgt=512;   { t„ytyy olla 2^n }
      TaustaMin=64;  { taustakuvan v„rit }
      TaustaMax=215; {  }
(*      PerusG=600;    { nopeus, jolla hiutaleet putoaa }
      GVaihtelu=300; { putoamisnopeuden vaihtelu }
      SivuLiike=50; { sivuttaisliikkeen suuruus }         *)


type tLumi=record

       x,y:longint;
       gravity:longint;
       sin_pos:word;
       c1,c2:word;
       style:word;

     end;


var  LH:array[0..LumiMax-1] of tLumi;
     Sine:Array[0..SineLgt] of longint;
     Max, PerusG, Gvaihtelu, SivuLiike : word;
     Sleet : boolean;



procedure Update(var Buffer:array of byte;DeltaX,DeltaY,Tuuli:Integer;Draw:boolean);
var i:integer;
    offset:word;

begin

    if(Max>=LumiMax) then Max:=LumiMax-1;

    for i:=0 to Max do with LH[i] do
        begin
         if (draw) then
         begin
         inc(x,Sine[sin_pos]+DeltaX shl 9+Tuuli);
         inc(sin_pos); sin_pos:=sin_pos and (SineLgt-1);
         inc(y,gravity+DeltaY shl 8);
         end;
         offset:=(x shr 10)+(Y shr 10)*320;
         if (offset<63679) and
           (Buffer[offset]>=TaustaMin) and
           (Buffer[offset+1]>=TaustaMin) and
           (Buffer[offset]<TaustaMax) and
           (Buffer[offset+1]<TaustaMax) then

           if (Style=1) then begin
              Buffer[offset]:=c1;
              Buffer[offset+1]:=c1 shr 8;
              Buffer[offset+320]:=c2;
              Buffer[offset+320+1]:=c2 shr 8;

              end else Buffer[offset]:=byte(c1);

        end;

end;



function GetColor:Word;
Begin GetColor:=(random(4)+232)+(random(4)+232) shl 8;end;


procedure Reset;
var i:integer;

begin for i:=0 to SineLgt do Sine[i]:=Round(sin(i*pi*2/SineLgt)*SivuLiike);
      for i:=0 to LumiMax-1 do with LH[i] do
         begin
          x:=longint(random(320)) shl 10;
          y:=longint(random(200)) shl 10;
          sin_pos:=random(SineLgt);
          gravity:=random(GVaihtelu)+PerusG-GVaihtelu;
          style:=random(2);
          if (Sleet) and (Style=1) then Style:=random(2);
          C1:=GetColor;
          C2:=GetColor;
         end;
{     PerusG:=600;
      Max:=0; }
end;


procedure VieLmaara(InLmaara:word);
begin

 PerusG:=600;
 GVaihtelu:=300;
 SivuLiike:=50;
 Sleet:=False;

 Max:=InLmaara;

 if (Max>1000) then Sleet:=true;

 if (Sleet) then { r„nt„„ }
  begin
   PerusG:=875;
   GVaihtelu:=100;
   SivuLiike:=50;
   Max:=InLmaara-1000;
  end;

 Reset;

end;

procedure Init;
begin

   Reset;
end;

end.
