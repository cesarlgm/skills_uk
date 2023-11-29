use "data/additional_processing/appended_census_occ", clear


generate occupation=.
replace occupation=occ2000 if year==2001
replace occupation=occ2010 if year==2011
replace occupation=occ2021 if year==2021

decode occ2021, g(code2021)
decode occ2010, g(code2010)
decode occ2000, g(code2000)

generate code=""
replace code=code2000 if year==2001
replace code=code2010 if year==2011
replace code=code2021 if year==2021

keep year occ* code 
duplicates drop 

sort year occupation

generate new_code=substr(code,1,3) if year==2021
destring new_code, replace

replace occupation=new_code if year==2021

keep occupation code year
reshape wide code, i(occupation) j(year)

export excel using "data/additional_processing/census_occ_code.xlsx", replace

/*


gcollapse (count) age, by(occupation year)

egen people_year=sum(age), by(year)

generate occ_share_year=age/people_year

gsort year occ_share_year

generate order_occ=_n if year==2001
egen occ_order=max(order_occ), by(occupation)

*I have determined that occupation codes are utterly different across years, so I have to fix all.
grscheme, ncolor(7) palette(tableau)
tw  (scatter occ_share_year occ_order if year==2001) (scatter occ_share_year occ_order if year==2011) (scatter occ_share_year occ_order if year==2021) , 
