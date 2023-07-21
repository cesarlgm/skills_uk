/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compute_gmm.do
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
This do file creates the dataset I need to execute the GMM code in matlab


*Latest log of chances:
- Drop code from equations 2 and 3


*/

global ref_skill_num    4
global ref_skill_name   abstract

global index_list   manual social routine abstract 
*global index_list   manual social abstract 



*Final dataset touches
{
   { 
        *Including only jobs I have observations for
        use "data/additional_processing/gmm_skills_dataset", clear

        cap drop temp
        *Filtering by number of education levels in the job
        gegen temp=nunique(education) if equation==1&!missing(y_var), by(occupation year)
        egen n_educ=max(temp), by(occupation year)
        keep if n_educ==3

        *keep if inlist(occupation, 1121,1122,1131, 1135)

        drop if missing(y_var)
        sort equation occupation year education


        egen n_obs=count(manual) if equation==1, by(occupation year)
    
        drop if n_obs==4


        keep occupation year 

        duplicates drop 

        tempfile job_filter
        save `job_filter'

    }

    {
        use "data/additional_processing/gmm_employment_dataset", clear

        drop if missing(y_var)
        keep if equation==3

        *Checking number of times I observe the job
        egen n_times_n=count(year), by(occupation education education_d)
        egen n_times_d=count(year), by(occupation education education_d)

        keep if n_times_d==3

        keep occupation year 
        duplicates drop 

        tempfile employment_filter
        save `employment_filter'
    }

    *Files for instrument
    {
        use "data/additional_processing/gmm_employment_dataset", clear
        drop if missing(y_var)
            
        preserve
            keep occupation education_d year indexd*
            forvalues skill=1/4 {
                rename indexd`skill' index`skill'
            }
            rename education_d education

            tempfile denominator
            save `denominator'
        restore

        keep occupation education index1-index4 year
        append using `denominator'

        duplicates drop 

        reshape wide index*, i(occupation year) j(education)
    }


    use "data/additional_processing/gmm_skills_dataset", clear
    append using "data/additional_processing/gmm_employment_dataset"

    merge m:1 occupation year using `job_filter', keep(3) nogen
    merge m:1 occupation year using `employment_filter', keep(3) nogen 
    drop if missing(y_var)

    sort equation skill occupation  year   education   

    { 
        egen n_times_n=count(year) if equation==3, by(occupation education education_d)
        egen n_times_d=count(year) if equation==3, by(occupation education education_d)

        drop if equation==3&n_times_n!=3&n_times_d!=3

        *This filter drops some jobs in the third euqation. I need to drop tem again from the first equation
        preserve
        {
            keep if equation==3
            keep occupation year
            duplicates drop 
            tempfile second_occ_filter
            save `second_occ_filter'
        }
        restore 
        merge m:1 occupation year using  `second_occ_filter', keep(3) nogen 
    }


    egen occ_id=group(occupation)
    egen year_id=group(year)

    unique occupation
    global n_jobs=`r(unique)'

    *Creating gmm error equations:
    qui {
        levelsof occ_id
        global jobs "`r(levels)'"

        levelsof year_id 
        global years "`r(levels)'"

        levelsof education 
        global educ_lev "`r(levels)'"

        qui summ education 
        *Defining globals
        global n_educ=`r(max)'
        di "$n_educ"

        qui summ skill
        global n_skills=`r(max)'
        di "$n_skills"
    }


    *keep if inlist(equation,1,2)
    *keep occupation-equation occ_id year_id

    tempvar temp
    gegen `temp'=nunique(education) if equation==1, by(occupation)
    egen n_education=max(`temp'), by(occupation)

    keep if n_education==3
}


