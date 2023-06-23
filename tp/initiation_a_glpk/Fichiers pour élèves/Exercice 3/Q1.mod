var x1;
var x2;

maximize z : 3*x1 + 5*x2;
subject to c1: x1 <= 4;
subject to c2: x2 <= 6;
subject to c3: 3*x1 + 2*x2 <= 18;

solve;

end;