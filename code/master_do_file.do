*=====================================================================================
*MAIN DO FILE

*Description: this do file executes all the programs required for the paper
*Author: César Garro-Marín
*=====================================================================================
/*
	To add later
	gtools
	unique

*/

*=====================================================================================

clear all
clear matrix
set more off, permanently
set graphics off
capture log close 
graph set window fontface "Times New Roman"

set maxvar 120000
set scheme s1color, permanently

cd "C:\Users\thecs\Dropbox\\1_boston_university\8-Research Assistantship\ukData"

global education educ_3_low //educ_3_low
global occupation bsoc00Agg
global wage_cuts  10 90
global continuous_list grossPay grossWkPayMain hourpay al_wkpay al_hourpay
global index_list   manual social routine abstract

adopath + "code/parameter_estimation"


*===============================================================================
*PROCESSING DATABASES
*===============================================================================
do "code/process_databases.do"


*===============================================================================
*CREATE GRAPHS AND FIGURES
*===============================================================================
*Arrows graph
do "code/tables_figures/summaries.do" _a2

do "code/tables_figures/within_index_correlation.do"

do "code/tables_figures/studying_abstract.do" 


do "code/tables_figures/get_top_jobs.do" _a2

do "code/tables_figures/education_classification_shares.do" 

*Add step up correction from the LFS

do "code/tables_figures/step_up_correction.do"

do "code/tables_figures/step_up_correction_census.do"

do "code/tables_figures/create_occ_arrow_graph.do"

do "code/tables_figures/people_do_jobs_differently.do" _a2

do "code/tables_figures/create_skill_education_graphs.do"

do "code/tables_figures/create_skill_correlations.do"

do "code/tables_figures/welch_index.do"


*===============================================================================
*ABSTRACT LAB 
*===============================================================================
foreach definition in _a2  {
	 do "code/parameter_estimation/create_GMM_skills_dataset.do" `definition'

	 do "code/parameter_estimation/create_GMM_employment_dataset.do"  `definition'

	 do "code/parameter_estimation/compute_GMM.do" `definition'
}


do "code/parameter_estimation/compute_employment_shares.do" _a2



do "code/parameter_estimation/wage_regressions.do" _a2



do "code/parameter_estimation/compute_q_values_bs.do"

do "code/parameter_estimation/studying_bad_bjs.do" _a2


/*


*===============================================================================
*ESTIMATE COSTS
*===============================================================================
*Here I create the datasets to estimate the cost parameters
*Skill datasets for the first two equations
do "code/parameter_estimation/create_GMM_skills_dataset.do"

*Dataset of employment changes coming from the LFS
do "code/parameter_estimation/create_GMM_employment_dataset.do"

*Output full dataset for matlab
do "code/parameter_estimation/compute_GMM.do"

*Detail on occupations I am losing when I do two equation solution
do "code/parameter_estimation/lost_occupations_detail.do"



*===============================================================================
*RECONSTRUCTING THE EDUCATIONAL CLASSIFICATION
*===============================================================================
/*
*Recovering the mapping of edlev in the SES
do "code/reconstructionEdlev.do"

do "code/saveOccupationCrossWalks.do"
*/

*Process Labor Force Surveys
do "code/process_LFS/process_LFS_database.do" 

*do "code/process_SES/process_SES_database.do"


*===============================================================================
*Prepare and create regressions
*===============================================================================
do "code/parameter_estimation/prepare_regression_data.do"



/*
*===============================================================================
*WORKING WITH LFS DATA
*===============================================================================


*do "./codeFiles/checkingCrossWalkConsistency.do"


*===============================================================================
*WORKING WITH SES DATA
*===============================================================================
do "./codeFiles/2_handlingSES/processSESdata.do"  `occupation'  0 3 ///
	`aggregateSOC'  `educationType' `chosen_def' `fixed_def'

/*
*This runs occ distributions with weighted data
do "${directory}/codeFiles/exploratoryEdlev.do" 0


