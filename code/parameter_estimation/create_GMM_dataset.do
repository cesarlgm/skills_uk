*Creates skill part of GMM dataset
global normalization .000001
global reference        abstract
global not_reference    manual
global weight          
global education        educ_3_mid

do "code/parameter_estimation/create_GMM_skills_dataset.do"

do "code/parameter_estimation/create_GMM_employment_dataset.do"