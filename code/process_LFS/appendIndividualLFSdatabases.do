local occupation	`1'
local boundaryType 	`2'
local thresh		`3'

local keepList	year age `occupation' edage impliedExperience edlevLFS  ///
				borderType boundary* waveWeight cwWeight
local filter `occupation'<2111 &  boundaryJob`thresh'& borderType==13

foreach year in 1997 2001 2006 2012 2017 {
	forvalues quarter=1/4 {
		if !(`year'==2001&`quarter'==1){
			append using "./tempFiles/tempLFS`year'q`quarter'Individual", force
		}
		
		*Here I add the crosswalk
		if `year'==1997&`quarter'==4 {
			joinby b_soc90 using "./tempFiles/crossWalk9000"
		}
	}
}

replace cwWeight=1 if missing(cwWeight)

*The ID's are not available in 1997
egen personID=group(year hserialp persno)


*I merge with the border dummies
merge m:1  year `occupation' using "./tempFiles/boundaryDummies`boundaryType'"

keep if  `filter'

keep 	`keepList'

*I generate education grouping again

g	newEducation=.

replace newEducation=1 if inlist(edlevLFS,0,1,2)
replace newEducation=2 if inlist(edlevLFS,3)
replace newEducation=3 if inlist(edlevLFS,4)

label define newEducationLbl 1 "Low education" 2 "Mid education" 3 "High education"
label values newEducation newEducationLbl

save "./tempFiles/appendedIndividualLFSDatabase", replace