*========================================================================================================
*VARIABLES TO CONSTRUCT THE ERRORS
*========================================================================================================
*{
    *EQUATION 1
    *==============================================

    *SKILL INDEXES
    local var_counter=0
    qui forvalues education=1/$n_educ {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'&education==`education'&equation==1
                local index_counter=1
                    foreach index in $index_list {
                        if `r(N)'!=0  /* & "`index'"!="$ref_skill_name" */   {
                            qui generate e1s_`index_counter'_`education'_`job'_`year'=0
                            qui replace e1s_`index_counter'_`education'_`job'_`year'= `index' if occ_id==`job'&year_id==`year'&equation==1&education==`education'
                            local ++var_counter
                        }
                        local ++index_counter
                    }
            }
        }
    }
    
    *OCCUPATION DUMMIES
    local var_counter=0
    foreach job in $jobs {
        foreach year in $years {
            local counter=1
            local index_counter
            qui summ  year if occ_id==`job'&year_id==`year'
            foreach index in $index_list {
                if `r(N)'!=0 /*& "`index'"!="$ref_skill_name"*/ {
                    qui generate i_`index'_`job'_`year'=0
                    qui replace i_`index'_`job'_`year'=-1 if occ_id==`job'&year_id==`year'&skill==`counter'&equation==1
                
                    local ++var_counter
                }
                
                local ++counter
            }
        }
    }
    

    *EQUATION 2 VARIABLES
    *==============================================
    *SKILL INDEXES
    cap drop e2_index_*
    forvalues education=1/$n_educ {
        local index_counter=1
        foreach index in $index_list {
            generate e2_index_`index_counter'_`education'=0
            qui replace e2_index_`index_counter'_`education'=`index' if equation==2 & education==`education'
            local ++index_counter
        }
    }


    *EQUATION 3 VARIABLES
    *==============================================
    *Numerator indexes
    cap drop e3n_index_*
    foreach education in $educ_lev {
        local index_counter=1
        foreach index in $index_list {
            generate e3n_index_`index_counter'_`education'=0
            qui replace e3n_index_`index_counter'_`education'=index`index_counter' if equation==3&education==`education'
            local ++index_counter
        }
    }

    *Denominator indexes
    cap drop e3d_index_*
    foreach education in $educ_lev {
        local index_counter=1
        foreach index in $index_list {
            generate e3d_index_`index_counter'_`education'=0
            qui replace e3d_index_`index_counter'_`education'=index`index_counter' if equation==3&education_d==`education'
            local ++index_counter
        }
    }


    *High education groups are never in the denominator
    cap drop e3d_*_3

    *Low education groups are never in the numerator
    cap drop e3n_*_1

    *Note to self: these variables seem to be same as the e2 ones. Check laters whether I use the e2 ones anywhere


    *EQUATION 2 VARIABLES
    *====================================================================
    foreach education in $educ_lev {
        qui summ  year if education==`education'&equation==2
        foreach index in $index_list {
            if `r(N)'!=0 {
                generate ts_`index'`education'=0
                replace ts_`index'`education'= `index' if education==`education'&equation==2
            }
        }
    }


    *EQUATION 3 VARIABLES
    *====================================================================
    *Numerator skill indexes
    foreach education in $educ_lev {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'&equation==3&education==`education'
                forvalues index=1/$n_skills {  
                    if `r(N)'!=0 {
                        generate en_index_`index'_`education'_`job'_`year'=0
                        replace  en_index_`index'_`education'_`job'_`year'= index`index' if occ_id==`job'&year_id==`year'&education==`education'&equation==3
                        local var_counter=`var_counter'+1
                    }
                }
            }
        }
    }

    *Denominator skill indexes
    foreach education in $educ_lev {
        foreach job in $jobs {
            foreach year in $years {
                qui summ  year if occ_id==`job'&year_id==`year'&equation==3&education_d==`education'
                forvalues index=1/$n_skills {  
                    if `r(N)'!=0 {
                        generate ed_index_`index'_`education'_`job'_`year'=0
                        replace  ed_index_`index'_`education'_`job'_`year'= indexd`index' if occ_id==`job'&year_id==`year'&education_d==`education'&equation==3
                        local var_counter=`var_counter'+1
                    }
                }  
        }
        }
    }
    

    *=========================================================================================================
    *INSTRUMENTS
    *=========================================================================================================
    


    /*
    foreach education in $educ_lev {
        foreach job in $jobs {
            qui summ  year if occ_id==`job'&equation==3&education==`education'
                forvalues index=1/$n_skills {  
                if `r(N)'!=0 {
                    generate ezn_index_`index'_`education'_`job'=0
                    replace  ezn_index_`index'_`education'_`job'= index`index' if occ_id==`job'&education==`education'&equation==3
                }
            }
        }
    }
        
    foreach education in $educ_lev {
        foreach job in $jobs {
            qui summ  year if occ_id==`job'&equation==3&education_d==`education'
                forvalues index=1/$n_skills {  
                if `r(N)'!=0 {
                    generate ezd_index_`index'_`education'_`job'=0
                    replace  ezd_index_`index'_`education'_`job'= indexd`index' if occ_id==`job'&education_d==`education'&equation==3
                }
            }
        }
    }
    */
        
    *EQUATION 1 INSTRUMENTS
    *===============================================================================
    cap drop z_*
    forvalues educ=1/3 {
        foreach index in $index_list {
            *if "`index'"!="$ref_skill_name" {
                cap drop temp 
                cap drop z_`index'_e`educ'
                generate temp=`index' if education==`educ' & equation==1
                generate temp_size=obs if education==`educ' & equation==1
                egen z_`index'_e`educ'=max(temp), by(skill occupation year)
                egen zs_`index'_e`educ'=sum(temp_size), by(skill occupation year)
                cap drop temp 
            *}
        }
    }


    foreach index in $index_list {
        *if "`index'"!="$ref_skill_name" {
            
            *z_`index'_e gives the index
            *zs_`index'_e gives the occupation size
            generate z_`index'_1=.
            generate zs_`index'_1=.
            replace z_`index'_1=z_`index'_e2 if education==1&equation==1
            replace zs_`index'_1=zs_`index'_e2 if education==1&equation==1
            replace z_`index'_1=z_`index'_e1 if inlist(education,2,3)&equation==1
            replace zs_`index'_1=zs_`index'_e1 if inlist(education,2,3)&equation==1


            generate z_`index'_2=.
            generate zs_`index'_2=.
            replace z_`index'_2=z_`index'_e2 if education==3&equation==1
            replace zs_`index'_2=zs_`index'_e2 if education==3&equation==1
            replace z_`index'_2=z_`index'_e3 if inlist(education,1,2)&equation==1
            replace zs_`index'_2=zs_`index'_e3 if inlist(education,1,2)&equation==1
     
            egen zt_`index'=rowtotal(zs_`index'_1 zs_`index'_2)

            generate zw_`index'_1= zs_`index'_1/ zt_`index'
            generate zw_`index'_2= zs_`index'_2/ zt_`index'

            generate zv_`index'=zw_`index'_1*z_`index'_1+zw_`index'_2*z_`index'_2 if equation==1
        *}
     
    }


    forvalues education=1/$n_educ {
        foreach index in $index_list {
            *Here the instrument is skill level of the other education groups
            generate z1s_`index'_`education'=0
            qui replace z1s_`index'_`education'=zv_`index' if equation==1 & education==`education'

            *Here the instruments is own education level
            generate s1s_`index'_`education'=0
            qui replace s1s_`index'_`education'=`index' if equation==1 & education==`education'
        }
    }


    *EQUATION 3 INSTRUMENTS
    *===============================================================================
    *Instruments for third equation are job by year dummies
    foreach job in $jobs {
        foreach year in $years {
            qui summ  year if occ_id==`job'&equation==3&year_id==`year'
            if `r(N)'!=0 {
                generate e3jy_`job'_`year'=0
                replace  e3jy_`job'_`year'=1 if occ_id==`job'&year_id==`year'&equation==3
            }
        }
    }



    order occupation  year skill education manual social routine abstract z*_1 z*_2 zv*, first
    sort equation skill  occupation year  education


    drop zv_*
    
    *Here I filter the jobs that 
    sort equation education occupation year skill  

    *Adding line for inst


    di "Expanding employment equation variables", as result
    *Creating equation 3 variables

    order education_d, after(education)
    egen ee_group_id=group(education education_d) if equation==3


    foreach job in $jobs {
        levelsof ee_group_id
        foreach pair in `r(levels)' {
            qui summ  year if occ_id==`job'&equation==3&ee_group_id==`pair'
            if `r(N)'!=0 {
                generate e3jep_`job'_`pair'=0
                replace  e3jep_`job'_`pair'=1 if occ_id==`job'&ee_group_id==`pair'&equation==3
            }
        }
    }


    levelsof ee_group_id
    foreach pair in `r(levels)' {
        foreach year in $years {
            generate x_`pair'`year'=0
            replace x_`pair'`year'=1 if ee_group_id==`pair'&year_id==`year'
        }
    }

    foreach year in $years {
        cap label var x_1`year' "Low/High"
        cap label var x_2`year' "Mid/Low"
        cap label var x_3`year' "High/Mid"
    }

    br education education_d year x*

    *drop x_11 x_13

    cap drop eey_group_id
    egen eey_group_id=group(education education_d year)
    order eey_group_id, after(education_d)


    *========================================================================================================
    *Variables for the standard errors
    *========================================================================================================
    di "Creating omega restriction variables", as result
    *Creating equation 2 variables
    foreach education in $educ_lev {
        qui summ  year if education==`education'&equation==2
        local skill_counter=1
        foreach index in $index_list {
            if `r(N)'!=0 {
                generate d1s_`index'`education'=0
                replace d1s_`index'`education'= `index' if education==`education'&inlist(equation,1,2)
                replace d1s_`index'`education'=index`skill_counter'  if education==`education'&inlist(equation,3)
                replace d1s_`index'`education'=-indexd`skill_counter'  if education_d==`education'&inlist(equation,3)
                local ++skill_counter
            }
        }
    }

    *Here I account for the fact that the thetas for manual are the same no matter the education group
    egen d1s_manual=rowtotal(d1s_manual*)
    order d1s_manual, before(d1s_manual1)
    drop d1s_manual1 d1s_manual2 d1s_manual3

    *These are the indicators to assign pi to the derivatives with respect to theta
    local var_counter=0
    di "Expanding equation 1 variables", as result
    foreach job in $jobs {
        foreach year in $years {
            qui summ  year if occ_id==`job'&year_id==`year'&equation==1
            local index_counter=1
                foreach index in $index_list {
                    if `r(N)'!=0   {
                        qui generate d2s_`index_counter'_`job'_`year'=0
                        qui replace d2s_`index_counter'_`job'_`year'= 1 if occ_id==`job'&year_id==`year'&inlist(equation,1,3)
                        local ++var_counter
                    }
                    local ++index_counter
                }
        }
    }



    *These are the indicators to assign betas to the derivatives with respect to theta
    local var_counter=0
    foreach job in $jobs {
        qui summ  year if occ_id==`job'&equation==3
            if `r(N)'!=0  /* & "`index'"!="$ref_skill_name" */   {
                qui generate d3s_`job'=0
                qui replace d3s_`job'= 1 if occ_id==`job'&inlist(equation,3)
            }
    }

    *Next I add indexes for the pi derivatives
    local var_counter=0
    di "Expanding equation 1 variables", as result
    foreach job in $jobs {
        foreach year in $years {
            qui summ  year if occ_id==`job'&year_id==`year'&equation==1
            local index_counter=1
                foreach index in $index_list {
                    if `r(N)'!=0   {
                        qui generate de1s_`index_counter'_`job'_`year'=0
                        qui replace de1s_`index_counter'_`job'_`year'= `index' if occ_id==`job'&year_id==`year'&equation==1
                        local ++var_counter
                    }
                    local ++index_counter
                }
        }
    }

    *Next I add indexes for the pi derivatives
    local var_counter=0
    di "Expanding equation 1 variables", as result
    foreach job in $jobs {
        foreach year in $years {
            qui summ  year if occ_id==`job'&year_id==`year'&equation==1
            local index_counter=1
                foreach index in $index_list {
                    if `r(N)'!=0  /* & "`index'"!="$ref_skill_name" */   {
                        qui generate de2sn_`index_counter'_`job'_`year'=0
                        qui replace de2sn_`index_counter'_`job'_`year'=index`index_counter' if occ_id==`job'&year_id==`year'&equation==3
                        qui generate de2sd_`index_counter'_`job'_`year'=0
                        qui replace de2sd_`index_counter'_`job'_`year'= indexd`index_counter' if occ_id==`job'&year_id==`year'&equation==3
                        local ++var_counter
                    }
                    local ++index_counter
                }
        }
    }


    order e1s* z1s_* i_*  ts_* e2_* en_* ed_* e3jy_* e3jep_* x_* d1s_* d2s_*  de1s_*  de2sn_* de2sd_*, last

    cap drop ezd_*_temp*

save "data/additional_processing/gmm_example_dataset", replace

use "data/additional_processing/gmm_example_dataset", clear
*This creates the ln vector in the right order; first it goes through skills, next through years and finally through jobs.
cap drop ln_alpha
cap drop __000000

egen ln_alpha=group(occupation year skill) if inlist(equation,1,3) //&skill!=$ref_skill_num
order ln_alpha, after(equation)

cap drop __000000

egen occ_index_3=group(occupation)
replace occ_index_3=0 if equation!=3

*gstats winsor y_var if equation==1, cut(5 95) gen(temp1)
gstats winsor y_var if equation==3, cut(5 95) gen(temp2) by(education education_d)
*replace y_var=temp1 if equation==1
replace y_var=temp2 if equation==3


drop e3jy_1_*
drop e3jep_*_1
drop e3jep_1_2

preserve
    keep occupation
    duplicates drop 
    save "data/additional_processing/GMM_occupation_filter", replace
restore

export delimited using  "data/additional_processing/gmm_example_dataset_winsor.csv", replace nolabel


