local educationType `1'
local occupation 	`2'


local incomeList grossPay grossWkPayMain hourpay

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



use "./tempFiles/lfsDatabaseRecodedEducation`educationType'Disag", replace

merge m:1 `occupation' using "./tempFiles/occAvailabilityTable", nogen
drop withData*
drop if year<2001

*I keep only jobs that have data in all 5 years
keep if nYearsAval>=17

rename (nonMgrossPay nonMgrossWkPayMain nonMhourpay) ///
	(obsNotMgrossPay obsNotMgrossWkPayMain obsNotMhourpay)

foreach variable in `incomeList' {
	egen tempTotal`variable'=sum(notMis`variable'), by(`education' year)
	g tempW`variable'=notMis`variable'/tempTotal`variable'
	replace `variable'= `variable'*tempW`variable'
}

collapse (sum) obs* `incomeList', by(year `education')

sort year `education'
foreach variable in `incomeList' {
	g	l`variable'=log(`variable')
	by year: g rel`variable'=l`variable'[_n]-l`variable'[1]
}

sort `education' year
foreach variable in `incomeList' {
	by `education': g	n`variable'=l`variable'[_n]-l`variable'[1]
}

label define detEducation ///
	1 "Below GCSE C" ///
	2 "GCSE C to A lev." ///
	3 "Bachelor +"
label values `education' detEducation

local graphName="output/levelHourpay.pdf"
kevinlineplot lhourpay year `education', ylab("log(hr wage)") range(0 4) ///
	yscale(0(1)4)
graph export "`graphName'", replace

local graphName="output/levelGrossPay.pdf"
kevinlineplot lgrossWkPay year `education', ylab("log(gross monthly pay)")  range(0 7) ///
	yscale(0(1)7)
graph export "`graphName'", replace


local graphName="output/levelHourpay0.pdf"
kevinlineplot nhourpay year `education', ylab("log(hr wage)")
graph export "`graphName'", replace

local graphName="output/levelGrossPay0.pdf"
kevinlineplot ngrossWkPay year `education', ylab("log(gross monthly pay)")  
graph export "`graphName'", replace


local graphName="output/relHourpay.pdf"
kevinlineplot relhourpay year `education', ylab("log(relative hr pay)")
graph export "`graphName'", replace

local graphName="output/relGrossPay.pdf"
kevinlineplot relgrossWkPay year `education', ylab("log(relative gross pay)") 
graph export "`graphName'", replace
