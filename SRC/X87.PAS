unit X87;

interface

{$inline on}

{ Converts a value to extended, so that the expression it is part of is
  computed in x87 80-bit precision, like the Borland Pascal 7 build of the
  original DOS version computes every floating point expression. On targets
  where extended is the same as double (Win64, ARM), the results are the same
  except in very rare cases. }
function Ext(x : extended) : extended; inline;

implementation

function Ext(x : extended) : extended; inline;
begin
  Ext := x;
end;

end.
