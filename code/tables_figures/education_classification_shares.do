*Note Apr 6: the averages here look fine.
use "data/temporary/LFS_agg_database", replace

do "code/process_LFS/create_education_variables.do"

gcollapse (sum) people, by(year $education)

egen people_year=sum(people), by(year)

generate educ_share=people/people_year

grscheme, ncolor(7) palette(tableau)
separate educ_share, by($education) 



tw connected `r(varlist)' year, yscale(range(0 .5)) ///
    legend(order(1 "GCSE A-" 2 "A* level / trade app" 3 "Bachelor+") ring(0) pos(7) cols(1) region(lcolor(none))) ///
    xtitle("Year") ytitle("Employment share") ylab(0(.1).6)

graph export "results/figures/education_share.png", replace