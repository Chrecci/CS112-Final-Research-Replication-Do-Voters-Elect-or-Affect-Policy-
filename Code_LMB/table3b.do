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
g lagged = eq_Dlead;
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
g    score = eq_Dlead;
g lagscore = lagged;
egen id = group(state district year n);
keep if score ~=. & lagscore ~=. ;
keep if democrat~=. & lagdemocrat ~=. ;
keep if id ~=.;



******************************;
* REGRESSION
******************************;
reg   score lagdemocrat,             cluster(id);
reg   score democrat,             cluster(id);
reg   democrat lagdemocrat,          cluster(id);






