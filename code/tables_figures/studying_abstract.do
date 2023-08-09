
global education educ_3_low

use "data/temporary/filtered_dems_SES", clear
drop if missing(gwtall)

rename edlev edlevLFS
do "code/process_LFS/create_education_variables.do"


do "code/aggregate_SOC2000.do"

merge m:1 bsoc00Agg using  "data/temporary/SES_occupation_key", nogen 

keep if  n_years==4

rename $education education
rename bsoc00Agg occupation


do "code/process_SES/compute_skill_indexes.do"

eststo clear
foreach variable in $abstract {
    eststo `variable': regress `variable' ibn.education, vce(r) nocons
    eststo `variable'_n: regress `variable' i.education, vce(r) 
}

esttab $abstract 


grscheme, ncolor(10) style(tableau)
coefplot $abstract, keep(*education) vert recast(connected) nooffset

graph export "results/figures/abstract_by_education_graph.pdf", replace

coefplot *_n, keep(*education) vert recast(connected) nooffset base

graph export "results/figures/abstract_by_education_graph_net.pdf", replace

