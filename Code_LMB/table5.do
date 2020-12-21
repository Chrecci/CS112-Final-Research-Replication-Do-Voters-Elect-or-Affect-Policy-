# delimit;
set mem 100m;

******************************;
** Lagged values;
******************************;
use ~/projects/voting/data/merged/enricoall2, clear;
* there are two obs for each state district year;
sort state district year;
by state district year: g n = _n;
keep if n<=2;

replace year = year +2;
g lagged = realada;
keep state district year n lagged;
sort state district year n;
save tmp, replace;

******************************;
** Simultaneous values;
******************************;
use ~/projects/voting/data/merged/enricoall2, clear;
sort state district year;
by state district year: g n = _n;
keep if n<=2;

drop lagada*;
sort state district year n;
merge state district year n using tmp;
rm tmp.dta;

* drop if last time was a redistricting year;
drop if year ==1952 | year==1962 | year==1972 | year==1982 | year==1992;
keep if lagdemvoteshare>.48 & lagdemvoteshare<.52;
drop democrat;
g       democrat = 1 if demvoteshare>=.5;
replace democrat = 0 if demvoteshare<.5;

g       lagdemocrat = 1 if lagdemvoteshare >=.5;
replace lagdemocrat = 0 if lagdemvoteshare <.5;
g    score = realada;
g lagscore = lagged;
egen id = group(state district year n);
keep if score ~=. & lagscore ~=. ;
keep if democrat~=. & lagdemocrat ~=. ;
keep if id ~=.;



******************************;
* REGRESSION;
* 3 GROUPS;
* group 1 is always takers, 
* group 3 is never takers, 
* group 2 are those affected by the IV;
******************************;
tab democrat lagdemocrat , row col;
* Instead of entering the NW entry and the SW entry by hand,
* the following code grab the two entries and make them 2 constants, a11 and a22;
egen a1 = mean(democrat) if lagdemocrat==0;
egen a2 = mean(democrat) if lagdemocrat==1;
replace a1 = (1-a1)*100;
replace a2 = (1-a2)*100;
egen a11 = mean(a1);
egen a22 = mean(a2);

xtile x1 = demvoteshare if lagdemocrat==1 , nq(100);
xtile x2 = demvoteshare if lagdemocrat==0 , nq(100);
summ a11 a22 x1 x2;

gen     group=1 if (lagdemocrat==0 & democrat==1) | (lagdemocrat==1 & x1> a11);
replace group=3 if (lagdemocrat==1 & democrat==0) | (lagdemocrat==0 & x2< a22);
replace group=2 if group==.;


sort group lagdemocrat;
by group lagdemocrat: summ score;
by group: reg score  lagdemocrat ,   cluster(id);


