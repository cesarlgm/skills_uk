foreach definition in _a1 _a2 _a3 {
	qui do "code/parameter_estimation/create_GMM_skills_dataset.do" `definition'

	qui do "code/parameter_estimation/create_GMM_employment_dataset.do" `definition'

	qui do "code/parameter_estimation/compute_GMM.do" `definition'
}
