param n;
param V{1..n} >= 0;
param P{1..n};
param M;

var x{1..n} binary;
var obj;

maximize c: obj;
c0: obj = sum{i in 1..n} V[i]*x[i];
c1: sum{i in 1..n} P[i]*x[i] <= M;

solve;

display x;

end;