param T;
set CONTRATS;
set ZONES;
set ARCS;

# PARAM CONTRATS
# --------------
param EnlevementMax{CONTRATS, 1..T};
param EnlevementMin{CONTRATS, 1..T};
param Quota{CONTRATS};
param ContratSplit{CONTRATS, ZONES};
param PrixContrats{CONTRATS};

# PARAM RESEAU
# ------------
param Orig{ARCS} symbolic;
param Dest{ARCS} symbolic;    
param TransMin{ARCS};
param TransMax{ARCS};     
param PrixTrans{ARCS};

# PARAM ZONES
# -----------
param Demande{ZONES, 1..T};
param PrixEcartN{ZONES};
param PrixEcartP{ZONES};

# VARIABLES
var obj;
var transported{ARCS, 1..T} >= 0;
var penaltyMore{ZONES, 1..T} >= 0;
var penaltyLess{ZONES, 1..T} >= 0;
var taken{CONTRATS, 1..T} >= 0;
var takenToZone{ZONES, 1..T} >= 0;


minimize o: obj;
c0: obj = sum{a in ARCS, t in 1..T} transported[a,t]*PrixTrans[a] +
          sum{z in ZONES, t in 1..T} (penaltyMore[z,t]*PrixEcartP[z] + penaltyLess[z,t]*PrixEcartN[z]) +
          sum{c in CONTRATS, t in 1..T} taken[c,t] * PrixContrats[c];

# ARC CONSTRAINT
c1{a in ARCS, t in 1..T}: TransMin[a] <= transported[a,t] <= TransMax[a];

# EQUILIBRAGE
c2{z in ZONES, t in 1..T}: Demande[z,t] + sum{a in ARCS: Orig[a]=z} transported[a,t] + penaltyMore[z,t] = 
                           takenToZone[z,t] + sum{a in ARCS: Dest[a]=z} transported[a,t] + penaltyLess[z,t];

# CONTRAT
c3{c in CONTRATS, t in 1..T}: EnlevementMin[c,t] <= taken[c,t] <= EnlevementMax[c,t];
c4{c in CONTRATS}: sum{t in 1..T} taken[c,t] >= Quota[c];
c5{z in ZONES, t in 1..T}: takenToZone[z,t] = sum{c in CONTRATS} taken[c,t]*ContratSplit[c,z];

solve;
display obj;
end;