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
local definition_list  educ_3_low //educ_4  //educ_3_low  educ_3_mid
local thresh_list   0 //10 20 30 40 These borders do not work. Maybe I should discuss this with Kevin

grscheme, ncolor(8) style(tableau)


foreach definition in `definition_list' {
    use "data/temporary/job_classification_`definition'", clear

    foreach classf in job_type_0 ref_job_type0 { 
        cap drop hi_lines
        cap drop lo_lines

        local high_education excess_03
        local low_education excess_02
        generate hi_lines=2*`low_education'
        generate lo_lines=(1/2)*`low_education'

        tw (scatter `high_education' `low_education' , msize(.6)) (line  lo_lines `low_education') ///
            (line  hi_lines `low_education' )  if `classf'==23, legend(off) ///
            ytitle(Top education) xtitle(Middle education)
        
        graph export "results/location_`definition'_23.png", replace

        cap drop hi_lines
        cap drop lo_lines

        local high_education excess_02
        local low_education excess_01
        generate hi_lines=2*`low_education'
        generate lo_lines=(1/2)*`low_education'

        tw (scatter `high_education' `low_education' , msize(.6)) (line  lo_lines `low_education') ///
            (line  hi_lines `low_education' )  if `classf'==12, legend(off) ///
            ytitle(Middle education) xtitle(Low education)

        graph export "results/location_`definition'_12.png", replace
    }
}
