Unit SJ3Table;

interface

function FindLanding(kulma:integer):integer;
function ParruAnim(var kulmalaskuri:integer):byte;
function SuksiLaskussa(kulma:integer):byte;
function LaskuAsento(suksi:byte):byte;
function LaskuAnim(kulma:integer;style:byte):byte;
Function PonnAnim(var ponnphase:byte):byte;
Function LentoAnim(kulma1:integer):byte;
Function SuksiLennossa(kulmas:integer):byte;  { k„rki yl”sp„in olevia suksia }
function jumprisk(kulma:integer):longint;


implementation

function FindLanding(kulma:integer):integer;
var temp : integer;
begin

 temp:=25; { korkeus, jonka j„lkeen alastulo on aloitettava }

{        temp:=35-MakiKulma(x) div 2; }

 case kulma of
  0..9  : temp:=50;
 10..20 : temp:=50;
 21..24 : temp:=50;
     25 : temp:=48;
     26 : temp:=45;
     27 : temp:=40;
     28 : temp:=36;
     29 : temp:=32;
     30 : temp:=28;
     31 : temp:=24;
     32 : temp:=22;
 33..39 : temp:=20;
 40..60 : temp:=15;
 end;

 FindLanding:=temp;

end;


function jumprisk(kulma:integer):longint;
var temp : longint;
begin

 temp:=1;

 case kulma of
  31 : inc(temp,1);
  30 : inc(temp,2);
  29 : inc(temp,4);
  28 : inc(temp,7);
  27 : inc(temp,12);
  26 : inc(temp,19);
  25 : inc(temp,29);
  24 : inc(temp,41);
  23 : inc(temp,54);
  22 : inc(temp,70);
  21 : inc(temp,90);
  20 : inc(temp,120);
  19 : inc(temp,200);
  18 : inc(temp,300);
  17 : inc(temp,500);
  16 : inc(temp,700);
  0..15 : inc(temp,950);
 end;

  jumprisk:=temp;

end;



function ParruAnim(var kulmalaskuri:integer):byte;
var JumperAnim : byte;
begin

   case kulmalaskuri of
   1000..1012 : JumperAnim:=169;
   1013..1033 : JumperAnim:=170;
   1034..1046 : JumperAnim:=169;
   1047..1059 : JumperAnim:=164;
   1060..1072 : JumperAnim:=171;
   1073..1093 : JumperAnim:=172;
   1094..1106 : JumperAnim:=171;
   1107       : KulmaLaskuri:=0;

   2000..2012 : JumperAnim:=173;
   2013..2025 : JumperAnim:=174;
   2026..2036 : JumperAnim:=175;
   2037..2047 : JumperAnim:=174;
   2048..2058 : JumperAnim:=175;
   2059..2071 : JumperAnim:=174;
   2072..2082 : JumperAnim:=173;
   2083       : KulmaLaskuri:=0;

   3000..3024 : JumperAnim:=176;
   3025..3037 : JumperAnim:=177;
   3038..3200 : JumperAnim:=164;
   3201       : KulmaLaskuri:=0;
{
   4000..4024 : JumperAnim:=173;
   4025..4033 : JumperAnim:=178;
   4034..4054 : JumperAnim:=173;
   4055..4063 : JumperAnim:=178;
   4064..4084 : JumperAnim:=173;
   4085       : KulmaLaskuri:=0;
   }

   end;

   if (kulmalaskuri=0) then JumperAnim:=164;

 ParruAnim:=JumperAnim;

end;



function SuksiLaskussa(kulma:integer):byte;
var value:byte;

begin

 value:=0;

  case kulma of
  4..6  : value:=1;
  7..9  : value:=2;
 10..12 : value:=3;
 13..16 : value:=4;
 17..19 : value:=5;
 20..24 : value:=6;
 25..28 : value:=7;
{ 29..32 : value:=9;
 33..39 : value:=10; }
 29..33 : value:=8;
 34..39 : value:=9;

 40..48 : value:=10;
 49..64 : value:=11;
 65..90 : value:=12;

{ 2..12 : value:=temp; }
 end;

 SuksiLaskussa:=value+71;

end;



function LaskuAsento(suksi:byte):byte;
var value : byte;
begin

 value:=0;

  suksi:=suksi-71;

    case suksi of
     2..4  : value:=1;
     5..6  : value:=2;
     7..9  : value:=3;
    10..12 : value:=4;
    end;

{   end; }

 LaskuAsento:=value+101;

end;



function LaskuAnim(kulma:integer;style:byte):byte;
var value : byte;
begin

 value:=127;

 if (kulma>70) then kulma:=kulma-71; { jos se on suksianim }

 case kulma of
  0..4  : value:=127;
  5..6  : value:=126;
  7     : value:=125;
  8..12 : value:=124;
 end;

 if (style=2) then value:=value+6;

 LaskuAnim:=value;

end;




Function PonnAnim(var ponnphase:byte):byte;
var value : byte;
begin

 value:=117;

  case (ponnphase) of
   4..6   : value:=118;
   7..9   : value:=119;
  10..13  : value:=120;
  14..17  : value:=121;
  18..20  : value:=122;
  21..23  : value:=123;
  24..50  : value:=112;  { TARKISTA TŽMŽ!!! }
  end;

 inc(ponnphase);

 PonnAnim:=value;

end;



Function LentoAnim(kulma1:integer):byte;
var value:byte;
begin

 value:=0;

(*
 case (kulma1) of
  50..59   : value:=1;
  60..74   : value:=2;
  75..89   : value:=3;
  90..114  : value:=4;
 115..139  : value:=5;
 140..174  : value:=6;
 175..1000 : value:=7;
 end; { ap }
*)

 case (kulma1) of
  50..61   : value:=1;
  62..76   : value:=2;
  77..95   : value:=3;
  96..119  : value:=4;
 120..149  : value:=5;
 150..186  : value:=6;
 187..1000 : value:=7;
 end;

 LentoAnim:=value+106;

end;



Function SuksiLennossa(kulmas:integer):byte;  { k„rki yl”sp„in olevia suksia }
var value:byte;
begin

 value:=0;

 case (kulmas) of
 -900..-258  : value:=19;
 -257..-216  : value:=18;
 -215..-176  : value:=17;
 -175..-136  : value:=16;
 -135..-97   : value:=15;
  -96..-59   : value:=14;
  -58..-20   : value:=13;

   20..58   : value:=1;
   59..96   : value:=2;
   97..135  : value:=3;
  136..175  : value:=4;
  176..215  : value:=5;
  216..257  : value:=6;

{ 258..298  : value:=93;
 299..340  : value:=94;
 341..384  : value:=95;
 385..429  : value:=96;
 430..475  : value:=97;
 476..1000 : value:=98; }
 end;

 SuksiLennossa:=value+71;

 (*
 SkiValues:=54;  { suora suksi v„liaikaisesti }
  *)

end;

end.
