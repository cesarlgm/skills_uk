

log using "results/log_files/skills_available.txt", text replace
descr bchoice-cstats
log close

*Create correlation table
estpost correlate bchoice-cstats, matrix list
est store correlation
esttab correlation using "results/tables/correlation.csv", unstack not noobs compress replace  csv nostar

est clear 
local model_list
foreach variable of varlist bchoice-cstats { 
	qui eststo `variable': reg `variable' i.edlev, 

	local model_list `model_list' || `variable' 
}

coefplot `model_list', vert drop(_cons) ///
	xlabel(1 "D-G" 2 "A-C" 3 "A*" 4 "Bachelor+")

graph export "results/figures/skills_educ.png", replace



foreach variable of varlist bchoice-cstats { 
	qui eststo `variable': reg `variable' i.edlev, 

	local model_list `model_list' || `variable' 
}

foreach variable of varlist bchoice-cstats {
	graph dot (mean) `variable' [fw=gwtall], over(occ_1dig) hor
	graph export "results/figures/skill_graphs/use_`variable'.png", replace
}

do "code/process_LFS/create_education_variables.do"
