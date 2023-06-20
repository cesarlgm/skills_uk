*===============================================================================
use "./data/temporary/LFS_agg_database", clear

do "code/process_LFS/create_education_variables.do"

collapse (mean) l_hourpay (sum) people [aw=people], by($education year)
egen temp=sum(people), by(year)
generate emp_share=people/temp 

keep if inlist(year, 2001,2017)

table $education year, c(mean emp_share)

