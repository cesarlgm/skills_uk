*===========================================================================
*creates LFS dataset
*===========================================================================


do "./codeFiles/filterLFS.do"

/*
local 	year quarter statr age socmain keepList socmain socmajl socmajm socmajs ///
		socmanl socmanm ref*


local yearList 1997 2001 2006 2012 2017

foreach year in `yearList' {
	forvalues quarter=1/1 {
		use "./tempFiles/tempLFS`year'q`quarter'", clear
	}
}
