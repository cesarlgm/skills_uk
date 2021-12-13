*===============================================================================
*Creation of the graph
*===============================================================================
local thresh 		`1'
local boundaryType 	`2'
local educationType `3'
local twoWayBorder	`4'

*This is just to modify the naming of the graph in allow more that pairwise borders
if `twoWayBorder'==0 {
	local 3way "multiple"
}
else {
	local 3way ""
}

preserve
keep if inlist(year, 2001, 2006, 2012, 2017)

replace borderType`thresh'=0 if missing(borderType`thresh')
label define borderType 0 "Normal job", modify

triplot empShare*, y symbol(x O T S X) separate(borderType`thresh') msize(.8 1 1 1 1.3) ///
	mcolor(gray ebblue midgreen orange cranberry) ///
	by(year, ///
	note("`graphNotes1'")) 
local graphID "./output/lfsBoundary`boundaryType'`thresh'`educationType'`3way'.pdf"
graph export  `graphID', replace
restore
