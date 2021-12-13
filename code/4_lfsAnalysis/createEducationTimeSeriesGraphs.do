*===============================================================================
*DO SANITY CHECKS IN EDUCATIONAL CLASSIFICATION
*===============================================================================

*Consistency of educational classification
*===============================================================================
local varList year age waveWeight quarter edlevLFS grossPay grossWkPayMain ///
	hourpay notM* nonM*
local incomeList grossPay grossWkPayMain hourpay 

set graphics on
/*
di "collapsing quarterly LFS"
forvalues year=1997/2017 {
	forvalues quarter=1/4 {
		if !((`year'==2001)&(`quarter'==1)|(`year'==2004)&(`quarter'==1)){
			use `varList' using "./tempFiles/tempLFS`year'q`quarter'Individual", clear
			g observations=1/waveWeight
			gcollapse (count) people=age observations notM* (mean) `incomeList' ///
				[fw=waveWeight], by(edlevLFS year quarter)
			save "./tempFiles/tempLFSeducAggregates`year'q`quarter'", replace
		}
	}
}
*/
clear
forvalues year=1997/2017 {
	forvalues quarter=1/4 {
		if !((`year'==2001)&(`quarter'==1)|(`year'==2004)&(`quarter'==1)){
			append using "./tempFiles/tempLFSeducAggregates`year'q`quarter'"
		}
	}
}

egen totalPop=sum(people), by(year quarter)
g	 shEdlevLFS=people/totalPop
g	 period=	yq(year,quarter)
g	 time= period
label var period "Quarter"
format period %tq

label var shEdlevLFS "Share of employment"
drop totalPop

xtset edlevLFS period

local graphNote "Note: vertical lines show breaks in the LFS educational classification"

*===============================================================================
*Disaggregated graph
*===============================================================================
local width lwidth(thick)
twoway 	(line shEdlevLFS period if edlevLFS==0, `width' lpattern(solid)) ///
		(line shEdlevLFS period if edlevLFS==1, `width' lpattern(dash)) ///
		(line shEdlevLFS period if edlevLFS==2, `width' lpattern(shortdash)) ///
		(line shEdlevLFS period if edlevLFS==3, `width' lpattern(-.-)) ///
		(line shEdlevLFS period if edlevLFS==4, `width' lpattern(--.--)), ///
		xline(177 180 184 192 204 220) ///
		legend(order(1 "No qualification" 2 "GCSE below C" 3 "GCSE A-C" 4 "A levels" 5 "Bachelor+")) ///
		note(`graphNote') ///
		title("Share of employment by educational level")
graph export "./output/edlevLFSConsistency.pdf", replace

do "./codeFiles/groupEducation.do"


*===============================================================================
*GCSE A-C as low education
*===============================================================================
preserve
collapse (sum) shEdlevLFS, by(newEducation period)

label var shEdlevLFS "Share of employment"

local width lwidth(thick)
local education newEducation
twoway 	(line shEdlevLFS period if `education'==1, `width' lpattern(solid)) ///
		(line shEdlevLFS period if `education'==2, `width' lpattern(dash)) ///
		(line shEdlevLFS period if `education'==3, `width' lpattern(shortdash)), ///
		xline(177 180 184 192 204 220) /// 
		legend(order(1 "Below A levels" 2 "A levels" 3 "Bachelor+")) note(`graphNote') ///
		yscale(range(0 .5)) ylabel(0(.1).5)
graph export "./output/newEducationLFSConsistencyEd1.pdf", replace
restore


preserve
*===============================================================================
*GCSE A-C as mid education
*===============================================================================
collapse (sum) shEdlevLFS, by(alternativeEducation period)

label var shEdlevLFS "Share of employment"

local education alternativeEducation
twoway 	(line shEdlevLFS period if `education'==1, `width' lpattern(solid)) ///
		(line shEdlevLFS period if `education'==2, `width' lpattern(dash)) ///
		(line shEdlevLFS period if `education'==3, `width' lpattern(shortdash)), ///
		xline(177 180 184 192 204 220) /// 
		legend(order(1 "Below GCSE C" 2 "GCSE A-C / A levels" 3 "Bachelor+")) note(`graphNote') ///
		yscale(range(0 .5)) ylabel(0(.1).5)
graph export "./output/newEducationLFSConsistencyEd2.pdf", replace


save "./tempFiles/tempLFSeducAggregatesAppended", replace
restore

preserve
*===============================================================================
*FOUR EDUCATION GROUPS
*===============================================================================
collapse (sum) shEdlevLFS, by(fourEducation period)

label var shEdlevLFS "Share of employment"

local education fourEducation
twoway 	(line shEdlevLFS period if `education'==1, `width' lpattern(solid)) ///
		(line shEdlevLFS period if `education'==2, `width' lpattern(dash)) ///
		(line shEdlevLFS period if `education'==3, `width' lpattern(shortdash)) ///
		(line shEdlevLFS period if `education'==4, `width' lpattern(-.-)), ///
		xline(177 180 184 192 204 220) /// 
		note(`graphNote') ///
		legend(order(1 "Below GCSE C" 2 "GCSE A-C" 3 "A levels" 4 "Bachelor+")) ///
		yscale(range(0 .5)) ylabel(0(.1).5)
graph export "./output/newEducationLFSConsistencyEd3.pdf", replace


save "./tempFiles/tempLFSeducAggregatesAppended", replace
restore


*===============================================================================
*AVERAGE WEEKLY PAY GRAPHS
*===============================================================================
kevinlineplot grossWkPay period edlevLFS, ylab("Gross weekly pay")
/*
*===============================================================================
*COHORT GRAPHS
*===============================================================================

local varList year age waveWeight quarter edlevLFS 


/*
forvalues year=1997/2017 {
	forvalues quarter=1/4 {
		if !((`year'==2001)&(`quarter'==1)|(`year'==2004)&(`quarter'==1)){
			use `varList' using "./tempFiles/tempLFS`year'q`quarter'Individual", clear
			egen ageCohort=cut(age), at(20,30,40,50,70)
			label values ageCohort ageCohort
			g observations=1/waveWeight
			collapse (count) people=age observations [fw=waveWeight], ///
				by(edlevLFS year quarter ageCohort) fast
			save "./tempFiles/tempLFSeducAggregatesAgeCohort`year'q`quarter'", replace
		}
	}
}

clear
forvalues year=1997/2017 {
	forvalues quarter=1/4 {
		if !((`year'==2001)&(`quarter'==1)|(`year'==2004)&(`quarter'==1)){
			append using "./tempFiles/tempLFSeducAggregatesAgeCohort`year'q`quarter'"
		}
	}
}


do "./codeFiles/groupEducation.do"

collapse (sum) people observations, by(alternativeEducation year quarter ageCohort)

egen totalPop=sum(people), by(year quarter ageCohort)
g	 shEdlevLFS=people/totalPop
label var shEdlevLFS "Share of employment"
g	 period=	yq(year,quarter)
g	 time= period
label var period "Quarter"
format period %tq

label var shEdlevLFS "Share of employment"
label define ageCohort 	20 "20-29" ///
						30 "30-39" ///
						40 "40-49" ///
						50 "50-60"
label values ageCohort ageCohort
label var ageCohort "10-year age cohorts"

local graphTitle "Education by age cohort"
local graphNote "Note: vertical lines show breaks in the LFS educational classification"
local width lwidth(thick)
local education alternativeEducation
twoway 	(line shEdlevLFS period if `education'==1, `width' lpattern(solid)) ///
		(line shEdlevLFS period if `education'==2, `width' lpattern(dash)) ///
		(line shEdlevLFS period if `education'==3, `width' lpattern(shortdash)), ///
		xline(177 180 184 192 204 220) /// 
		legend(order(1 "Low" 2 "Mid" 3 "High"))  ///
		yscale(range(0 .5)) ylabel(0(.1).5) ///
		by(ageCohort, caption(`graphNote') title(`graphTitle'))

keep if year==2017&quarter==4		
local graphTitle 	"Share of employment by age cohort"
local graphNote 	"Note: GCSE A-C is included in mid."
tw bar shEdlevLFS ageCohort, by(alternativeEducation, ///
	title(`graphTitle') caption(`graphNote')) barwidth(8) ///
	color(ebblue) yscale(range( 0 .5)) xtitle("Start of the 10-year bracket")
*/
