*Compute GMM values
use "data/additional_processing/initial_values_file", clear


cap program drop gmm_skills
program define gmm_skills
    version 16.1 
    systax varlist if, at(name)
    
end