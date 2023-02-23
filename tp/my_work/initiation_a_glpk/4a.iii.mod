param n;
param V{1..n} >= 0;
param P{1..n};
param M;

param k;
param C{1..n};  # categorie de chaque objet
param Q{1..k};  # nb d'objets qu'on peut mettre dans le sac

var x{1..n} binary;
var obj;

maximize c: obj;
c0: obj = sum{i in 1..n} V[i]*x[i];
c1: sum{i in 1..n} P[i]*x[i] <= M;

D{j in 1..k}: sum{i in 1..n : C[i]=j} x[i] <= Q[j];

solve;

display x;
display obj;

end;