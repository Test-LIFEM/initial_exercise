capture log close
log using "~/Desktop/LIFE-M/temp/data_exercise_analysis", replace
* Complete part 2 of data exercise from LIFE-M orientation:
* Replicate JEL descriptive statistics and IGM elasticity
* Alex Coblin

set more off

	use "$temp/lifem_census_cleaned_tr0", clear
	
	local age_vars age_g2 age_g1_s1 age_g1_s2
	local other_vars sex_g2 white_g2 black_g2 nonwhite_g2 attendance_g2 higrade_* shtopcode* inc* ln_inc*  ohio_g2
	* Summary stats - Full sample
	estpost summarize `age_vars' `other_vars', d 
	esttab using "${output}/full_sumstats.xls", cells("count mean sd min max p25 p50 p75 p90") label tab replace

	* Summary stats - Ohio
	estpost summarize `age_vars' `other_vars' if ohio_g2 == 1, d
	esttab using "${output}/full_sumstats_oh.xls", cells("count mean sd min max p25 p50 p75 p90") tab replace

	* Summary stats - NC
	estpost summarize `age_vars' `other_vars' if ohio_g2 == 0, d
	esttab using "${output}/full_sumstats_nc.xls", cells("count mean sd min max p25 p50 p75 p90") tab replace

	* Limit sample of sons/dads by age
	local control_dad age_g2_* age_g1_s1_* ohio_g2
	local control_mom age_g2_* age_g1_s2_* ohio_g2
	local r replace		


	* Regress son outcome on dad outcome to estimate IG elasticity for given variable
	loc outcomes "incwage ln_incwage std_incwage ln_std_incwage higrade ln_higrade std_higrade ln_std_higrade"
	gen outname = ""
	gen b = .
	gen se = .
	loc i=1
	
	foreach x of local outcomes {
		reg  `x'_g2 `x'_g1_s1 `control_dad'
		if `i'==1 	outreg2 using "${temp}/full_igresults_dad.xls", replace
		if `i'>1 	outreg2 using "${temp}/full_igresults_dad.xls", append
		
		replace outname = "`x'" if _n == `i'
		replace b = _b[`x'_g1_s1] if _n==`i'
		replace se = _se[`x'_g1_s1] if _n==`i'
		
		loc ++i
		
		
		}
