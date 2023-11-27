*Clean the census
global census2001 "data\raw\census\2001_UK_ALL\stata\01uklicind-20061002.dta"
global census2011
global census2021


do "code/process_census/clean_2001_census.do"

do "code/process_census/clean_2011_census.do"

do "code/process_census/clean_2021_census.do"
