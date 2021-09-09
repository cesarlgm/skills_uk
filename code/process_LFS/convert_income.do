local year 		`1'
local quarter 	`2'

local incomeList 	grossPay grossWkPayMain hourpay
local hourList		bushr

if !(`year'==2001&`quarter'==1){
	merge m:1 year quarter using "data/raw/cpi", nogen keep(3)

	if (`year'>=1999) {
		rename gross99 	grossPay
		rename grsswk	grossWkPayMain
	}
	else {
		rename empgro	grossPay
		rename grsswk	grossWkPayMain
	}

	foreach variable in `incomeList' bushr {
		replace `variable'=. if `variable'<=0
		replace `variable'=`variable'/cpi20*100
		g notMis`variable'=!missing(`variable')
	}
}
