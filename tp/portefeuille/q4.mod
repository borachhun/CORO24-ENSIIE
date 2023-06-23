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
param CoeffRedH;
param CoeffRedB;


# VARIABLES
var obj;
var transported{ARCS, 1..T} >= 0;
var penaltyMore{ZONES, 1..T} >= 0;
var penaltyLess{ZONES, 1..T} >= 0;
var taken{CONTRATS, 1..T} >= 0;
var takenToZone{ZONES, 1..T} >= 0;

var inj{STOCKAGES, 0..T} >= 0;
var sou{STOCKAGES, 0..T} >= 0;
var niv{STOCKAGES, 0..T} >= 0;

var alpha{STOCKAGES, 0..T};
var midNiv{STOCKAGES, 0..T} binary;


minimize o: obj;
c0: obj = sum{a in ARCS, t in 1..T} transported[a,t]*PrixTrans[a] +
          sum{z in ZONES, t in 1..T} (penaltyMore[z,t]*PrixEcartP[z] + penaltyLess[z,t]*PrixEcartN[z]) +
          sum{c in CONTRATS, t in 1..T} taken[c,t] * PrixContrats[c] +
          sum{s in STOCKAGES} (PrixMouv[s] * sum{t in 0..(T-1)} (inj[s,t] + sou[s,t]));

# ARC CONSTRAINT
c1{a in ARCS, t in 1..T}: TransMin[a] <= transported[a,t] <= TransMax[a];

# EQUILIBRAGE
c2{z in ZONES, t in 1..T}: Demande[z,t] + sum{a in ARCS: Orig[a]=z} transported[a,t] + penaltyMore[z,t] + sum{s in STOCKAGES: LocStock[s]=z} inj[s,t-1] = 
                           takenToZone[z,t] + sum{a in ARCS: Dest[a]=z} transported[a,t] + penaltyLess[z,t] + sum{s in STOCKAGES: LocStock[s]=z} sou[s,t-1];

# CONTRAT
c3{c in CONTRATS, t in 1..T}: EnlevementMin[c,t] <= taken[c,t] <= EnlevementMax[c,t];
c4{c in CONTRATS}: sum{t in 1..T} taken[c,t] >= Quota[c];
c5{z in ZONES, t in 1..T}: takenToZone[z,t] = sum{c in CONTRATS} taken[c,t]*ContratSplit[c,z];

# STOCKAGE
c6{s in STOCKAGES, t in 0..T-1}: InjMin[s] <= inj[s,t];
c62{s in STOCKAGES, t in 0..T-1}: inj[s,t] <= alpha[s,t] * InjMax[s];

c7{s in STOCKAGES, t in 0..T-1}: SouMin[s] <= sou[s,t];
c72{s in STOCKAGES, t in 0..T-1}: sou[s,t] <= alpha[s,t] * SouMax[s];

c8{s in STOCKAGES, t in 0..T}: NivMin[s] <= niv[s,t] <= NivMax[s];
c9{s in STOCKAGES}: niv[s,0] = NivInit[s];
c10{s in STOCKAGES}: niv[s,T] = NivFin[s];
c11{s in STOCKAGES, t in 1..T}: niv[s,t] = niv[s,t-1] + inj[s,t-1] - sou[s,t-1];

# QUESTION 4
# c12{s in STOCKAGES}: midNiv[s] = niv[s,0] / ((NivMin[s]+NivMax[s])/2);
c13{s in STOCKAGES, t in 1..T}: alpha[s,t] = midNiv[s,t-1] * CoeffRedH + (1 - midNiv[s,t-1]) * CoeffRedB;

c14{s in STOCKAGES, t in 1..T}: ((NivMin[s]+NivMax[s])/2) - niv[s,t-1] >= 10000 * midNiv[s,t-1];


solve;
display obj;
end;