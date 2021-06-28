capture log close
log using "~/Desktop/LIFE-M/temp/data_exercise", replace
* Clean dataset for analysis
* Replicate JEL descriptive statistics and IGM elasticity
* Alex Coblin

set more off

blah blah blah
	****** Generate relavant controls and Clean census data
	use "$temp/lifem_census_merge_tr0", clear
	* Generate age controls
	local age_vars age_g2 age_g1_s1 age_g1_s2
	foreach var of varlist `age_vars' {
	gen `var'_2=`var'^2
	gen `var'_3=`var'^3
	gen `var'_4=`var'^4
	}
	
	gen white_g2 = (race_g2==1)
	replace white_g2 = . if race_g2==.
	gen nonwhite_g2 = 1- white_g2
	gen black_g2 = (race_g2==2)
	replace black_g2 = . if race_g2==.
	recode school_g2 (1=0) (2=1), gen(attendance_g2)
		
	gen ohio_g2 = 0
	replace ohio_g2=1 if statefips_g2==39	
	replace ohio_g2 = . if statefips_g2==.
	
	* fix wage variable
	local incwage_vars incwage_g2 incwage_g1_s1 incwage_g1_s2
	foreach var of varlist `incwage_vars'{
	replace `var'=. if `var'>=999998
	replace `var'=. if `var'<=0
	replace `var'=5001 if `var'>5001 & `var'<.
	}
	
	gen shtopcode_g2 = (incwage_g2==5001)
	replace shtopcode_g2 = . if incwage_g2==.
	gen shtopcode_g1_s1 = (incwage_g1_s1==5001)
	replace shtopcode_g1_s1 = . if incwage_g1_s1==.
	gen shtopcode_g1_s2 = (incwage_g1_s2==5001)
	replace shtopcode_g1_s2 = . if incwage_g1_s2==.

	* Standardize variables
	foreach x of varlist incwage_g2 incwage_g1_s1 higrade_g2 higrade_g1_s1 incwage_g1_s2 higrade_g1_s2 {
	sum `x'
	gen std_`x' = (`x' - r(mean))/r(sd)
	gen ln_std_`x' = ln(std_`x')
	gen ln_`x' = ln(`x')
	}
	
	* add labels to variables
	label variable age_g2 			"Age (G2)"
	label variable age_g1_s1 		"Father's Age (G1)"
	label variable age_g1_s2 		"Mother's Age (G1)"
	label variable white_g2 		"Race-white (G2)"
	label variable race_g2			"Race (G2)"
	label variable nonwhite_g2		"Race-nonwhite (G2)"
	label variable black_g2			"Race-black (G2)"
	label variable ohio_g2			"Ohio born (G2)"
	label variable incwage_g2		"Income (G2)"
	label variable incwage_g1_s1	"Father Income (G1)"
	label variable incwage_g1_s2	"Mother Income (G1)"
	label variable sex_g2			"Sex (G2)"
	label variable shtopcode_g2		"Share with topcode income (G2)"
	label variable shtopcode_g1_s1	"Share of fathers with topcode income (G1)"
	label variable shtopcode_g1_s2	"Share of mothers with topcode income (G1)"
	label variable higrade_g2		"Highest grade of schooling (G2)"
	label variable higrade_g1_s1	"Father highest grade of schooling (G1)"
	label variable higrade_g1_s2	"Mother highest grade of schooling (G1)"
	label variable ln_incwage_g2 	"Log Income (G2)"
	label variable ln_incwage_g1_s1 	"Log Father Income (G1)"
	label variable ln_incwage_g1_s2 	"Log Mother Income (G1)"
	
	saveold "$temp/lifem_census_cleaned_tr0", replace
