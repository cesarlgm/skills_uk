
set seed 100

global reference abstract


do "code/process_SES/save_file_for_minimization.do" $education

do "code/process_SES/compute_skill_indexes.do" alt

rename $occupation occupation
rename $education  education

gcollapse (mean) manual* social* routine* abstract* (count) obs=manual, by(education occupation year)

drop if year<2001

{
    egen group_id=group(occupation education)
    egen time=group(year)

    xtset group_id time
}

{
*Creating log and dlog of skills
foreach index in $index_list {
    *generate l_`index'=log(`index'+$normalization)
    generate l_`index'=`index'_i //asinh(`index')
    generate d_l_`index'=d.l_`index'
}


*I compute -dlogS_ijt+dlogS_manualjt
foreach index in $index_list { 
    generate  y_d_l_`index'=-d_l_`index'+d_l_$reference
}


*Compute pi_{ijt} and the dependent variable: dlogS_ijt+\pi_{ijt}
foreach index in manual social routine abstract {    
    gegen pi_`index'=    mean(y_d_l_`index') if !missing(y_d_l_`index') , by(occupation year)

    generate y_`index'=d_l_`index'+ pi_`index'
}

foreach index in $index_list {
    generate x_`index'=`index'*pi_`index'
    generate z_`index'=l.x_`index'
}

{
    keep occupation education year y_* x_* z_*  $index_list pi_* obs
    rename (y_manual y_social y_abstract y_routine) (y_1 y_2 y_3 y_4)
    reshape long y_, i(occupation education year)  j(skill)
    rename y_ y_var
}


cap drop in_regression
regress y_var i.education#c.(x_*), nocons
generate in_regression=e(sample)

cap drop x_e_*
cap drop z_e_*
foreach variable in $index_list {
    forvalues education=1/3 {
        generate z_e_`variable'_`education'=0 if in_regression==1
        replace z_e_`variable'_`education'=z_`variable' if education==`education'&in_regression

        generate x_e_`variable'_`education'=0 if in_regression==1
        replace x_e_`variable'_`education'=x_`variable' if education==`education'&in_regression==1
    }
}

foreach variable in $index_list {
    forvalues education=1/3 {
        eststo fs_`variable'_`education': regress x_e_`variable'_`education' z_e_* if in_regression==1, nocons
    }
}


global table_options  booktabs noomit nobase  stat(F r2 N) mtitles("Manual" "Social" "Routine") b(2) se(2) replace
esttab fs_*_1 using "results/tables/instrument_lag_table_1.tex", keep(*_1) $table_options
esttab fs_*_2 using "results/tables/instrument_lag_table_2.tex", keep(*_2) $table_options
esttab fs_*_3 using "results/tables/instrument_lag_table_3.tex", keep(*_3) $table_options
}


{
    *Second version
}