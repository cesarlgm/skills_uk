
forvalues i=1/3 {
    eststo educ`i': reghdfe d_l_employment  i_* if education==`i'&year==2001, nocons absorb(industry_cw)
    eststo educ`i'_empshare: reghdfe d_l_educ_empshare  i_* if education==`i'&year==2001 , nocons absorb(industry_cw)
}