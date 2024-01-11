


use  "data/additional_processing/gmm_example_dataset_eq6_a2", clear


keep if equation==2


regress y_var i.education#c.(manual social routine abstract_a2), nocons r


regress y_var i.education#c.(manual social  abstract_a2), nocons r

