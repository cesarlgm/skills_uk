
use "data/additional_processing/appended_census_occ", clear

gcollapse (sum) occ_share, by(occ2010 year)

gsort year occ_share

generate order_occ=_n if year==2011
egen occ_order=max(order_occ), by(occ2010)

replace occ_order=occ_order-90

*I have determined that occupation codes are utterly different across years, so I have to fix all.
grscheme, ncolor(7) palette(tableau)

tw  (scatter occ_share occ_order if year==2001) ///
    (scatter occ_share occ_order if year==2011) ///
    (scatter occ_share occ_order if year==2021) , ///
    legend(order(1 "2001" 2 "2011" 3 "2021") ring(0) pos(11)) ///
    ytitle("Employment share") xtitle("Size ranking")

graph export "results/figures/assessing_occ_cw.png", replace
