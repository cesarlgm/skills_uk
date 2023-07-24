*Create dlnA estimates
*===========================================================================================================

import excel "data\output\pi_estimates_twoeq.xlsx", sheet("Sheet1") firstrow clear

rename estimate pi
rename se pi_se

drop t 

merge m:1 occupation using  "data/output/sigma_estimates_twoeq_same_inst", keep(3) nogen


generate dlnA=pi*beta

save "data/output/dlna_estimates_twoeq_same_inst", replace

