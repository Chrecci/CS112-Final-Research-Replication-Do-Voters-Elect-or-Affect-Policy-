# delimit;
set more 1;
set mem 100m;
use ~/projects/voting/data/merged/enricoall2, clear;

g       D = 1 if demvoteshare>=.5;
replace D = 0 if demvoteshare<.5;

program define big;

keep if demvoteshare>.25 & demvoteshare<.75;
log using `1', replace;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "SLOPE AND INTERCEPT";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' demvoteshare ;
regress `1' demvoteshare democrat;
regress `1' demvoteshare democrat if demvoteshare>.25 & demvoteshare<.75;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR WINNERS AND LOSERS";
display "REGION 1 IS BELOW THE THRESHOLD, REGION 2 ABOVE IT";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-25";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.25 & demvoteshare<.75 ;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-10";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.4 & demvoteshare<.6 ;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-5";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.45 & demvoteshare<.55 ;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR +/-2";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat if demvoteshare>.48 & demvoteshare<.52 ;



display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "QUARTIC ESTIMATES OF THE DISCONTINUITY FOR ALL OBSERVATIONS";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' D demvoteshare demvs2 ;
regress `1' D demvoteshare demvs2 demvs3 ;
regress `1' D demvoteshare demvs2 demvs3 demvs4;
predict fit;
predict stderror, stdp;

g fit1 =fit if dembin <.5;
g fit2 =fit if dembin >.5;
g stderror1 = stderror if dembin <.5;
g stderror2 = stderror if dembin >.5;

g int1U = fit1 + stderror1;
g int1L = fit1 - stderror1;
g int2U = fit2 + stderror2;
g int2L = fit2 - stderror2;



egen mean`1'=mean(`1'), by(dembin);
gen meanY100=mean`1';

quietly replace meanY100=. if state==. & district==. & dembin==.;

gen sortid=_n;
sort dembin demvoteshare;
quietly by dembin: replace meanY100=. if _n~=1;
sort sortid;
drop sortid;

graph meanY100 fit1 fit2 int1U int1L int2U int2L demvoteshare, l1("Quartic Regression Estimates") 
b2("Democrat Election Vote Share Bins") 
title("`1' Quartic Estimates for All Observations") xline(.5) 
c(.lll[-]l[-]l[-]l[-]) s(oiiii)  sort saving(`1'_quarticall.gph, replace);

translate `1'_quarticall.gph `1'_quarticall.eps, replace;
drop fit* stderr* int* ;


display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "QUARTIC ESTIMATES OF THE DISCONTINUITY FOR 25 to 75%";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' D demvoteshare demvs2 demvs3 demvs4 if demvoteshare<.75 & demvoteshare>.25;
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


graph meanY100 fit1 fit2 int1U int1L int2U int2L  demvoteshare if demvoteshare>=.25 & demvoteshare<=.75, 
b2("Democrat Vote Share") b1(" ") t1(" ") t2(" ") l1(" ") l2("`1'")
xline(.5) xlabel(.25,.5,.75) ylabel(0,50,100)
c(.lll[-]l[-]l[-]l[-]) s(oiiii) sort saving(`1'_quartic25to75.gph, replace);

translate `1'_quartic25to75.gph `1'_quartic25to75.eps, replace;

drop fit* std* int* meanY100;

log close;

end;

cd output-reg5;

rename aclu_vs aclu;
rename lwv_vs lwv;
rename lcv_vs lcv;
rename afge_vs afge;
rename afscme_vs afscme;
rename aft_vs aft;
rename bctd_vs bctd;
rename uaw_vs uaw;
rename cc_vs cc;
rename ccus1_vs ccus;
rename acu_vs acu;
rename cvvf_vs cvvf;
rename cv_vs cv;
rename lfs_vs lfs;
rename ntu_vs ntu;
rename twr_vs twr;



* Liberal;
big nomada;
big realada;
big lagada;
big aclu;
big lwv;

* Environment;
big lcv;

* Unions;
big afge;
big afscme;
big aft;
big bctd;
big uaw;

* Conservative;
big cc;
big ccus;
big acu;

* Christian;
big cvvf;
big cv;
 
* No taxes;
big lfs;
big ntu;
big twr;



/*dropping AL districts because one outlier could skew the results*/;
drop if district==99;

graph using  uaw_quartic25to75 aft_quartic25to75 afge_quartic25to75
             lcv_quartic25to75,
             margin(5) saving(combined3, replace);
translate combined3.gph combined3.eps, replace;

graph using lwv_quartic25to75 aclu_quartic25to75
            twr_quartic25to75,
            margin(5) saving(combined4, replace);
translate combined4.gph combined4.eps, replace;


graph using lfs_quartic25to75 cc_quartic25to75
            ccus_quartic25to75 cvvf_quartic25to75,
            margin(5) saving(combined5, replace);
translate combined5.gph combined5.eps, replace;


graph using  acu_quartic25to75 cv_quartic25to75 ntu_quartic25to75,
             margin(5) saving(combined6, replace);
translate combined6.gph combined6.eps, replace;


cd ..;


program drop _all;


