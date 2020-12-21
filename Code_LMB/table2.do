# delimit;
set more 1;
set mem 100m;
use ~/projects/voting/data/merged/enricoall2, clear;
g       D = 1 if demvoteshare>=.5;
replace D = 0 if demvoteshare<.5;

drop  demvs2 demvs3 demvs4;
orthpoly demvoteshare, deg(4) generate(demvs demvs2 demvs3 demvs4);

program define big;
log using `1', replace;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "TTEST ESTIMATES FOR WINNERS AND LOSERS";
display "REGION 1 IS BELOW THE THRESHOLD, REGION 2 ABOVE IT";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' democrat, cluster(clusterid);

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

regress `1' D demvoteshare demvs2 demvs3 demvs4, cluster(clusterid);
quietly predict yhat;

egen mean`1'=mean(`1'), by(dembin);
gen meanY100=mean`1';

quietly replace meanY100=. if state==. & district==. & dembin==.;

gen sortid=_n;
sort dembin demvoteshare;
quietly by dembin: replace meanY100=. if _n~=1;
sort sortid;
drop sortid;

graph meanY100 yhat demvoteshare, l1("Quartic Regression Estimates") 
b2("Democrat Election Vote Share Bins") 
title("`1' Quartic Estimates for All Observations") xline(.5) 
c(.ll) s(oii) sort saving(`1'_quarticall.gph, replace);

translate `1'_quarticall.gph `1'_quarticall.eps, replace;

drop yhat;

display "                       ";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "`1'";
display "QUARTIC ESTIMATES OF THE DISCONTINUITY FOR 25 to 75%";
display "@@@@@@@@@@@@@@@@@@@@@@@";
display "                       ";

regress `1' D demvoteshare demvs2 demvs3 demvs4 if demvoteshare<.75 & demvoteshare>.25, cluster(clusterid);
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



graph meanY100 fit1 fit2 int1U int1L int2U int2L demvoteshare if demvoteshare>=.25 & demvoteshare<=.75, 
b2("Democrat Vote Share") b1(" ") t1(" ") t2(" ") l1(" ") l2("`1'")
xline(.5) xlabel(.25,.5,.75) ylabel
c(.ll[-]l[-]l[-]l[-]l[-]) s(oiiii)  sort saving(`1'_quartic25to75.gph, replace);

translate `1'_quartic25to75.gph `1'_quartic25to75.eps, replace;

drop fit* std* int* meanY100;

log close;

end;

cd output-reg4;

big pcturban;

/*now generating region and candidates variables*/;

gen south=0;
replace south=1 if state>=41 & state<=56;
gen north=0;
replace north=1 if state>=1 & state<=37;
gen west=0;
replace west=1 if state>=61;
g logincome = log(realincome);
gen pcteligible=votingpop/totpop;
gen     college = 1 if collegeattend >1 ;
replace college = 0 if collegeattend ==1 ;
gen     ivy = 1 if collegeattend ==2 ;
replace ivy = 0 if collegeattend ==0 | collegeattend >2;
gen     military = 1 if militaryservice >0 ;
replace military = 0 if militaryservice ==0 ;
gen     profession = 1 if lastoccup_shrt >= 2 & lastoccup_shrt <= 4 ;
replace profession = 0 if lastoccup_shrt <= 1 | lastoccup_shrt > 4 ;
g tenure = int(yrsofserv/100) ;
gen     sex2  = 0 if sex ==1;
replace sex2  = 1 if sex ==2;

rename realincome income;
rename pctblack black;
rename pcteligible eligible;
rename pcthighschl high_school;

big south;
big north;
big west;
big high_school;
big medianincome;
big logincome;
big income;
big black;
big eligible;
big lagdemvoteshare;


big sex;
big college;
big ivy;
big military;
big profession;
big tenure;
big age;

/*dropping AL districts because one outlier could skew the results*/;
drop if district==99;
big totpop;
big votingpop;
big mnfcng;

graph using income_quartic25to75
        high_school_quartic25to75 
        black_quartic25to75 eligible_quartic25to75 , 
        margin(5) saving(combined1, replace);
translate combined1.gph combined1.eps, replace;

graph using 
        votingpop_quartic25to75 
        north_quartic25to75 south_quartic25to75 west_quartic25to75,
        margin(5) saving(combined2, replace);                                    
          
translate combined2.gph combined2.eps, replace;         


graph using sex_quartic25to75 college_quartic25to75 military_quartic25to75 
      profession_quartic25to75 age_quartic25to75 tenure_quartic25to75, 
      margin(5) saving(combined2B, replace);
translate combined2B.gph combined2B.eps, replace;



cd ..;


program drop _all;


