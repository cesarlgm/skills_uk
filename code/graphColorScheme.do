*===============================================================================
/*
	Project: 	UK skills and education project
	Author: 	César Garro-Marín
	Purpose: 	set graph colorscheme
	output: 	tempFiles/skillSESdatabaseAggTimeSplit.csv

*/
*===============================================================================

local ncolors `1'

grstyle init
grstyle set plain
grstyle set symbol pplain      
grstyle set legend 6
grstyle set color  inferno, n(`ncolor')
