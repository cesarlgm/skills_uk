use  "data/additional_processing/final_SES_file.dta", clear

*First I compute the skill indexes
{
    local abstract 		cwritelg clong  ccalca cpercent cstats cplanoth csolutn canalyse
    local social		cpeople cteach  cspeech cpersuad cteamwk clisten
    local routine		brepeat bvariety cplanme bme4 
    local manual		chands cstrengt  cstamina
    global index_list 	manual abstract social routine  

    local variable_list  `manual' `routine' `abstract' `social' 

    foreach variable in `variable_list' {
        summ `variable'
        replace `variable'=(`variable'-`r(min)')/(`r(max)'-`r(min)')
        summ `variable'
        assert `r(min)'==0
        assert `r(max)'==1
    }

    foreach index in $index_list {
        egen `index'=rowmean(``index'')
    }

    gcollapse (mean) $index_list (count) obs=chands, by(occupation year education)
    
    tempfile indexes
    save `indexes'
}
