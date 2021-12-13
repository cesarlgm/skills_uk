*=========================================================================
*Labeling border types
*=========================================================================
local educationType `1'

if `educationType'==1 {
	label define jobType 	12 "Below A levels - A levels" ///
							13 "Below A levels - Bachelor+" ///
							23 "A levels - Bachelor+"
}
else if `educationType'==2  {
	label define jobType 	12 "Below GCSE C - GCSE C to A lev." ///
							13 "Below GCSE C - Bach+" ///
							23 "GCSE C to A lev. - Bach+" ///
							1  "Below GCSE C" ///
							2  "GCSE C to A lev." ///
							3  "Bachelor +"
}
else if `educationType'==3 {
	label define jobType 	12 "Below GCSE C - GCSE A-C" ///
							13 "Below GCSE C - A levels" ///
							14 "Below GCSE C - Bachelor+" ///
							23 "GCSE A-C- A levels" ///
							24 "GCSE A-C- Bachelor+" ///
							34 "A levels- Bachelor+" ///
							123 "Below GCSE C - GCSE A-C - A levels" ///
							124 "Below GCSE C - GCSE A-C - Bachelor+" ///
							134 "Below GCSE C - A levels - Bachelor+" ///
							234 "GCSE A-C - A levels - Bachelor+" ///
							1234 "4-way boder"
							
}
label values jobType jobType
