

import excel "data\output\pi_estimates_twoeq.xlsx", sheet("Sheet1") firstrow clear

merge m:1 occupation using "data/output/sigma_twoeq", keepusing(sigma)

generate beta_j_inv=sigma/(sigma-1)

generate dlnA=estimate/beta_j_inv



forvalues skill=2/4 {
    summarize estimate if skill==`skill', d 
}


forvalues skill=2/4 {
    summarize dlnA if skill==`skill', d 
}




grscheme, ncolor(7) palette(tableau)

tw (kdensity dlnA if skill==2, lwidth(medthick) ) ///
  (kdensity dlnA if skill==3, lpattern(--)  lwidth(medthick)  ) ///
  (kdensity dlnA if skill==4, lpattern(.-.) lwidth(medthick) ) if inrange(dlnA,-10,10), ///
  legend(ring(0) pos(11) order(1 "Social" 2 "Adaptability" 3 "Abstract")) ///
   xtitle(dlnA{sub:ijt}) ytitle("Density") yscale(range(0 .6))
graph export "results/figures/dlna_estimates_all.png", replace


local figure_name   "results/figures/dlna_estimates.tex"
local figure_path   "figures/"
local figure_list   dlna_estimates_all
local figure_title  "$d\ln A_{ijt}$ estimates"
local figure_notes  "The table shows estimates of $d\ln A_{ijt}$. To improve readibility, the figure excludes estimates outside the -10 and 10 range."
local figure_key    fig:sigma_estimates

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(1) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') nodate




grscheme, ncolor(7) palette(tableau)
tw (kdensity dlnA if skill==4&year==2006, lwidth(medthick) ) ///
  (kdensity dlnA if skill==4&year==2012, lpattern(--)  lwidth(medthick)  ) ///
  (kdensity dlnA if skill==4&year==2017, lpattern(.-.) lwidth(medthick) ) if inrange(dlnA,-10,10), ///
  legend(ring(0) pos(11) order(1 "2006" 2 "2012" 3 "2017")) ///
   xtitle({&pi}{sub:abstract jt}) ytitle("Density") yscale(range(0 .6))

graph export "results/figures/dlna_estimates_abstract.png", replace


grscheme, ncolor(7) palette(tableau)
tw (kdensity dlnA if skill==3&year==2006, lwidth(medthick) ) ///
  (kdensity dlnA if skill==3&year==2012, lpattern(--)  lwidth(medthick)  ) ///
  (kdensity dlnA if skill==3&year==2017, lpattern(.-.) lwidth(medthick) ) if inrange(dlnA,-10,10), ///
  legend(ring(0) pos(11) order(1 "2006" 2 "2012" 3 "2017")) ///
   xtitle({&pi}{sub:Adaptability jt}) ytitle("Density")  yscale(range(0 .6))
graph export "results/figures/dlna_estimates_adaptability.png", replace


grscheme, ncolor(7) palette(tableau)
tw (kdensity dlnA if skill==2&year==2006, lwidth(medthick) ) ///
  (kdensity dlnA if skill==2&year==2012, lpattern(--)  lwidth(medthick)  ) ///
  (kdensity dlnA if skill==2&year==2017, lpattern(.-.) lwidth(medthick) ) if inrange(dlnA,-10,10), ///
  legend(ring(0) pos(11) order(1 "2006" 2 "2012" 3 "2017")) ///
 xtitle({&pi}{sub:social jt}) ytitle("Density")  yscale(range(0 .6))

graph export "results/figures/dlna_estimates_social.png", replace



local figure_name   "results/figures/dlna_time.tex"
local figure_path   "figures/"
local figure_list   dlna_estimates_social dlna_estimates_adaptability dlna_estimates_abstract 
local figure_title  "$d\ln A_{ijt}$ estimates"
local figure_notes  "The table shows estimates of $d\ln A_{abstract,jt}$. To improve readibility, the figure excludes estimates outside the -10 and 10 range."
local figure_key    fig:sigma_time
local figure_labels Social Adaptability Abstract

latexfigure using `figure_name', path(`figure_path') ///
    figurelist(`figure_list') rowsize(2) title(`figure_title') ///
    key(`figure_key') note(`figure_notes') nodate figlab(`figure_labels') 

