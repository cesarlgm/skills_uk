use "data/additional_processing/gmm_example_dataset_eq6_a2", clear

order equation education occupation skill year y_var

keep equation-abstract_a2

save "data/additional_processing/kevin_file_011523", replace

