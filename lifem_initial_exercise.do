capture log close
log using "~/Desktop/LIFE-M/temp/data_exercise", replace
* Complete part 2 of data exercise from LIFE-M orientation:
* Replicate JEL descriptive statistics and IGM elasticity
* Alex Coblin

set more off

global path 	"~/Google Drive/Shared drives/LIFE-M Lab 2021"
global data 	"$path/LIFE-M Public Data/beta versions/v2"
global ipums 	"$path/User guide"
global temp  	"~/Desktop/LIFE-M/temp"

	* Generate files for dads
	use "$data/lifem_master_public_v2.dta", clear
	keep if generation==1 & training==0 & sex == 1 & ///
		link_census40==1 & inrange(link_census40_precision,0.97,1)
	keep lifem_id statefips
	rename statefips statefips_g1_s1
	* Merge dad histid to lifem_id
	merge 1:1 lifem_id using "$data/lifem_using_census_v2", keepusing(histid_1940) keep(3) nogen
	drop if histid_1940 == ""
	rename lifem_id poploc
	rename histid_1940 histid_1940_g1_s1
	saveold "$temp/g1_s1_tr0", replace

	* Generate files for moms
	use "$data/lifem_master_public_v2.dta", clear
	keep if generation==1 & training==0 & sex == 2 & ///
		link_census40==1 & inrange(link_census40_precision,0.97,1)
	keep lifem_id statefips
	rename statefips statefips_g1_s2
	* Merge mom histid to lifem_id
	merge 1:1 lifem_id using "$data/lifem_using_census_v2", keepusing(histid_1940) keep(3) nogen
	drop if histid_1940 == ""
	rename lifem_id momloc
	rename histid_1940 histid_1940_g1_s2
	saveold "$temp/g1_s2_tr0", replace

	* Generate file for children (g2)
	use "$data/lifem_master_public_v2.dta", clear
	keep if generation==2 & training==0 & ///
		link_census40==1 & inrange(link_census40_precision,0.97,1)
	keep lifem_id poploc momloc sex statefips
	rename statefips statefips_g2
	rename sex sex_g2
	merge 1:1 lifem_id using "$data/lifem_using_census_v2", keepusing(histid_1940) keep(3) nogen
	rename histid_1940 histid_1940_g2
	drop if histid_1940_g2 == ""
	saveold "$temp/g2_tr0", replace

	* Merge parent/child files
	use "$temp/g2_tr0", clear
	merge m:1 poploc using "$temp/g1_s1_tr0"
	drop if _merge == 2
	rename _merge _merge_g1_s1
	merge m:1 momloc using "$temp/g1_s2_tr0"
	drop if _merge == 2
	keep if _merge == 3 | _merge_g1_s1 == 3
	drop _merge*
	drop lifem_id poploc momloc
	gen fam_id = _n
	reshape long histid_1940_ statefips_, i(fam_id sex_g2) j(gen_sex) string
	drop if histid_1940_ == ""
	rename histid_1940 histid
	saveold "$temp/lifem_census_crosswalk", replace
	
	* Merge IPUMS data to LIFEM crosswalk
	use "$ipums/ipums-assignment.dta", clear
	local censusvars "histid statefip sex age race bpl incwage school higrade"
	keep `censusvars'
	merge 1:m histid using "$temp/lifem_census_crosswalk", keep(3) nogen
	rename histid histid_
	rename statefip census_statefip
	local censusvars "census_statefip sex age race bpl incwage school higrade"
	reshape wide histid_ statefips_ `censusvars', i(fam_id sex_g2) j(gen_sex) string
	drop fam_id
	saveold "$temp/lifem_census_merge", replace
	
	
	
	****** Stuff from other exercise
	use "$temp/lifem_census_merge", clear
	* Generate age controls for son and dad
	local age_vars ageg1_s1 ageg1_s2 ageg2
	foreach var of varlist `age_vars' {
	gen `var'_2=`var'^2
	gen `var'_3=`var'^3
	gen `var'_4=`var'^4
	}
	
	gen white_g2 = (raceg2==1)
	replace white_g2 = . if raceg2==.
	gen nonwhite= 1- white_g2
	gen black_g2 = (raceg2==2)
	replace black_g2 = . if raceg2==.
	recode schoolg2 (1=0) (2=1), gen(attendance_g2)
		
	gen ohio_g2 = 0
	replace ohio_g2=1 if statefips_g2==39	
	replace ohio_g2 = . if statefips_g2==.
	
	* fix wage variable
	local incwage_vars incwageg2 incwageg1_s1 incwageg1_s2
	foreach var of varlist `incwage_vars'{
	replace `var'=. if `var'>=999998
	replace `var'=. if `var'<=0
	replace `var'=5001 if `var'>5001 & `var'<.
	}
	
	gen shtopcode_g2 = (incwageg2==5001)
	replace shtopcode_g2 = . if incwageg2==.
	gen shtopcode_g1_s1 = (incwageg1_s1==5001)
	replace shtopcode_g1_s1 = . if incwageg1_s1==.
	gen shtopcode_g1_s2 = (incwageg1_s2==5001)
	replace shtopcode_g1_s2 = . if incwageg1_s2==.

	* Standardize variables
	foreach x of varlist incwageg2 incwageg1_s1 higradeg2 higradeg1_s1 incwageg1_s2 higradeg1_s2 {
	sum `x'
	gen std_`x' = (`x' - r(mean))/r(sd)
	gen ln_std_`x' = ln(std_`x')
	gen ln_`x' = ln(`x')
	}
	
	* Limit sample of sons/dads by age
	local control ageg* ohio_g2
	local r replace		


	* Regress son outcome on dad outcome to estimate IG elasticity for given variable
	loc outcomes "incwage ln_incwage std_incwage ln_std_incwage higrade ln_higrade std_higrade ln_std_higrade"
	loc i=0
	foreach x of local outcomes {
		reg  `x'_g2 `x'_g1_s1 `control'
		if `i'==0 	outreg2 using "${temp}/full_igresults.xls", replace
		if `i'>0 	outreg2 using "${temp}/full_igresults.xls", append
		loc ++i
		}

	* Summary stats
	estpost summarize age yob race black attendance shtopcode* inc* linc* educ* leduc*, d
	esttab using "${out}/sumstats_tr`t'.xls", cells("count mean sd min max p25 p50 p75 p90") tab replace

	
	
