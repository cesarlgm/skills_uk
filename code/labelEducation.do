
cap label define alternativeEducation 	1 "Below GCSE C" ///
										2 "GCSE C - A levels" ///
										3 "Bachelor +"
cap label values alternativeEducation alternativeEducation

cap label define fourEducation 		1 "Below GCSE C" ///
									2 "GCSE A-C" ///
									3 "A levels" ///
									4 "Bachelor +" 
cap label values fourEducation fourEducation

cap label var alternativeEducation "Education: 3 levels, GCSE A-C as mid"
cap label var fourEducation "Education: 4 levels"
