
{
    use "data/additional_processing/clean_2001_census.dta", clear

    generate year=2001

    keep id education age occ2000 year

    tempfile census2001
    save `census2001'
}

{
    use "data/additional_processing/clean_2011_census.dta", clear

    rename caseno id

    generate year=2011

    keep id education age occ2010 year

    tempfile census2011
    save `census2011'
}

{
    use "data/additional_processing/clean_2021_census.dta", clear

    egen id=group(resident_id_m)

    generate year=2021

    keep id education age occ2021 year

    tempfile census2021
    save `census2021'
}

clear
append using  `census2001'
append using  `census2011'
append using  `census2021'

save "data/additional_processing/appended_census_occ", replace



