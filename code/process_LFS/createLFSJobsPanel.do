*===============================================================================
*BOUNDARY JOBS GRAPHS
*===============================================================================
local boundaryType 	`1'
local occupation 	`2'
local educationType	`3'

use "./tempFiles/boundaryFile`educationType'", clear

*===============================================================================
preserve 
*Jobs in LFS panel. I use this file to filter the SES data
keep `occupation'
duplicates drop

save "./tempFiles/jobsInLFSPanelKey", replace
restore
