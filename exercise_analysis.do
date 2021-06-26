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
	forv s = 1(1)2 {
		reg  `x'_g2 `x'_g1_s`s' `control_dad' if sex_g2 == `s'
		if `i'==1 	outreg2 using "$output/full_igresults_g2s`s'_g1s`s'.xls", replace
		if `i'>1 	outreg2 using "$output/full_igresults_g2s`s'_g1s`s'.xls", append
		
		replace outname = "`x'" if _n == `i'
		replace b = _b[`x'_g1_s`s'] if _n==`i'
		replace se = _se[`x'_g1_s`s'] if _n==`i'
		
		
		loc ++i
		}
		}


	*** Figures
	grstyle init
	grstyle set color hue, n(2)
	grstyle set symbol
	grstyle set legend 1, nobox inside
	
	
	twoway (histogram age_g2 if sex_g2==1, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram age_g1_s1, fcolor(none) lcolor(black) discrete freq), legend( label(1 "sons") label(2 "fathers"))  ylab(, angle(horizontal)) xlab(0(5)100) graphregion(color(white)) xtitle("Age in 1940")
	gr export "${output}/histage_tr0_g2s1_g1s1.png", replace
	
	twoway (histogram age_g2 if sex_g2==1, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram age_g1_s2, fcolor(none) lcolor(black) discrete freq), legend( label(1 "sons") label(2 "mothers"))  ylab(, angle(horizontal)) xlab(0(5)100) graphregion(color(white)) xtitle("Age in 1940")
	gr export "${output}/histage_tr0_g2s1_g1s2.png", replace
	
	twoway (histogram age_g2 if sex_g2==2, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram age_g1_s1, fcolor(none) lcolor(black) discrete freq), legend( label(1 "daughters") label(2 "fathers"))  ylab(, angle(horizontal)) xlab(0(5)100) graphregion(color(white)) xtitle("Age in 1940")
	gr export "${output}/histage_tr0_g2s2_g1s1.png", replace
	
	twoway (histogram age_g2 if sex_g2==2, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram age_g1_s2, fcolor(none) lcolor(black) discrete freq), legend( label(1 "daughters") label(2 "mothers"))  ylab(, angle(horizontal)) xlab(0(5)100) graphregion(color(white)) xtitle("Age in 1940")
	gr export "${output}/histage_tr0_g2s2_g1s2.png", replace
	
	twoway (kdensity incwage_g2 if sex_g2 == 1) (kdensity incwage_g1_s1), legend( label(1 "sons") label(2 "fathers")) xtitle("Income in 1940") graphregion(color(white))
	gr export "${output}/densincome_tr0_g2s1_g1s1.png", replace

	twoway (kdensity incwage_g2 if sex_g2 == 2) (kdensity incwage_g1_s1), legend( label(1 "daughters") label(2 "fathers")) xtitle("Income in 1940") graphregion(color(white))
	gr export "${output}/densincome_tr0_g2s2_g1s1.png", replace

	twoway (kdensity incwage_g2 if sex_g2 == 1) (kdensity incwage_g1_s2), legend( label(1 "sons") label(2 "mothers")) xtitle("Income in 1940") graphregion(color(white))
	gr export "${output}/densincome_tr0_g2s1_g1s2.png", replace

	twoway (kdensity incwage_g2 if sex_g2 == 2) (kdensity incwage_g1_s2), legend( label(1 "daughters") label(2 "mothers")) xtitle("Income in 1940") graphregion(color(white))
	gr export "${output}/densincome_tr0_g2s2_g1s2.png", replace

	twoway (histogram higrade_g2 if sex_g2 == 1, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram higrade_g1_s1, fcolor(none) lcolor(black) discrete freq), legend( label(1 "sons") label(2 "fathers"))  ylab(, angle(horizontal)) xlab(0(2)20) graphregion(color(white)) xtitle("Years of education in 1940")
	gr export "${output}/histeduc_tr0_g2s1_g1s1.png", replace

	twoway (histogram higrade_g2 if sex_g2 == 1, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram higrade_g1_s2, fcolor(none) lcolor(black) discrete freq), legend( label(1 "sons") label(2 "mothers"))  ylab(, angle(horizontal)) xlab(0(2)20) graphregion(color(white)) xtitle("Years of education in 1940")
	gr export "${output}/histeduc_tr0_g2s1_g1s2.png", replace

	twoway (histogram higrade_g2 if sex_g2 == 2, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram higrade_g1_s1, fcolor(none) lcolor(black) discrete freq), legend( label(1 "daughters") label(2 "fathers"))  ylab(, angle(horizontal)) xlab(0(2)20) graphregion(color(white)) xtitle("Years of education in 1940")
	gr export "${output}/histeduc_tr0_g2s2_g1s1.png", replace

	twoway (histogram higrade_g2 if sex_g2==2, color(midgreen) discrete freq ylabel(,format(%9.0g))) || (histogram higrade_g1_s2, fcolor(none) lcolor(black) discrete freq), legend( label(1 "daughters") label(2 "mothers"))  ylab(, angle(horizontal)) xlab(0(2)20) graphregion(color(white)) xtitle("Years of education in 1940")
	gr export "${output}/histeduc_tr0_g2s2_g1s2.png", replace

	
