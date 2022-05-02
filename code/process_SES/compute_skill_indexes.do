local abstract 		cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
local social		cpeople  cteamwk clisten  cspeech cpersuad  cteach
local routine		brepeat bme4 bvariety cplanme 
local manual		chands cstrengt  cstamina
global index_list   manual social routine abstract 


local variable_list  `manual' `routine' `abstract' `social' 

foreach variable in `variable_list' {
    summ `variable'
    replace `variable'=((`variable'-`r(min)')/(`r(max)'-`r(min)'))
    replace `variable'=`variable'
    summ `variable'
}

foreach index in $index_list {
    egen `index'=rowmean(``index'')
}


