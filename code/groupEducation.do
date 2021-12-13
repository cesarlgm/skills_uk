local dataset `1'

if "`dataset'"==""{
	local education edlevLFS
}
else {
	local education edlev
}


*Measure 1
g		newEducation=.
replace newEducation=1 if inlist(`education',0,1,2)
replace newEducation=2 if inlist(`education',3)
replace newEducation=3 if inlist(`education',4)


label define newEducationLbl 1 "Below GCSE C" 2 "GCSE C-A lev." 3 "Bachelor+"
label values newEducation newEducationLbl

*Measure 2
g		alternativeEducation=.
replace	alternativeEducation=1 if inlist(`education',0,1)
replace	alternativeEducation=2 if inlist(`education',2,3)
replace	alternativeEducation=3 if inlist(`education',4)

label values alternativeEducation newEducationLbl

g 		fourEducation=.
replace fourEducation=1 if inlist(`education',0,1)
replace fourEducation=2 if inlist(`education',2)
replace fourEducation=3 if inlist(`education',3)
replace fourEducation=4 if inlist(`education',4)

label define fourEducation 	1 "GCSE below C or less" 	///
							2 "GCSE A-C" 				///
							3 "A levels"				///
							4 "Bachelor+"		
							
label values fourEducation fourEducation
