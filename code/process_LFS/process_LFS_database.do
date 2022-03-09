*===============================================================================
*Basic LFS processing
*This do file:
*	-Creates the education mapping
*	-Filters the sample of interest in each LFS
* 	-Creates employment counts by education-occupation cell
*	-Appends all the datasets
*	-Computes employment shares by skill
*	-Defines boundary jobs
*===============================================================================
*Some notes: 2001q1 does not have data on occupational classification
*===============================================================================
global continuous_list grossPay grossWkPayMain hourpay al_wkpay al_hourpay

do "code/process_LFS/import_CPI.do"



*First I create the collapsed datasets by year
*di "Collapsing LFS databases"
do "code/process_LFS/create_collapsed_LFS.do"

di "Appending LFS databases"
*Then I create the append all the LFS
do "code/process_LFS/append_LFS.do" edlevLFS 

*I create quick education graphs to evaluate the definitions
do "code/process_LFS/create_education_graphs.do"

*Produce list of occupations by group
do "code/process_LFS/produce_occ_groups_list.do"
*/

*Classifying jobs into jobs that 
do "code/process_LFS/classify_jobs.do"

do "code/process_LFS/output_data_theta_estimation.do"


*Below is old code that problably will be discarded

/****************************************************************************************************
/*
if `aggregateSOC'==1 {
	local occupation bsoc00Agg
}

/*
*Here I compute the occupational employment shares by skill
do "codeFiles/1_handlingLFS/computeYearlyEmploymentShares.do" edlevLFS `occupation'

*Compute similarity of employment distributions
do "codeFiles/1_handlingLFS/computeEmpShareCorrelations.do" edlevLFS `occupation'

do "codeFiles/1_handlingLFS/computeEmpShareWelchTable.do" edlevLFS `occupation'

*This groups the education variables
do "codeFiles/1_handlingLFS/recodeEducation.do"   `occupation' `educationType'

do "codeFiles/1_handlingLFS/checkOccAvailability" `occupation'


*This classifies the fobs by type
do "codeFiles/4_lfsAnalysis/classifyJobs.do" 		`educationType' `occupation' 

*This creates graphs of the change of occupation sizes
do "codeFiles/4_lfsAnalysis/changeInSize.do" 		`educationType' `occupation' 

*This creates the set of tables with the effect of alternative switching job
*definitions
do "codeFiles/4_lfsAnalysis/switching_jobs_tables.do" 	`educationType' ///
	`occupation'  1 `chosen_def'

*This outputs switching jobs flag variables
do "codeFiles/4_lfsAnalysis/define_switching_job_flags.do" 	`educationType' ///
	`occupation'  1 `chosen_def'

*This creates a graph with timing of transitioning for transitioning occupations
do "codeFiles/4_lfsAnalysis/transition_time_graphs.do" 	`educationType' ///
	`occupation'  1 `chosen_def'
*/	
do "codeFiles/4_lfsAnalysis/occ_employment_shares_graphs.do" 		`educationType' ///
	`occupation' 
/*
*This creates ralaxes the core jobs definitions and outputs flags
do "codeFiles/4_lfsAnalysis/relaxing_core_jobs.do" 	`educationType' `occupation' ///	
	`chosen_def' `fixed_def'
	
/*
do "codeFiles/4_lfsAnalysis/createRelativeWageGraphs" `educationType' `occupation'


*do "./codeFiles/4_lfsAnalysis/borderJobTables.do" 	`educationType' `occupation' 

do "./codeFiles/4_lfsAnalysis/borderJobPatterns.do" 	`educationType' `occupation' 

di "Creating education time series graphs"
do "./codeFiles/4_lfsAnalysis/createEducationTimeSeriesGraphs"

******************************************************************************************************/



