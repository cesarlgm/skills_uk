
*Getting top and bottom jobs by skill
foreach skill in $index_list {
    preserve
    gsort -`skill'
    keep if inrange(_n,1,5)|inrange(_n,_N-6,_N)
    export delimited occupation using "results/tables/occ_examples_`skill'", replace
    restore
}


