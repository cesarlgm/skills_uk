global normalization  0
global reference        abstract
global not_reference    manual
global weight          
global education        educ_3_mid

*New regression approach

*Creating the SES database
do "code/process_SES/save_file_for_minimization.do" $education

do "code/process_SES/compute_skill_indexes.do"

rename $education education
rename $occupation occupation

global coefplot_options base recast(connected) vert nooffset legend(ring(0) pos(11)) yscale(range(0 .7)) ylab(0(.1).7)
grscheme, ncolor(10) style(tableau)
*Highest category
eststo clear
foreach variable in $manual $abstract $routine $social {
    cap drop d_`variable'
    generate d_`variable'=`variable'==1

    eststo `variable': regress d_`variable' ibn.education, nocons
} 

foreach index in $index_list  {
    coefplot ${`index'}, $coefplot_options title(`index'_1)
    graph export "results/figures/`index'_100.png", replace
}

*Lowest category
{
    foreach variable in $manual $abstract $routine $social {
        cap drop d_`variable'
        generate d_`variable'=`variable'==0

        eststo `variable': regress d_`variable' ibn.education, nocons
    } 
}

foreach index in $index_list  { 
    coefplot ${`index'},  $coefplot_options title(`index'_0)
    graph export "results/figures/`index'_0.png", replace
}

*Second largest category
{
    foreach variable in $manual $abstract $routine $social {
        qui levelsof clong
        local levels `r(levels)'
        local n_levels: word count of `levels'
        local level=`n_levels'-2
        
        local level_value: word `level' of `levels'
    
        cap drop d_`variable'
        generate d_`variable'=`variable'==`level_value'

        eststo `variable': regress d_`variable' ibn.education, nocons
    } 
}

foreach index in $index_list  { 
    coefplot ${`index'},  $coefplot_options  title(`index'_0.75)
    graph export "results/figures/`index'_75.png", replace
}

*Second lowest category
{
    foreach variable in $manual $abstract $routine $social {
        qui levelsof clong
        local levels `r(levels)'
        
        local level_value: word 2 of `levels'
    
        cap drop d_`variable'
        generate d_`variable'=`variable'==`level_value'

        eststo `variable': regress d_`variable' ibn.education, nocons
    } 
}

foreach index in $index_list  { 
    coefplot ${`index'},  $coefplot_options  title(`index'_.25)
    graph export "results/figures/`index'_25.png", replace
}


foreach answer in 0 25 75 100 {
    local figure_name "results/figures/scale_`answer'.tex"
    local figure_list manual_`answer' routine_`answer' social_`answer' abstract_`answer'
    local path "../results/figures/"

    latexfigure using `figure_name', path(`path') figurelist(`figure_list') title(Answer `answer') rowsize(2)
}