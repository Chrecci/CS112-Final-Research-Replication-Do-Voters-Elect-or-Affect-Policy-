# delimit;
set more 1;
set mem 100m;
use ~/projects/voting/data/merged/enricoall2, clear;
drop  demvs2 demvs3 demvs4;

program define big;

g       d1 = 0 if lagdemvote <=.5;
replace d1 = 1 if lagdemvote >.5;
replace d1 = . if lagdemvote ==.;
tab d1;

g bin2 = int(lagdemvote*100)/100; 
replace dembin = bin2;

log using `1', replace;
drop if state==. & district==. & dembin==.;

sort dembin;
collapse meanY100 = `1', by(dembin);

g x2 = dembin*dembin;
g x3 = dembin*dembin*dembin;
g x4 = dembin*dembin*dembin*dembin;
g       dd1 = 0 if dembin<=.5;
replace dd1 = 1 if dembin>.5;
replace dd1 = . if dembin==.;

reg meanY100 dd1 x2 x3 x4;
predict fit;
predict stderror, stdp;

g fit1 =fit if dembin <.5;
g fit2 =fit if dembin >.5;
g stderror1 = stderror if dembin <.5;
g stderror2 = stderror if dembin >.5;

g int1U = fit1 + 2*stderror1;
g int1L = fit1 - 2*stderror1;
g int2U = fit2 + 2*stderror2;
g int2L = fit2 - 2*stderror2;


g       hat = fit1 if dembin<=.5;
replace hat = fit2 if dembin>.5;
g       upper = int1U if dembin<=.5;
replace upper = int2U if dembin>.5;
g       lower = int1L if dembin<=.5;
replace lower = int2L if dembin>.5;


keep if meanY100 ~=. ;
keep meanY100 hat lower upper dembin;
save coeff, replace;
summ;
stop;



summ  meanY100 dembin fit;

graph meanY100 fit1 fit2 int1U int1L int2U int2L dembin , 
l1(" ") l2("ADA Score, time t") b1(" ") t1(" ") t2(" ")
b2("Democrat Vote Share, time t-1")  xlabel(0,.5,1) ylabel (0,.5,1)
title(" ") xline(.5) 
c(.lll[-]l[-]l[-]l[-]) s(oiiii) sort saving(`1'_reduced.gph, replace);
translate `1'_reduced.gph `1'_reduced.eps, replace;

* xlabel(0,.5,1) ylabel (0,.5,1);

drop meanY100 x2-x4 fit dd1;

log close;

end;

cd output-reg10;

big realada ;
*big democrat;

cd ..;

log close;

program drop _all;


