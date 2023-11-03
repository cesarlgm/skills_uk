
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

