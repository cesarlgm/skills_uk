
    foreach index in $index_list {
        eststo `index'01: regress `index' ibn.interest_occ if year==2001, vce(cl $occupation) nocons
        eststo `index'17: regress `index' ibn.interest_occ if year==2017, vce(cl $occupation) nocons
        eststo `index'01d: regress `index' i.interest_occ if year==2001, vce(cl $occupation) 
        eststo `index'17d: regress `index' i.interest_occ if year==2017, vce(cl $occupation) 
        eststo `index'd: regress `index' i.year##i.interest_occ, vce(cl $occupation)
    }

    local table_name "results/tables/up_low_occ.tex"
    local table_title "Skill use in occupations with increased low share"
    local coltitles 2001 2017
    *None of the over time differences are significant
    textablehead using `table_name', ncols(2) coltitles(`coltitles') title(`table_title')
    foreach index in $index_list {
        writebf using `table_name', text(`index')
        leanesttab `index'01 `index'17 using `table_name', not append noobs nostar
        leanesttab `index'01d `index'17d using `table_name', keep(1.interest_occ) coeflabel(1.interest_occ "Difference")  append noobs nostar
    
    }
    textablefoot using `table_name'