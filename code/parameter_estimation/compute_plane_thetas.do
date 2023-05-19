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

        *keep if inlist(occupation, 1121,1122)

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

    keep if inlist(equation,1,2)
    keep occupation-equation occ_id year_id

    tempvar temp
    gegen `temp'=nunique(education) if equation==1, by(occupation)
    egen n_education=max(`temp'), by(occupation)

    keep if n_education==3

    keep if equation==2

    regress y_var i.education#c.(manual social routine abstract), nocons

}

