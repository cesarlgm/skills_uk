global abstract     cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
global social		cpeople  cteamwk clisten  cspeech cpersuad  cteach
global routine		brepeat bme4 bvariety cplanme 
global manual		chands cstrengt  cstamina

global abstract_a1      cwritelg canalyse  ccalca cpercent 
global social_a1		cpeople  cteamwk clisten
global routine_a1		brepeat bme4 
global manual_a1		chands   cstamina

global abstract_a2      cstats cplanoth csolutn  clong
global social_a2	    cspeech cpersuad  cteach
global routine_a2		bvariety cplanme 
global manual_a2		cstrengt   

local alternatives  `1'

local variable_list  $manual $routine $abstract $social


foreach variable in `variable_list' {
    summ `variable'
    replace `variable'=((`variable'-`r(min)')/(`r(max)'-`r(min)'))
    replace `variable'=`variable'
    summ `variable'
}

foreach index in $index_list {
    egen `index'=rowmean(${`index'})
    
    *In this line I reverse the routine index
    if "`index'"=="routine" {
        replace `index'=1-`index'
    }

    *This compute the inverse hyperbolic sine
    generate `index'_i=asinh(`index')
}

if "`alternatives'"!="" { 
    foreach index in $index_list {
        egen `index'_a1=rowmean(${`index'_a1})
        egen `index'_a2=rowmean(${`index'_a2})
        generate `index'_i_a1=asinh(`index'_a1)
        generate `index'_i_a2=asinh(`index'_a2)
    }
}


