set R;
set G;
param T;
param VolMin{R, 1..T};
param VolMax{R, 1..T};
param VolInit{R};
param ValEau{R};
param Apport{R, 1..T};
param Delai{R};
param Orig{G} symbolic;
param Dest{G} symbolic;
param Rendement{G};
param TurMin{G, 1..T};
param TurMax{G, 1..T};
param PrixElec{1..T};

var InTur{G, 1..T};
var VolLeft{R, 1..T};
var VolIn{R, 1..T};
var VolOut{R,1..T};
var obj;

maximize z: obj;
c0: obj = (sum{t in 1..T, g in G} (PrixElec[t] * Rendement[g] * InTur[g,t])) + sum{r in R} (ValEau[r] * VolLeft[r,T]);
c1{g in G, t in 1..T}: TurMin[g,t] <= InTur[g,t] <= TurMax[g,t];
c2{r in R, t in 1..T}: VolOut[r,t] = sum{g in G: Orig[g]=r} InTur[g,t];
c3{r in R, t in 1..T}: VolIn[r,t] = (sum{g in G: Dest[g]=r && t-Delai[Orig[g]]>=1} InTur[g,t-Delai[Orig[g]]]) + Apport[r,t];
c4{r in R}: VolLeft[r,1] = VolInit[r] + VolIn[r,1] - VolOut[r,1];
c5{r in R, t in 2..T}: VolLeft[r,t] = VolLeft[r,t-1] + VolIn[r,t] - VolOut[r,t];
c6{r in R, t in 1..T}: VolMin[r, t] <= VolLeft[r,t] <= VolMax[r,t];

solve;
display obj;

end;