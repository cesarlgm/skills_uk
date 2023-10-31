
    local table_name "results/tables/people_do_jobs_differently_all.tex"
    local table_title "Within-job skill use across education groups"
    local coltitles `""Manual""Social""Adabtability""Abstract""'
    local table_notes "standard errors clustered at the occupation level in parenthesis"

    textablehead using `table_name', ncols(4) coltitles(`coltitles') title(`table_title')
    leanesttab *n using `table_name', fmt(3) append star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") nobase stat(n_occ N , label( "\midrule Number of occupations" "Observations") fmt(%9.0fc %9.0fc))
    texspec using `table_name', spec(y y y y) label(Occupation f.e.)
    texspec using `table_name', spec(y y y y) label(Year f.e.)
    textablefoot using `table_name', notes(`table_notes')

    *Excel table
    esttab *n using "results/tables/skill_use_within_jobs_all.csv", ///
        b(3) se(3) par  star(* .10 ** .05 *** .01) coeflabel(_cons "Baseline use") label nobase stat(n_occ N , label( "\midrule Number of occupations" "Observations") fmt(%9.3fc %9.3fc)) replace