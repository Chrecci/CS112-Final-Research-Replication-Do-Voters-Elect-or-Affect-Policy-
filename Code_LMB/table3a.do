# delimit;
set mem 100m;


******************************;
** Lagged values;
******************************;
use ~/projects/voting/data/merged/enricoall4, clear;
* there are two obs for each state district year;
sort state district year;
by state district year: g n = _n;
keep if n<=2;

replace year = year +2;
g lagged_nom = dwnom1;
g lagged_rank = rankorder1;
keep state district year n lagged_nom lagged_rank;
sort state district year n;
save tmp, replace;

******************************;
** Simultaneous values;
******************************;
use ~/projects/voting/data/merged/enricoall4, clear;
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


* OPTION 1;
g    score = dwnom1;
g lagscore = lagged_nom;
* dwnom1 can be used only after mid 70s;
replace score =. if year <= 1975;
replace lagscore =. if year <= 1975;
* OPTION 2;
*g    score = rankorder1;
*g lagscore = lagged_rank;

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






