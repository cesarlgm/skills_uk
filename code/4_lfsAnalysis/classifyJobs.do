*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	classifies jobs according to education
	
	output: 	tempFiles/skillSESdatabaseAggTimeSplit.csv

*/
*===============================================================================
local occupation  		`2'
local educationType  	`1'
local do_location 		"4_lfsAnalysis/classifyJobs.do"

if `educationType'==1 {
	local education newEducation
	local nLevels=3
}
else if `educationType'==2 {
	local education alternativeEducation
	local nLevels=3
}
else if `educationType'==3 {
	local education fourEducation
	local nLevels=4
}


use "./tempFiles/lfsDatabaseRecodedEducation`educationType'", clear

merge m:1 `occupation' using "./tempFiles/occAvailabilityTable", nogen
drop withData*
drop if year<2001

*I keep only jobs that have data in all 5 years
keep if nYearsAval>=17

qui 	unique `occupation'
local	nJobs=	r(unique)

preserve
	*===========================================================================
	*Saving the occupations in LFS key
	*===========================================================================
	keep `occupation'
	duplicates drop
	save "./tempFiles/jobsInLFSPanelKey", replace
	*===========================================================================
restore

save "tempFiles/occupationsForClassification`educationType'", replace

*Parenthesis to complete the panel
foreach variable in year `occupation' `education' {
	preserve
	keep `variable'
	duplicates drop
	save "tempFiles/`variable'Key", replace
	restore
}
clear
use "tempFiles/yearKey", clear
cross using "tempFiles/`occupation'Key"
cross using "tempFiles/`education'Key"

label data "Generated with `do_location'"
save "tempFiles/jobClassificationPanel", replace

*I delete the trash I created
rm "tempFiles/yearKey.dta"
rm "tempFiles/`occupation'Key.dta"
rm "tempFiles/`education'Key.dta"


merge 1:1 year `occupation' `education' ///
	using "tempFiles/occupationsForClassification`educationType'", nogen

*I will asssume that cells that are not in my data mean that there is no people 
*in them
replace people=0 if missing(people)

*I generate the educational level population shares
egen 	educTotal=sum(people), by(`education' year)
egen	peopleTotal=sum(people), by(year)

*I compute job level education shares
g		educAggShare=educTotal/peopleTotal
drop 	educTotal peopleTotal

*Proper renaming to fix the mess I have across datasets
rename 	observations	educ_occ_obs 
rename	people			educ_occ_people
	

egen 	occ_total_obs=sum(educ_occ_obs), by(`occupation' year)


label var educAggShare "Education share in the population"

*I generate occupation level education shares
egen 	occTotal=sum(educ_occ_people), by(`occupation' year)
g		educOccShare=educ_occ_people/occTotal

drop 	occTotal

*Indicators for populating an occupation
g	   populateInd=educOccShare>educAggShare

*Here I create indicators flagging which are border jobs
egen   nEduc=sum(populateInd), by(year `occupation')
g	   borderJob=nEduc>=2
drop   nEduc	

*Now I create indicators for the border type
g	  		tempBorder=`education' if populateInd //&borderJob

tostring 	tempBorder, replace
replace 	tempBorder="" if tempBorder=="."

sort year `occupation' populateInd `education'
by year `occupation' populateInd: g tempBorder1=tempBorder[_n-1]+tempBorder[_n]

g 		tempBorder2=strlen(tempBorder1)
egen 	tempBorder3=max(tempBorder2), by(year `occupation')

g	 	tempBorder4=tempBorder1 if tempBorder2==tempBorder3
destring tempBorder4, replace

egen jobType=max(tempBorder4), by(year `occupation')

drop tempBorder*

*Now I label the job type
do "codeFiles/labelBorderType.do" `educationType'
drop age nYearsAval 

*Creating job count 
egen totalJobCount=count(`occupation'), by(year `education')
egen jobCount=count(`occupation'), by(year `education' jobType)
g 	 jobShare=jobCount/totalJobCount



*===============================================================================
*COMPUTING WEIGHTS
*New addition alert! creating occupation level weight
*===============================================================================
sort year `occupation' educOccShare
by year `occupation': g educOrder=_n
g	 excessEmployment=abs(educOccShare-educAggShare) if educOrder>1
g	 		tempWeight=excessEmployment
replace	 	tempWeight=1 if educOrder==1
egen 		tempWeight2=sum(ln(tempWeight)), by(year `occupation')

g			weight1=sqrt(exp(tempWeight2))
drop		tempWeight2

replace 	tempWeight=tempWeight^2
egen		tempWeight2=sum(tempWeight-1/3), by(year `occupation')
g			weight2=sqrt(tempWeight2)

drop tempW*

label var weight1 "Product weight"
label var weight2 "Cartesian weight"

*===============================================================================
*CREATING SOME GRAPHS
*===============================================================================
*Graphs for border jobs
preserve
	keep year jobType jobShare jobCount
	duplicates drop

	g borderJob=inlist(jobType,12,23,13)

	
	keep if borderJob
	kevinlineplot jobCount year jobType, ylab("Number of jobs")
	graph export "output/jobClassificationBorder.pdf", replace
restore

preserve
	keep year jobType jobShare jobCount
	duplicates drop

	g borderJob=inlist(jobType,12,23,13)

	
	keep if borderJob
	collapse (sum) jobCount, by(year)
	tw line jobCount year, ytitle("Number of jobs") ///
		yscale(range(0 105)) ylab(0(15)105)
	graph export "output/jobClassificationBorderTotal.pdf", replace 
restore

*Non border jobs
preserve
	keep year jobType jobShare jobCount
	duplicates drop

	g borderJob=inlist(jobType,12,23,13)

	keep if !borderJob
	kevinlineplot jobCount year jobType, ylab("Share of total jobs")
	graph export "output/jobClassificationBorderNot.pdf", replace
restore


*This is the file I use for merging with the SES data
preserve
	drop populateInd totalJobCount jobCount jobShare educOrder excessEmployment
	label data "Generated with `do_location'"
	save "tempFiles/borderClassificationForSES`educationType'", replace
restore

label data "Generated with `do_location'"
save "tempFiles/borderJobClassificationLFS`educationType'", replace
