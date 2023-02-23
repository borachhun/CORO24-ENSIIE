var x1;
var x2;
var x3;
var obj;

minimize z: obj;
c0: obj = -x1 + 2*x2 - 3*x3;
c1: 1 <= x1 <= 4;
c2: 3 <= x2 <= 6;
c3: 5 <= x3 <= 10;
c4: x1 + 2*x2 + x3 = 15;

solve;

display x1, x2, x3;
display obj;

end;