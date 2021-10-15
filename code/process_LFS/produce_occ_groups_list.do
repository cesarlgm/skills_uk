local occupation bsoc00Agg


use "./data/temporary/LFS_agg_database", clear

gcollapse (sum) people, by(`occupation' year)

do "code/process_LFS/aggregate_occupations.do" `occupation'

gcollapse (mean) people, by(`occupation' occ_1dig)

gsort occ_1dig -people

egen total_1dig_empl=sum(people), by(occ_1dig)

generate group_share=people/total_1dig_empl

by occ_1dig: keep if _n<6

order occ_1dig bsoc00Agg group_share

drop people total_1dig_empl

export excel "results/tables/occupation_group_examples.xls", replace firstrow(variables)
*write an example of what the occupations are.


