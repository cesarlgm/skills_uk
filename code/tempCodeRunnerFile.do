*Create the datasets
do "code/parameter_estimation/create_GMM_skills_dataset.do"

qui do "code/parameter_estimation/create_GMM_employment_dataset.do"

qui do "code/parameter_estimation/compute_GMM.do"

