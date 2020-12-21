* Like reg6.do, but only for NOMINATE scores 
*******************************************************************************
# delimit;
set more 1;
set mem 100m;
use ~/projects/voting/data/merged/enricoall4, clear;
drop  demvs2 demvs3 demvs4;

replace dwnom1 = . if year <=1975;

program define big;
log using `1', replace;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR WINNERS AND LOSERS";
display "REGION 1 IS BELOW THE THRESHOLD, REGION 2 ABOVE IT";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat , cluster(clusterid);

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-25";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.25 & demvoteshare<.75 , 
cluster(clusterid);

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-10";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.4 & demvoteshare<.6 , 
cluster(clusterid);

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-5";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.45 & demvoteshare<.55 , 
cluster(clusterid);

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-2";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.48 & demvoteshare<.52 , 
cluster(clusterid);

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "QUARTIC ESTIMATES OF THE DISCONTINUITY FOR ALL OBSERVATIONS";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

orthpoly demvoteshare if demvoteshare<=.5, deg(4) generate(demvs demvs2 demvs3 demvs4);

regress `1' demvoteshare demvs2 demvs3 demvs4 if demvoteshare<.5 , 
cluster(clusterid);
quietly predict yhat1 if demvoteshare<=.5;
quietly predict stderror1, stdp;

drop demvs demvs2 demvs3 demvs4;

orthpoly demvoteshare if demvoteshare >=.5, deg(4) generate(demvs demvs2 demvs3 demvs4);

regress `1' demvoteshare demvs2 demvs3 demvs4 if demvoteshare>.5 , 
cluster(clusterid);
predict yhat2 if demvoteshare>=.5;
predict stderror2, stdp;

summ yhat1 stderror1 yhat2 stderror2 if _n == _N;

disp yhat2[_N]-yhat1[_N];
disp sqrt(stderror1[_N]^2 + stderror2[_N]^2);

egen mean`1'=mean(`1'), by(dembin);
gen meanY100=mean`1';

quietly replace meanY100=. if state==. & district==. & dembin==.;

gen sortid=_n;
sort dembin demvoteshare;
quietly by dembin: replace meanY100=. if _n~=1;
sort sortid;
drop sortid;

g int1U = yhat1 + 2*stderror1;
g int1L = yhat1 - 2*stderror1;
g int2U = yhat2 + 2*stderror2;
g int2L = yhat2 - 2*stderror2;


graph meanY100 yhat1 yhat2  int1U int1L int2U int2L demvoteshare
, l1(" ") l2(" Nominate score at time t") b1(" ") t1(" ") t2(" ")
b2("Democrat Vote Share at time t")
title(" ") xline(.5) xlabel(0,.5,1) ylabel 
c(.lll[-]l[-]l[-]l[-]) s(oiiii) sort saving(`1'_quarticall.gph, replace);
translate `1'_quarticall.gph `1'_quarticall.eps, replace;

drop yhat1 yhat2 stderror1 stderror2 demvs demvs2 demvs3 demvs4 int*;



display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "QUARTIC ESTIMATES OF THE DISCONTINUITY FOR 25 to 75%";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";                                                  

orthpoly demvoteshare if demvoteshare <=.5 & demvoteshare>.25, deg(4) generate(demvs demvs2 demvs3 demvs4);

regress `1' demvoteshare demvs2 demvs3 demvs4 if demvoteshare<.5 & 
demvoteshare>.25 , cluster(clusterid);
predict yhat1 if demvoteshare<=.5;
predict stderror1, stdp;

drop demvs demvs2 demvs3 demvs4;

orthpoly demvoteshare if demvoteshare >=.5 & demvoteshare<.75, deg(4) generate(demvs demvs2 demvs3 demvs4);

regress `1' demvoteshare demvs2 demvs3 demvs4 if demvoteshare>.5 & 
demvoteshare<.75 , cluster(clusterid);
predict yhat2 if demvoteshare>=.5;
predict stderror2, stdp;

summ yhat1 stderror1 yhat2 stderror2 if _n == _N;
list demvoteshare yhat1 yhat2 stderror1 stderror2 if _n==_N;
disp yhat2[_N]-yhat1[_N];
disp sqrt(stderror1[_N]^2 + stderror2[_N]^2);

graph meanY100 yhat1 yhat2 demvoteshare 
if demvoteshare >=.25 & demvoteshare<=.75, l1("Quartic Regression Estimates") 
b2("Democrat Election Vote Share Bins") 
title("`1'") xline(.5) xlabel(.25,.5,.75) ylabel 
c(.ll) s(oii) sort saving(`1'_quartic25to75.gph, replace);

translate `1'_quartic25to75.gph `1'_quartic25to75.eps, replace;

drop yhat1 yhat2 stderror1 stderror2 meanY100 demvs demvs2 demvs3 demvs4;

log close;

end;

cd output-reg11;

big dwnom1;

cd ..;


program drop _all;


