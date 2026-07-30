program Mandelbrot;

label
  99;

var
  x, y, i: Integer;
  ca, cb, a, b, t: Real;
  
begin
  for y := -12 to 12 do
  begin
    for x := -39 to 39 do
    begin
      ca := 0.0458 * x;
      cb := 0.08333 * y;
      a := ca;
      b := cb;
      
      for i := 0 to 16 do
      begin
         t := a * a - b * b + ca;
         b := 2 * a * b + cb;
         a := t;
         if (a * a + b * b) > 4 then goto 99;
      end;
      99:
      if i > 15 then
         Write(' ')
      else if i > 9 then
         Write(Chr(i + 7 + 48))
      else
         Write(Chr(i + 48));
    end;
    WriteLn;
  end;
end.
