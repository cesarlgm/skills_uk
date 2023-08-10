global abstract     cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
global social		cpeople  cteamwk clisten  cspeech cpersuad  cteach
global routine		brepeat bme4 bvariety cplanme 
global manual		chands cstrengt  cstamina

global abstract_a1      cwritelg	clong	cpercent	cstats	csolutn	canalyse 
global abstract_a2      cwritelg	clong	cstats	canalyse cpercent 
global abstract_a3      cwritelg	clong	cstats


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
 
cap drop *_a1* 
cap drop *_a2* 
cap drop *_a3*


egen abstract_a1=rowmean($abstract_a1)
egen abstract_a2=rowmean($abstract_a2)
egen abstract_a3=rowmean($abstract_a3)
generate abstract_a1_i=asinh(abstract_a1)
generate abstract_a2_i=asinh(abstract_a2)
generate abstract_a3_i=asinh(abstract_a3)



