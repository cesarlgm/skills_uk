*Execute GMM

*Creates skill part of GMM dataset
global normalization .000001
global reference        abstract
global skill_ref_no     4
global not_reference    manual
global weight          
global education        educ_3_low
global ed_reference     1

*First I create the datasets
{
    do "code/parameter_estimation/create_GMM_skills_dataset.do"

    do "code/parameter_estimation/create_GMM_employment_dataset.do"
}

*Next I compute the initial values
{
    do "code/parameter_estimation/create_GMM_initial_values.do"
}

/*
*Next I start setting up the program
{
    do "code/parameter_estimation/compute_GMM.do"
}