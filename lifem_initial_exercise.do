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
	
	saveold "$temp/lifem_census_merge", replace
	
	
