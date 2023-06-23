param p;
set T := 1..p;
param m;
param M;
param In{T};
param Pr{T};

var vendu{T} >= 0;
var niv{0..p} >= m, <=M;      # niveau a la fin du pas de temps
var obj;

param u;
param N;

maximize c: obj;
c0: obj = sum{t in T} Pr[t]*vendu[t];
c1{t in T}: niv[t] = niv[t-1] - vendu[t] + In[t];
c2: niv[0] = M;

# Question 2
c3{t in T}: sum{t1 in t..t+u-1 : t+u-1<=p} vendu[t1] <= N;

solve;

display vendu, niv, obj;

end;