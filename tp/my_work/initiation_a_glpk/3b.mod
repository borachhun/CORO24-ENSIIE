var x1 >= 1, <= 4;
var x2 >= 3, <= 6;
var x3 >= 5, <= 10;
var obj;

minimize z: obj;
c0: obj = -x1 + 2*x2 - 3*x3;
c4: x1 + 2*x2 + x3 = 15;

solve;

display x1, x2, x3;
display obj;

end;