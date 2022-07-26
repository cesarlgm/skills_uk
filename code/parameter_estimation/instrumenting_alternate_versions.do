
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

*===========================================================================================================================
*Instrumenting with lagged values
*===========================================================================================================================
{
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
        generate z_`index'=l.`index'*pi_`index'
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

    ivreg2 y_var (x_e_*=z_e_*), robust nocons  cluster(occupation) 
    cap drop in_regression
    generate in_regression=e(sample)


    generate skill_sum=.
    forvalues education=1/3 {
        global c_social`education'= _b[x_e_social_`education']
        global c_manual`education'= _b[x_e_manual_`education']
        global c_routine`education'=_b[x_e_routine_`education']
        local social`education':    display %9.2fc      _b[x_e_social_`education']
        local manual`education':  display %9.2fc      _b[x_e_manual_`education']
        local routine`education':   display %9.2fc      _b[x_e_routine_`education']
        replace skill_sum=_b[x_e_manual_`education']*manual+_b[x_e_social_`education']*social+_b[x_e_routine_`education']*routine if education==`education'
    }

    generate y_skill_sum=1-skill_sum

    eststo abstract: regress y_skill_sum ibn.education#c.$reference if skill==1&in_regression $weight, cluster(occupation) robust

    forvalues education=1/3{
        local  $reference`education':    display %9.2fc      _b[`education'.education#c.$reference]
    }


    matrix costs=J(3,4,.)
    forvalues education=1/3 {
        local counter=1
        foreach skill in manual routine social abstract {
            matrix costs[`education',`counter']=``skill'`education''
            local ++counter
        }
    }

    matrix list costs
}

global table_options  booktabs noomit nobase  stat(F r2 N) mtitles("Manual" "Social" "Routine") b(2) se(2) replace
esttab fs_*_1 using "results/tables/instrument_lag_table_1.tex", keep(*_1) $table_options
esttab fs_*_2 using "results/tables/instrument_lag_table_2.tex", keep(*_2) $table_options
esttab fs_*_3 using "results/tables/instrument_lag_table_3.tex", keep(*_3) $table_options
}

*===========================================================================================================================
*Instrumenting with alternative measures of skills
*===========================================================================================================================

{
    *Second version
    *Creating log and dlog of skills
    foreach index in $index_list {
        *generate l_`index'=log(`index'+$normalization)
        generate l_`index'_a1=`index'_i_a1
        generate d_l_`index'_a1=d.l_`index'_a1
        generate l_`index'_a2=`index'_i_a2
        generate d_l_`index'_a2=d.l_`index'_a2
    }

     *I compute -dlogS_ijt+dlogS_manualjt
    foreach index in $index_list { 
        generate  y_d_l_`index'_a1=-d_l_`index'_a1+d_l_${reference}_a1
        generate  y_d_l_`index'_a2=-d_l_`index'_a2+d_l_${reference}_a2
    }


    *Compute pi_{ijt} and the dependent variable: dlogS_ijt+\pi_{ijt}
    foreach index in manual social routine abstract {    
        gegen pi_`index'_a1=    mean(y_d_l_`index'_a1) if !missing(y_d_l_`index'_a1) , by(occupation year)
        gegen pi_`index'_a2=    mean(y_d_l_`index'_a2) if !missing(y_d_l_`index'_a2) , by(occupation year)


        generate y_`index'=d_l_`index'_a1+ pi_`index'_a1
    }


    foreach index in $index_list {
        generate x_`index'=`index'_a1*pi_`index'_a1
        generate z_`index'=`index'_a2*pi_`index'_a2
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

    ivreg2 y_var (x_e_*=z_e_*), robust nocons  cluster(occupation) 
    cap drop in_regression
    generate in_regression=e(sample)


    generate skill_sum=.
    forvalues education=1/3 {
        global c_social`education'= _b[x_e_social_`education']
        global c_manual`education'= _b[x_e_manual_`education']
        global c_routine`education'=_b[x_e_routine_`education']
        local social`education':    display %9.2fc      _b[x_e_social_`education']
        local manual`education':  display %9.2fc      _b[x_e_manual_`education']
        local routine`education':   display %9.2fc      _b[x_e_routine_`education']
        replace skill_sum=_b[x_e_manual_`education']*manual+_b[x_e_social_`education']*social+_b[x_e_routine_`education']*routine if education==`education'
    }

    generate y_skill_sum=1-skill_sum

    eststo abstract: regress y_skill_sum ibn.education#c.$reference if skill==1&in_regression $weight, cluster(occupation) robust

    forvalues education=1/3{
        local  $reference`education':    display %9.2fc      _b[`education'.education#c.$reference]
    }


    matrix costs=J(3,4,.)
    forvalues education=1/3 {
        local counter=1
        foreach skill in manual routine social abstract {
            matrix costs[`education',`counter']=``skill'`education''
            local ++counter
        }
    }
}

*===========================================================================================================================
*Instrumenting with values of skills of other education levels
*===========================================================================================================================


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

drop *_a1 *_a2

gegen n_educ=nunique(education),by(occupation year)

*Drop observations with less than 3 observations

drop if n_educ<3

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

    foreach skill in $index_list { 
       forvalues education=1/3 {
            cap drop temp 
            egen temp =mean(`skill') if education==`education', by(occupation year)
            egen `skill'_`education'=mean(temp),  by(occupation year)
       }

       generate inst_1_`skill'=`skill'_2 if education==1
       generate inst_2_`skill'=`skill'_3 if education==1

       replace inst_1_`skill'=`skill'_1 if education==2
       replace inst_2_`skill'=`skill'_3 if education==2

       replace inst_1_`skill'=`skill'_1 if education==3
       replace inst_2_`skill'=`skill'_2 if education==3
    }
    
    foreach index in $index_list {
        generate x_`index'=`index'*pi_`index'
        generate z_`index'_1= inst_1_`index'*pi_`index'
        generate z_`index'_2= inst_2_`index'*pi_`index'
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
    cap drop z*_e_*
    foreach variable in $index_list {
        forvalues education=1/3 {
            generate z1_e_`variable'_`education'=0 if in_regression==1
            replace z1_e_`variable'_`education'=z_`variable'_1 if education==`education'&in_regression
            generate z2_e_`variable'_`education'=0 if in_regression==1
            replace z2_e_`variable'_`education'=z_`variable'_2 if education==`education'&in_regression

            generate x_e_`variable'_`education'=0 if in_regression==1
            replace x_e_`variable'_`education'=x_`variable' if education==`education'&in_regression==1
            
        }
    }   

    foreach variable in $index_list {
        forvalues education=1/3 {
            eststo fs_`variable'_`education': regress x_e_`variable'_`education' z*_e_* if in_regression==1, nocons
        }
    }

    esttab fs_manual*  fs_routine* fs_social*,  stat(F) 


    ivreg2 y_var (x_e_manual_1 x_e_manual_2 x_e_manual_3 x_e_social_1 x_e_social_2 x_e_social_3 x_e_routine_1 x_e_routine_2 x_e_routine_3 =z1_e_manual_1 z2_e_manual_1 z1_e_manual_2 z2_e_manual_2 z1_e_manual_3 z2_e_manual_3 z1_e_social_1 z2_e_social_1 z1_e_social_2 z2_e_social_2 z1_e_social_3 z2_e_social_3 z1_e_routine_1 z2_e_routine_1 z1_e_routine_2 z2_e_routine_2 z1_e_routine_3 z2_e_routine_3), robust nocons  cluster(occupation)  first
    cap drop in_regression
    generate in_regression=e(sample)
    

    generate skill_sum=.
    forvalues education=1/3 {
        global c_social`education'= _b[x_e_social_`education']
        global c_manual`education'= _b[x_e_manual_`education']
        global c_routine`education'=_b[x_e_routine_`education']
        local social`education':    display %9.2fc      _b[x_e_social_`education']
        local manual`education':  display %9.2fc      _b[x_e_manual_`education']
        local routine`education':   display %9.2fc      _b[x_e_routine_`education']
        replace skill_sum=_b[x_e_manual_`education']*manual+_b[x_e_social_`education']*social+_b[x_e_routine_`education']*routine if education==`education'
    }

    generate y_skill_sum=1-skill_sum

    eststo abstract: regress y_skill_sum ibn.education#c.$reference if skill==1&in_regression $weight, cluster(occupation) robust

    forvalues education=1/3{
        local  $reference`education':    display %9.2fc      _b[`education'.education#c.$reference]
    }


    matrix costs=J(3,4,.)
    forvalues education=1/3 {
        local counter=1
        foreach skill in manual routine social abstract {
            matrix costs[`education',`counter']=``skill'`education''
            local ++counter
        }
    }
}