capture log close
log using "~/Desktop/LIFE-M/temp/data_exercise", replace
* Complete data exercise from orientation:
* Replicate JEL descriptive statistics and IGM elasticity
* Alex Coblin

set more off

global path 	"~/Google Drive/Shared drives/LIFE-M Lab 2021"
global data 	"$path/LIFE-M Public Data/beta versions/v2"
global ipums 	"$path/User guide"
global temp  	"~/Desktop/LIFE-M/temp"

	* Generate files for full sample
	use "$data/lifem_master_public_v2.dta", clear
	keep if generation==1 & training==0 & ///
	link_census40==1 & inrange(link_census40_precision,0.97,1)
	keep lifem_id sex statefips
	rename lifem_id poploc if sex == 1
	rename lifem_id momloc if sex == 2
	saveold "$temp/g1_tr0", replace

	use "$data/lifem_master_public_v2.dta", clear
	keep if generation==2 & training==0 & ///
	link_census40==1 & inrange(link_census40_precision,0.97,1)
	keep lifem_id poploc sex
	saveold "$temp/g2_tr0", replace

	* Merge parent/child files
	use "$temp/g2_tr0", clear
	merge m:1 poploc using "$temp/g1_tr0"
	merge m:1 momloc
	
	