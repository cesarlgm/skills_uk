
do "code/process_LFS/import_CPI.do"


*=======================================================================
*Creation of overall datasets
*=======================================================================
*First I create the collapsed datasets by year
*di "Collapsing LFS databases"
do "code/process_LFS/create_collapsed_LFS.do"

di "Appending LFS databases"
*Then I create the append all the LFS
do "code/process_LFS/append_LFS.do"  
