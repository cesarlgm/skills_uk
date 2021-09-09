*===============================================================================
*Recoding education
*===============================================================================
local yearList 1997 2001 2006 2012 2017
local occupation 		`1'
local educationType		`2'



use "./tempFiles/finalLFSdatabaseDisag", clear

do "./codeFiles/groupEducation"

if `educationType'==1 {
	local education		newEducation
}
else if `educationType'==2 {
	local education 	alternativeEducation
}
else if `educationType'==3 {
	local education 	fourEducation
}

label var year "Year"
label var newEducation "Recoded education"

preserve
collapse (sum) people observations, by(`education' year quarter)
egen 		   totalPeople=sum(people), by(year quarter)
g			   sharePeople=people/totalPeople

local content sharePeople
local fileName=		"./output/edlevPopCount.tex"
local tableTitle= 	"Population by education level"
local levels 		"Low Medium High" 
textablehead using `fileName', ncols(5) coltitles(`yearList') ///
	f("Education level") t(`tableTitle') col("c") key(tab:popcount) drop

*Outputting the table
forvalues educ=1/3 {
	local varLab: word `educ' of `levels'
	label var `content' "`varLab'"
	estpost tabstat `content' if `education'==`educ'&quarter==4, ///
		by(year) col(var) nototal
	esttab e(`content',fmt(%9.2fc)) using `fileName', plain nomtitles collabels(none)  ///
		append booktabs label f
}
	
*I output the total
replace totalPeople=totalPeople/1000
local content 		totalPeople
label var `content' "\midrule Total population (000)"
estpost tabstat `content' if `education'==1&quarter==4, ///
		by(year) col(var) nototal
esttab e(`content',fmt(%14.0fc)) using `fileName', plain nomtitles collabels(none)  ///
append booktabs label f

	
textablefoot using `fileName', notes(uses data from UK LFS for the 4th quarter of each year)
restore

replace age=age*people


save "./tempFiles/lfsDatabaseRecodedEducation`educationType'Disag", replace

collapse (sum) people observations age, by(year `education' `occupation')
replace age=age/people


save "./tempFiles/lfsDatabaseRecodedEducation`educationType'", replace


*After that I should focus on aggregating a bit the occupational distribution
