param T;
set CONTRATS;
set ZONES;
set ARCS;
set STOCKAGES;

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

# PARAM STOCKS
# ------------
param NivInit{STOCKAGES};
param NivFin{STOCKAGES};
param NivMin{STOCKAGES};
param NivMax{STOCKAGES};
param InjMin{STOCKAGES};
param InjMax{STOCKAGES};
param SouMin{STOCKAGES};
param SouMax{STOCKAGES};
param LocStock{STOCKAGES} symbolic;
param PrixMouv{STOCKAGES};


# VARIABLES
var obj;
var transported{ARCS, 1..T} >= 0;
var penaltyMore{ZONES, 1..T} >= 0;
var penaltyLess{ZONES, 1..T} >= 0;
var taken{CONTRATS, 1..T} >= 0;
var takenToZone{ZONES, 1..T} >= 0;

var inj{STOCKAGES, 1..T} >= 0;
var sou{STOCKAGES, 1..T} >= 0;
var niv{STOCKAGES, 1..T} >= 0;


minimize o: obj;
c0: obj = sum{a in ARCS, t in 1..T} transported[a,t]*PrixTrans[a] +
          sum{z in ZONES, t in 1..T} (penaltyMore[z,t]*PrixEcartP[z] + penaltyLess[z,t]*PrixEcartN[z]) +
          sum{c in CONTRATS, t in 1..T} taken[c,t] * PrixContrats[c] +
          sum{s in STOCKAGES} (PrixMouv[s] * sum{t in 1..T} (inj[s,t] + sou[s,t]));

# ARC CONSTRAINT
c1{a in ARCS, t in 1..T}: TransMin[a] <= transported[a,t] <= TransMax[a];

# EQUILIBRAGE
c2{z in ZONES, t in 1..T}: Demande[z,t] + sum{a in ARCS: Orig[a]=z} transported[a,t] + penaltyMore[z,t] + sum{s in STOCKAGES: LocStock[s]=z} inj[s,t] = 
                           takenToZone[z,t] + sum{a in ARCS: Dest[a]=z} transported[a,t] + penaltyLess[z,t] + sum{s in STOCKAGES: LocStock[s]=z} sou[s,t];

# CONTRAT
c3{c in CONTRATS, t in 1..T}: EnlevementMin[c,t] <= taken[c,t] <= EnlevementMax[c,t];
c4{c in CONTRATS}: sum{t in 1..T} taken[c,t] >= Quota[c];
c5{z in ZONES, t in 1..T}: takenToZone[z,t] = sum{c in CONTRATS} taken[c,t]*ContratSplit[c,z];

# STOCKAGE
c6{s in STOCKAGES, t in 1..T}: InjMin[s] <= inj[s,t] <= InjMax[s];
c7{s in STOCKAGES, t in 1..T}: SouMin[s] <= sou[s,t] <= SouMax[s];
c8{s in STOCKAGES, t in 1..T}: NivMin[s] <= niv[s,t] <= NivMax[s];
c9{s in STOCKAGES}: niv[s,1] = NivInit[s];
c10{s in STOCKAGES}: niv[s,T] - sou[s,T] + inj[s,T] = NivFin[s];
c11{s in STOCKAGES, t in 1..T-1}: niv[s,t+1] = niv[s,t] + inj[s,t] - sou[s,t];

solve;
display obj;
end;