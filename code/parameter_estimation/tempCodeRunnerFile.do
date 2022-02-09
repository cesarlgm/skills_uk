
local table_name "results/tables/regression_table.tex"
local table_title "Estimates of $\beta_{i}^e$"
local table_note   "Standard errors clustered at the occupation level"
local table_options   label append f collabels(none) ///
        nomtitles plain  par  b(%9.3fc) se(%9.3fc) star
local col_titles Unweighted Weighted 

textablehead using `table_name', ncols(6) coltitles(`col_titles') ///
    title(`table_title')

leanesttab reg*u reg*w using `table_name', fmt(2) ///
    stat(n_occupations N r2, fmt(%9.0fc %9.0fc %9.2fc)) append
    
textablefoot using `table_name', notes(`table_note')


local table_name "results/tables/theta_estimates.tex"
local table_title "Estimates of $\theta_{i}^e$"
local table_note   "standard errors computed using the delta method"
local table_options   label append f collabels(none) ///
        nomtitles plain  par  b(%9.3fc) se(%9.3fc) star
local col_titles Manual Routine Abstract Social Manual Routine Abstract Social

textablehead using `table_name', ncols(8) coltitles(`col_titles') ///
    exhead(&\multicolumn{4}{c}{Unweighted}&\multicolumn{4}{c}{Weighted} \\) ///
    title(`table_title')

leanesttab theta*1u theta*1w using `table_name', fmt(2) noobs append  coeflabel(_nl_1 "Low")
leanesttab theta*2u theta*2w using `table_name', fmt(2) noobs append  coeflabel(_nl_1 "Mid")
leanesttab theta*3u theta*3w using `table_name', fmt(2) noobs append  coeflabel(_nl_1 "High")
textablefoot using `table_name', notes(`table_note')

