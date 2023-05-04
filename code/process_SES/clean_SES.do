*===============================================================================
*Basic data cleaning
*===============================================================================
use ".\data\raw\SESsurvey\ses_combined_general%20release", clear

sort dataset crosspid
recode asex (1=0) (2=1) (3=.)
label def asex 0 "Male", modify
label def asex 1 "Female", modify
*recode awork (3=.) 

*Whether onejob or more than one
recode bjobs (5=.) (-2=.) (-1=.)

*Whether job involves use of computerised or automated equipment
*this  variable is not available in 1997 and 2017
recode bauto (5=.) (-2=.) (-1=.) (2=0) (9=.)

*class of worker
recode 	bemptype (3=.)
g		employee=!missing(bemptype)&(bemptype==1)
label 	define employee 0 "No" 1 "Yes"
label 	values employee employee

*Whether paid salary or wage by employer
recode bpdwage (5=.) (-2=.) (-1=.) (2=0)
label	def bpdwage 0 "No", modify

*Type of self-employment
recode bselfem1 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem2 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem3 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem4 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem5 (11=.) (-2=.) (-1=.) (10=0) 

*Employee status: LFS definition
*Note: the survey includes only people who are in the labor force
recode bempsta (3=.) 

*Whether supervisor or manager
************************************************************************
*Here there is harmonization across waves of the variables 
recode bmanage (6=.) (-2=.) (-1=.) (3=0) (2=1)
gen bmanageall=bmanage

recode bmanage_86 (2=0)
recode bmanage_92 (2=0)
replace bmanageall=bmanage_86 if dataset==1986
replace bmanageall=bmanage_92 if dataset==1992
***********************************************************************
*Whether have other working for him
recode bothers (5=.) (-2=.) (-1=.) (2=0)

*Whether job is permanent or not
recode bperm (5=.) (-2=.) (-1=.) (2=0)

*Way in which job is not permanent
recode btemp (5=.) (6=.) (7=.) (8=.) (9=.) (-1=.) 

*Whether working fulltime or parttime
recode bfultime (5=.) (-2=.) (-1=.) (2=0)

*THIS IS LIKE DISCRETION
*How much choice have over way in which job is done
replace bchoice=. if bchoice<1 | bchoice>4

*How often work involves short repetitive tasks
replace brepeat=. if brepeat<1 | brepeat>5

*How much variety in job
replace bvariety=. if bvariety<1 | bvariety>5

*How closely supervised in job
replace bsuper=. if bsuper<1 | bsuper>4
forval x=1/4{
	*At this point low values of bme mean less routine
	replace bme`x'=. if bme`x'<1 | bme`x'==7
}


*Recoding value 6 to missing
ds c*
foreach x in `r(varlist)'{
	if "`x'"!="crosspid" {	
		recode `x' (6=.)
	}
}

rename asex sex
rename aage age
rename b_isco isco88
rename bemptype emptype



keep 	dataset crosspid isco88 b_soc90 bsoc2000 bsoc2010 edlev dpaidwk sex age ///
		region emptype bchoice brepeat bvariety bauto bsuper bme1 bme2 bme3 bme4 ///
		c* sk* dusepc gwtall 


*There is no way to save the dataset before 1997
drop if dataset <1997
*the reason why we drop previous datasets is that there are no skills variable of interest
*all values are changed so that the range is 0-10, with 10 meaning the use or importance of a skill is higher


recode bsuper (1=4) (4=1) (2=3)  (3=2)

local bList 	bsuper bchoice bme1 bme2 bme3 bme4  
foreach variable in `bList' {
	replace `variable'=(`variable'-1)*10/3
	label drop `variable'
	label define `variable' 0 "More choice" 10 "Less choice"
	eststo `variable': reg `variable' edlev
}


eststo clear
ds c* 

local 	cList 		`r(varlist)'
di "`cList'"


eststo clear
foreach variable in `cList' {
	local	excludeList1 !inlist("`variable'", "cplanme","cahead","cmytime", "crosspid")&!inlist("`variable'","cnoac1", "cnoac2", "cnoac3", "cnoac4", "cnoac5","country")
	if  `excludeList1' {
		di "`variable'"
		cap label drop `variable'
		recode 	`variable'  		(1=5) (2=4) (3=3) (4=2) (5=1)
		label define `variable' 	0 "not at all" 10 "essential"
		label values `variable' `variable'
		eststo `variable': qui reg  `variable' edlev
	}
}


label var cplanme "Importance of planning own act, bigger=less routine"


*There are non-integer values in this variable. They are not suppose to be this 
*way, thus I round to the nearest integer
replace	skcheck=round(skcheck)

ds sk*
foreach x in `r(varlist)'{
	replace `x'=round(`x')*10/4
	cap label drop `x'
}

sort dataset isco88 bsoc2000

rename dataset year

do "./code/groupEducation" SES


*Handling of computer use complexity
replace dusepc=. if inlist(dusepc, 5,6,8,-2,-1,9)
*not at all important and 
replace dusepc=0 if inlist(cusepc, 1)|inlist(dusepc, 7)

/*
*I will create two versions of dusepc:
*===============================================================================
	- dusepc:	 	version that treats no computer use as missing
	- dusepcFull:	version that treats no computer use as 5
*/

*Here I reverse the ordering of the dusepc variable
recode 	dusepc  		(0=5) (1=4) (2=3) (3=2) (4=1)
rename 	dusepc dusepcFull 

g		dusepc=dusepcFull
replace dusepc=.a if dusepc==5
replace dusepc=(dusepc-1)*(4/3)+1
replace dusepc=round(dusepc,.01)
replace dusepc=.a if dusepcFull==5

label drop dusepc
label define dusepc ///
	5 "no computer use" ///
	4 "straightforward" ///
	3 "moderate" ///
	2 "complex" ///
	1 "advanced" 

label values  dusepc dusepcFull

drop dusepcFull

*===============================================================================
*This finishes the sesCleaning
