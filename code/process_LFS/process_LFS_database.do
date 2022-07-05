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

do "code/process_LFS/import_CPI.do"


*=======================================================================
*Creation of overall datasets
*=======================================================================
*First I create the collapsed datasets by year
*di "Collapsing LFS databases"
do "code/process_LFS/create_collapsed_LFS.do"

di "Appending LFS databases"
*Then I create the append all the LFS
do "code/process_LFS/append_LFS.do"  

/*
*=======================================================================
*Identifying polarizing jobs
*=======================================================================
do "code/process_LFS/identify_polarizing_jobs.do"

do "code/process_LFS/step_up_correction.do"

/*

*I create quick education graphs to evaluate the definitions
do "code/process_LFS/create_education_graphs.do"

*Produce list of occupations by group
do "code/process_LFS/produce_occ_groups_list.do"


*Classifying jobs into jobs that 
do "code/process_LFS/classify_jobs.do"

do "code/process_LFS/output_data_theta_estimation.do"

