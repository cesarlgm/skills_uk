
use "data/additional_processing/gmm_example_dataset", clear
*This creates the ln vector in the right order; first it goes through skills, next through years and finally through jobs.
cap drop ln_alpha
cap drop __000000

egen ln_alpha=group(occupation skill year) if inlist(equation,1,3) //&skill!=$ref_skill_num
order ln_alpha, after(equation)

cap drop __000000

egen occ_index_3=group(occupation)
replace occ_index_3=0 if equation!=3

*gstats winsor y_var if equation==1, cut(1 99) gen(temp1)
*gstats winsor y_var if equation==3, cut(1 99) gen(temp2) by(education education_d)
*replace y_var=temp1 if equation==1
*replace y_var=temp2 if equation==3

export delimited using  "data/additional_processing/gmm_example_dataset.csv", replace


