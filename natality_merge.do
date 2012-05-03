/* natality_merge.do */
/* merges 2000 - 2004 CDC Natality data & drops irrelevant records & vars */
/* data from: http://www.nber.org/data/vital-statistics-natality-data.html */
/* RFBoyce 03 May 2012 */

clear

/* Stata needs 6G of mem to run this prg.  This will freeze up a personal computer - use with caution */
// set mem 6g

set more off

//cd ~/Documents/CPDS/Summer
//cd ./Summer
cd ~/shared_space/sacerdot/natl_orig

/* data from 2000 - 2002 have the same varnames */
foreach y in 2000 2001 2002{
	use ./natl`y'
	gen year = `y'
	/* gen a state var whose varnam matches later datasets' state var */
	gen state = stresfip
	label variable state "State of residence" 
	label define state 1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" ///
		15 "HI" 16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" ///
		27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" 37 "NC" 38 "ND" ///
		39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" ///
		53 "WA" 54 "WV" 55 "WI" 56 "WY"
	label values state state
	/* drop vars that won't be used in analysis */
	drop anemia cardiac lung herpes hydra hemo incervix renal rh uterine othermr amnio monitor induct stimula        ///
	tocol ultras otherob febrile meconium rupture abruptio preplace excebld seizure precip prolong dysfunc      ///
	breech cephalo cord anesthe distress otherlb nanemia injury alcosyn hyaline meconsyn venl30 ven30m nseiz    ///
	otherab anen spina hydro microce nervous heart circul rectal tracheo omphalo gastro genital renalage urogen ///
	cleftlp adactyly clubfoot hernia musculo downs chromo othercon obstrc clabor abnml congan
	/* recode vars with mis-matching data types */
	destring cntyrfip smsarfip mraceimp dmarimp mageimp flgbwimp, replace
	/* keep only records from states that use the "unrevised" tobacco use question */
	keep if inlist(state, 2, 1, 5, 4, 8, 9, 11, 10, 13, 15, 19, 17, 18, 20, 22, 25, 24, 23, 26, 27, ///
		29, 28, 30, 37, 38, 31, 34, 35, 32, 39, 40, 41, 44, 46, 48, 49, 51, 50, 55, 54, 56)
	tab state, missing 
	/* create var that captures tob use during pregnancy */
	gen tobpreg = tobacco
	save ./natl`y'_rev, replace
}

clear

/* data from 2003 - 2004 have the same varnames */
foreach y in 2003 2004{
	use ./natl`y'
	gen year = `y'
	label define state 1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" ///
		15 "HI" 16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" ///
		27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" 37 "NC" 38 "ND" ///
		39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" ///
		53 "WA" 54 "WV" 55 "WI" 56 "WY"
	/* encode string state var as num values */
	encode mrstate, generate(state) label(state) 
	label variable state "State of residence" 
	/* recode vars with mis-matching data types */
	destring mraceimp, replace
	/* keep only records from states that use the "unrevised" tobacco use question */
	keep if inlist(state, 2, 1, 5, 4, 8, 9, 11, 10, 13, 15, 19, 17, 18, 20, 22, 25, 24, 23, 26, 27, ///
		29, 28, 30, 37, 38, 31, 34, 35, 32, 39, 40, 41, 44, 46, 48, 49, 51, 50, 55, 54, 56)
 	/* drop variables that won't be used for analysis */
 	drop urf* uop* uld* uab* uca*
	tab state, missing 
	/* create var that captures tob use during pregnancy */
	gen tobpreg = tobuse
	save ./natl`y'_rev, replace
}

clear

/* merge 2000 - 2004 datasets into one file */
use ./natl2000_rev
foreach y in 2001 2002 2003 2004{
	append using ./natl`y'_rev
	compress
}
save ./natl_master, replace

 /* check data */
tab state year, missing
