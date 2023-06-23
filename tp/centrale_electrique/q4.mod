param T;
param P;
param Palier{1..P};
param Prix{1..T};
param Cout;
param NbDemarrage;
param MaxCapacite;


var obj;
var etat{0..T+1, 1..P} binary;


maximize o: obj;


c0: obj = sum{t in 1..T} ( 
            ( sum{p in 1..P} etat[t,p] * Palier[p] * MaxCapacite )
            * Prix[t] 
            - Cout 
          );

c1{t in 0..T+1}: sum{p in 1..P} etat[t,p] = 1;
c2: etat[0,1] = 1;
c3: etat[T+1,1] = 1;
c4{t in 0..T, p in 2..P-1}: etat[t+1,p-1] + etat[t+1,p] + etat[t+1,p+1] >= etat[t,p];
c5{t in 0..T}: etat[t+1,1] + etat[t+1,2] >= etat[t,1];
c6{t in 0..T}: etat[t+1,P-1] + etat[t+1,P] >= etat[t,P];

c7: sum{t in 0..T} (etat[t,1]+etat[t+1,2]) <= 2*NbDemarrage;


solve;
display obj;
end;
