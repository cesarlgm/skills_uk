{
    *Import the crosswalks
    import excel "data\raw\census\occ_crosswalks\cw_2000_2010.xlsx", sheet("occ20002010") firstrow clear

    tempfile cw_2000_2010
    save `cw_2000_2010'
}

{
    *Import the crosswalks
    import excel "data\raw\census\occ_crosswalks\cw_2010_2020.xlsx", sheet("cw20102020") firstrow clear

    tempfile cw_2010_2020
    save `cw_2010_2020'
}




{
    use "data/additional_processing/clean_2001_census.dta", clear

    generate year=2001

    keep id education age occ2000 year sex

    joinby occ2000 using  `cw_2000_2010'

    generate weight=male_share if sex==1
    replace weight=female_share if sex==2

    tempfile census2001ind
    save `census2001ind'

    gcollapse (sum) people=age [iw=weight], by(education year occ2010)

    tempfile census2001
    save `census2001'
}


{
    use "data/additional_processing/clean_2011_census.dta", clear

    rename caseno id

    generate year=2011

    keep id education age occ2010 year sex

    tempfile census2011ind
    save `census2011ind'

    gcollapse (count) people=age, by(education year occ2010)
  
    tempfile census2011
    save `census2011'
}

{
    use "data/additional_processing/clean_2021_census.dta", clear

    egen id=group(resident_id_m)

    generate year=2021

    keep id education age occ2021 year sex

    decode occ2021, g(code)

    generate new_code=substr(code,1,3) if year==2021
    destring new_code, replace

    replace occ2021=new_code if year==2021

    joinby occ2021 using  `cw_2010_2020'

    generate weight=men_share if sex==1
    replace weight=women_share if sex==2


    tempfile census2021ind
    save `census2021ind'

    gcollapse (sum) people=age [iw=weight], by(education year occ2010)


    tempfile census2021
    save `census2021'
}

clear
append using  `census2001'
append using  `census2011'
append using  `census2021'

egen people_year=sum(people), by(year)

generate occ_share=people/people_year

egen people_occ_year=sum(people), by(year occ2010)

generate educ_occ_share=people/people_occ_year

save "data/additional_processing/appended_census_occ", replace

clear
append using  `census2001ind'
append using  `census2011ind'
append using  `census2021ind'

keep id age sex education occ2010 weight year

replace weight=1 if year==2011

save "data/additional_processing/appended_census_occ_ind", replace

