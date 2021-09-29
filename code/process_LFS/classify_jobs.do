*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	classifies jobs according to education
	
	output: 	tempFiles/skillSESdatabaseAggTimeSplit.csv
*/
*===============================================================================
set graph on
local occupation bsoc00Agg
local definition_list  educ_3_low educ_4  educ_3_mid
local thresh_list   0 //10 20 30 40 These borders do not work. Maybe I should discuss this with Kevin
grscheme, ncolor(8) style(tableau)




local legend_edlevLFS legend(order(1 "No qualification" 2 "GCSE D-G" 3 "GCSE A-C" ///
        4 "A* level" 5 "Bachelor +")   pos(6))

local legend_educ_4 legend(order(1 "GCSE D-" 2 "GCSE A-C" ///
        3 "A* level" 4 "Bachelor +") pos(6))


local legend_educ_3_low legend(order(1 "GCSE C-" 2  "A* level" 3 "Bachelor +") pos(6))


local legend_educ_3_mid legend(order(1  "GCSE D-" 2 "GCSE A-A*" ///
        3 "Bachelor +") pos(6))


foreach definition in `definition_list' {
    
    use "./data/temporary/LFS_agg_database", clear

    cap log close
        log using "results/log_files/n_occupations.txt", text replace
        unique `occupation'
    log close

    do "code/process_LFS/create_education_variables.do"

    gcollapse (sum) people, by(`occupation' year `definition')
    
    fillin `occupation' year `definition'

    replace people=0 if missing(people)

    gegen total_occ_employment=sum(people), by(`occupation' year)

    generate occ_in_year=total_occ_employment>0

    gegen total_educ_employment=sum(people), by(`definition' year)

    gegen total_employment=sum(people), by(year)

    generate educ_pop_share=total_educ_employment/total_employment

    foreach thresh in `thresh_list' {    
        log using "results/log_files/job_examples_`definition'_`thresh'.txt", text replace
            di "Population shares in 2006"
            table `definition' if year==2006, c(mean educ_pop_share) 
        log close
    }

    generate educ_share=people/total_occ_employment

    foreach thresh in `thresh_list' {
        generate populated_`thresh'=educ_share/educ_pop_share>(1+`thresh'/100) if !missing(educ_share)
        generate excess_`thresh'=educ_share-educ_pop_share
        
        local th_varlist `th_varlist' populated_`thresh'*
        local th_list `th_list'  populated_`thresh'
    }


    keep people educ_share populated_* `occupation' year `definition' occ_in_year excess_* educ_pop_share
    reshape wide people educ_share populated_* excess_* educ_pop_share, i(`occupation' year) j(`definition')
    
    keep if year>=2001

    gegen n_years_data=sum(occ_in_year), by(`occupation')

    keep if n_years_data==17

    cap log close
        log using "results/log_files/n_occupations.txt", text append
        di "Number of occupations once I limit them to occupations appearing in all years"
    unique `occupation'

    log close

    *determine number of education groups
    ds educ_share*
    local n_educ: word count `r(varlist)'

    order educ_share* `th_varlist', after(year)
    
    forvalues educ=1/`n_educ'{ 
        foreach thresh in `thresh_list' {
            replace populated_`thresh'`educ'=populated_`thresh'`educ'*`educ'
            tostring populated_`thresh'`educ', replace
            replace populated_`thresh'`educ'="" if populated_`thresh'`educ'=="0" |  populated_`thresh'`educ'=="." 
        }
    }
    foreach thresh in `thresh_list' {
        gegen job_type_`thresh'=concat(populated_`thresh'*)
        generate n_educ_`thresh'=length(job_type_`thresh')
        destring job_type_`thresh', replace
    }
   
    order job_type* n_educ*, last

    egen total_occ_employment=rowtotal(people*)

    keep total_occ_employment job_type_* educ_pop_share* excess_* `occupation' year  n_educ_* educ_share* 

    egen total_employment=sum(total_occ_employment), by(year)

    generate occ_share=total_occ_employment/total_employment

    order educ_share* excess* educ_pop_share*, after(year)

    do "code/process_LFS/aggregate_occupations.do" `occupation'

    do "code/process_LFS/refine_classification.do" `thresh_list'


    save "data/temporary/job_classification_`definition'", replace

    *I output some necessary graphs
    foreach thresh in `thresh_list' { 
        foreach classf in job_type_`thresh' ref_job_type`thresh' {
            cap log close
            log using "results/log_files/job_examples_`definition'_`classf'.txt", text replace
            cap log close
            preserve
                keep if `classf'<10
                collapse (sum) occ_share (count) n_jobs=occ_share, by(year `classf')

                separate occ_share, by(`classf')  shortlabel 
                tw connected `r(varlist)' year, `legend_`definition'' yscale(range(0 .50))

                graph export "results/figures/empshare_job_classification_`definition'_`classf'.png", replace

                separate n_jobs, by(`classf')  shortlabel
                tw connected  `r(varlist)' year, `legend_`definition'' yscale(range(0 100))

                graph export "results/figures/n_jobs_job_classification_`definition'_`classf'.png", replace
            restore

            preserve
                keep if `classf'>10
                collapse (sum) occ_share (count) n_jobs=occ_share, by(year `classf')

                separate occ_share, by(`classf')  shortlabel 
                tw connected `r(varlist)' year,  yscale(range(0 .50))

                graph export "results/figures/empshare_job_classification_`definition'_`classf'_border.png", replace

                separate n_jobs, by(`classf')  shortlabel
                tw connected  `r(varlist)' year,  yscale(range(0 100))

                graph export "results/figures/n_jobs_job_classification_`definition'_`classf'_border.png", replace
            restore
            *export example of jobs by type
            cap log close
            log using "results/log_files/job_examples_`definition'_`classf'.txt", text append
            levelsof `classf'
            foreach jobtype in `r(levels)' {
                di "Job type==`jobtype'"
                list `occupation' educ_share* if `classf'==`jobtype' & year==2006
            }
            log close
            }
    }

    foreach thresh in `thresh_list' {
        foreach classf in job_type_`thresh' ref_job_type`thresh' {
            preserve
                keep if `classf'<10
                *Some details on the type of jobs
                collapse (sum) occ_share (count) n_jobs=occ_share, by(year `classf' occ_1dig)
            
                gegen job_type_share=sum(occ_share),  by(year `classf')

                generate type_empshare=occ_share/job_type_share

            
                levelsof `classf'
                foreach educ in `r(levels)' {
                    graph	bar	type_empshare	if  `classf'==`educ', ///
                        over(occ_1dig)	by(`classf')	stack	hor	label ///
                        title("Education==`educ', `definition'")
                    graph export "results/figures/job_type_composition_`definition'_`classf'_`educ'.png", replace
                }
            restore
        }
    }
}


