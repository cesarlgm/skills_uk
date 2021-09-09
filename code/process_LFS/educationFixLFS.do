*===============================================================================
*Edication fix
*===============================================================================


local year `1'

*The educational classification is year specific
if `year'==1997 {
	rename hiqual 		highestQual`year'
	rename hiquald  	highestQualD
	
}
else if `year'==2001 {
	rename hiqual 		highestQual`year'
	rename hiquald  	highestQualD
}
else if `year'==2006 {
	rename hiqual5 		highestQual`year'
	rename hiqual5d  	highestQualD
}
else if `year'==2012 {
	rename hiqual1 	highestQual`year'
	rename hiqul11d 	highestQualD
}

else if `year'==2017 {
	rename hiqual15 	highestQual`year'
	rename hiqul15d 	highestQualD
}

