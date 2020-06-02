Unit Tuuli;

Interface

procedure Init;
procedure Piirra;
procedure Hae;
procedure Alusta(place:byte);
procedure Siirra;
procedure Tuo(x,y:integer);
procedure AsetaPaikka(place:byte);

var voim,windy, value : integer;

Implementation

uses SJ3Graph, SJ3Help;

var tsuun : boolean;      { kiinnostaako n„m„ kaikkia? }
    traja1, traja2 : integer;
    tkulma : single;
    tuulix, tuuliy:integer;
    tpaikka : byte;

procedure Tuo(x,y:integer);
begin

 tuulix:=x;
 tuuliy:=y;

 case tpaikka of
 11 : begin inc(tuulix,10); dec(tuuliy,20); end;
 12 : begin inc(tuulix,15); dec(tuuliy,5); end;
 13 : begin dec(tuulix,10); inc(tuuliy,12); end;
 end;

end;

procedure AsetaPaikka(place:byte);
begin

  tpaikka:=place;

  tuulix:=10;
  tuuliy:=180;

  case tpaikka of
  1 : begin end;
  2 : tuuliy:=97;
  3 : tuulix:=268;
  4 : tuulix:=150;
  5 : begin tuulix:=268; tuuliy:=97; end;
  6 : begin tuulix:=268; tuuliy:=21; end;
  7 : begin tuulix:=150; tuuliy:=21; end;
{  8 : begin tuulix:=7; tuuliy:=33; end; }
  8 : begin tuulix:=56; tuuliy:=33; end;
  end;



end;


procedure Alusta(place:byte);
var temp1,temp2 : byte;
begin

  temp1:=random(180);    { Tuulen rajoja }
  temp2:=random(120);
  windy:=temp2;          { ns. tuulisuusindeksi }

  traja1:=temp1-temp2;
  traja2:=temp1+temp2;
  tkulma:=random(temp2*2)+traja1;
  voim:=random(50);
  if random(2)=0 then tsuun:=true else tsuun:=false;

  AsetaPaikka(place);


end;


procedure Siirra;
begin

 if (tsuun) and (tkulma>traja2) then tsuun:=false;
  if (tsuun=false) and (tkulma<traja1) then tsuun:=true;
   if (random(50)=0) then tsuun:=not tsuun;
 if (tsuun) then tkulma:=tkulma+(random(4)/5) else tkulma:=tkulma-(random(4)/5);

end;

procedure Hae;
begin

 Siirra;
 value:=round(cos(pi*tkulma/180)*voim);

{ value:=-10; }

end;


procedure Piirra;
var s:string;
 begin

{
 tuulix:=10;
 tuuliy:=180;
 }

{ fillbox(tuulix,tuuliy,tuulix+42,tuuliy+12,10); }
 fillbox(tuulix+4,tuuliy+1,tuulix+38,tuuliy+2,248);

 fillbox(tuulix+21,tuuliy+1,tuulix+21,tuuliy+2,240);

 PutPixel(tuulix+21,tuuliy+9,247); { piste; oli 252 }

 if (value>0) then
  fillbox(tuulix+22,tuuliy+1,tuulix+22+value div 3,tuuliy+2,236);

 if (value<0) then
  fillbox(tuulix+20+value div 3,tuuliy+1,tuulix+20,tuuliy+2,237);

 s:=txtp(abs(value));

 if (value<0) then writefont(tuulix+10,tuuliy+5,'-');

 writefont(tuulix+15,tuuliy+5,s[1]);
 writefont(tuulix+24,tuuliy+5,s[3]);

end;

procedure Init;
begin

 Alusta(0);
end;

end.
