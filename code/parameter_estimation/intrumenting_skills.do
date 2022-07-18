set seed 100

global reference manual

global weight [aw=obs]

do "code/process_SES/save_file_for_minimization.do" $education

generate random_number=runiform()

generate sample_half=1+(random_number>.5)

do "code/process_SES/compute_skill_indexes.do"

rename $occupation occupation
rename $education  education

gcollapse (mean) manual* social* routine* abstract* (count) obs=manual, by(education occupation year sample_half)


*Setting panel dataset
{
    egen group_id=group(occupation education sample_half)
    egen time=group(year)

    xtset group_id time
}

*Creating log and dlog of skills
foreach index in $index_list {
    *generate l_`index'=log(`index'+$normalization)
    generate l_`index'=`index'_i //asinh(`index')
    generate d_l_`index'=d.l_`index'
}

drop if year==2001

*I compute -dlogS_ijt+dlogS_manualjt
foreach index in $index_list { 
    generate  y_d_l_`index'=-d_l_`index'+d_l_$reference
}


*Compute pi_{ijt} and the dependent variable: dlogS_ijt+\pi_{ijt}
foreach index in manual social routine abstract {    
    gegen pi_`index'=    mean(y_d_l_`index') if !missing(y_d_l_`index') $weight, by(occupation year sample_half)

    generate y_`index'=d_l_`index'+ pi_`index'
}



generate x_manual=  manual*pi_manual
generate x_social=  social*pi_social
generate x_routine= routine*pi_routine
generate x_abstract=abstract*pi_abstract

keep occupation education year y_* x_*  $index_list pi_* obs sample_half
rename (y_manual y_social y_abstract y_routine) (y_1 y_2 y_3 y_4)
reshape long y_, i(occupation education year sample_half)  j(skill)
rename y_ y_var

{  
    preserve
        keep if sample_half==2

        foreach variable in $index_list {
            rename pi_`variable' z_pi_`variable'
            rename x_`variable' z_`variable'
        }

        keep occupation education year skill z_*

        tempfile instruments
        save `instruments'
    restore

    keep if sample_half==1
    merge 1:1 occupation education year skill using `instruments', keep(3)

    ivreg2 y_var (i.education#c.(x_social x_routine x_abstract)=i.education#c.(z_pi_social z_pi_routine z_pi_abstract)) , nocons first
    generate in_regression=e(sample)

    foreach variable in social routine abstract {
        forvalues education=1/3 {
            generate z_pi_`variable'_`education'=0 if in_regression==1
            replace z_pi_`variable'_`education'=z_pi_`variable' if education==`education'&in_regression

            generate x_`variable'_`education'=0 if in_regression==1
            replace x_`variable'_`education'=x_`variable' if education==`education'&in_regression==1
        }
    }

    ivreg2 y_var (x_*_1 x_*_2 x_*_3=z_*_1 z_*_2 z_*_3) , nocons first

    
    foreach variable in social routine abstract {
        forvalues education=1/3 {
            regress x_`variable'_`education' z_pi_*_1 z_pi_*_2 z_pi_*_3 if in_regression==1, nocons
        }
    }

    ivreg2 y_var i.education#c.(x_social x_routine x_abstract)  $weight, nocons  
}
