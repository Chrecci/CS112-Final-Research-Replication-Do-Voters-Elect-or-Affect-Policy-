* like reg2.do but 
* the dependent variable is vote equal to party leadership
**********************************************************************
# delimit;
set more 1;
set mem 100m;
use ~/projects/voting/data/merged/enricoall2, clear;

g       D = 1 if demvoteshare>=.5;
replace D = 0 if demvoteshare<.5;

program define big;

*keep if demvoteshare>.25 & demvoteshare<.75;
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

regress `1' D demvoteshare demvs2 demvs3 demvs4;
quietly predict fit;
predict stderror, stdp;

g fit1 =fit if dembin <.5;
g fit2 =fit if dembin >.5;
g stderror1 = stderror if dembin <.5;
g stderror2 = stderror if dembin >.5;

g int1U = fit1 + 2*stderror1;
g int1L = fit1 - 2*stderror1;
g int2U = fit2 + 2*stderror2;
g int2L = fit2 - 2*stderror2;

egen mean`1'=mean(`1'), by(dembin);
gen meanY100=mean`1';

quietly replace meanY100=. if state==. & district==. & dembin==.;

gen sortid=_n;
sort dembin demvoteshare;
quietly by dembin: replace meanY100=. if _n~=1;
sort sortid;
drop sortid;

graph meanY100 fit1 fit2 int1U int1L int2U int2L demvoteshare, l1("Percent Voted Like Democrat Leader at Time t") 
l2(" ") b1(" ") t1(" ") t2(" ")
b2("Democrat Vote Share at time t") 
title(" ") xline(.5) xlabel(0,.5,1) ylabel(0,.5,1)
c(.lll[-]l[-]l[-]l[-]) s(oiiii) sort saving(`1'_quarticall.gph, replace);

translate `1'_quarticall.gph `1'_quarticall.eps, replace;
drop fit* int* stderr*;


display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "QUARTIC ESTIMATES OF THE DISCONTINUITY FOR 25 to 75%";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' D demvoteshare demvs2 demvs3 demvs4 if demvoteshare<.75 & demvoteshare>.25;
quietly predict yhat;

graph meanY100 yhat demvoteshare if demvoteshare>=.25 & demvoteshare<=.75, 
b2("Democrat Election Vote Share") b1(" ") t1(" ") t2(" ") l1(" ") l2(" ")
xline(.5) xlabel(.25,.5,.75) 
c(.ll) s(oii) sort saving(`1'_quartic25to75.gph, replace);

translate `1'_quartic25to75.gph `1'_quartic25to75.eps, replace;

drop yhat meanY100;

log close;

end;

cd output-reg7;







big eq_Dwhip;
big eq_Dlead;

cd ..;


program drop _all;


