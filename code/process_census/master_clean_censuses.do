*Clean the census
global census2001 "data\raw\census\2001_UK_ALL\stata\01uklicind-20061002.dta"
global census2011 "data\raw\census\2011_UK_ENWA\UKDA-7605-stata\stata\isg_regionv2.dta"
global census2021 "data\raw\census\2021_UK_ENWA\stata\safeguarded_reg_final_csv2023_07_12.dta"



do "code/process_census/clean_2001_census.do"

do "code/process_census/clean_2011_census.do"

do "code/process_census/clean_2021_census.do"

do "code/process_census/append_censuses.do"

do "code/process_census/check_occupational_codes.do"