*===============================================================================
*ABSTRACT LAB 
*===============================================================================
foreach definition in _a2  {
	 do "code/parameter_estimation/create_GMM_skills_dataset.do" `definition'

	 do "code/parameter_estimation/compute_GMM.do" `definition'
}
