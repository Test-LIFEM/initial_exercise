capture log close
log using "~/Desktop/LIFE-M/temp/master_data_exercise", replace
* Master dofile for LIFE-M data exercise 
* Alex Coblin

set more off

global path 	"~/Google Drive/Shared drives/LIFE-M Lab 2021"
global data 	"$path/LIFE-M Public Data/beta versions/v2"
global ipums 	"$path/User guide"
global output	"~/Dropbox/LIFEM_shared/output"
global temp  	"~/Dropbox/LIFEM_shared/temp"
global git 		"~/GitHub/initial_exercise"


	do "$git/create_lifem_census_merge.do"		// Generates extract from LIFE-M master and merges to 1940 Census
												// 	inputs: 	$data/lifem_master_public_v2.dta
												//				$data/lifem_using_census_v2
												//				$ipums/ipums-assignment.dta
												//	outputs:	$temp/lifem_census_merge
												
