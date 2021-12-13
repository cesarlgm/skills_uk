*===============================================================================
*RECONSTRUCTION EDLEV
*This recoveres the mapping of edlev in the survey of skills and employment
*===============================================================================
use "data/raw/SESsurvey/ses_combined_general%20release"

keep dataset dquals* edlev

*dquals is not available in 1997
keep if dataset>1997

forvalues j=1/3{
	g edlev`j'=.
	
	*This recodes the education variable 
	local yearFilter & inlist(dataset, 2001, 2006,2012, 2017) 
	*Recoding for 2001 and 2006
	replace edlev`j'=0 if dquals`j'==1`yearFilter'
	
	*Level 1
	*GCSE DG or CSE foundational
	replace edlev`j'=1 if dquals`j'==2`yearFilter'
	*NVQ level 1
	replace edlev`j'=1 if dquals`j'==9`yearFilter'
	*the classification of other changes across time
	replace edlev`j'=1 if dquals`j'==24`yearFilter'
	*sce standard 4-7
	replace edlev`j'=1 if dquals`j'==5`yearFilter'
	
	*The recoding puts everyone with the weird classifications in level 1
	replace edlev`j'=1 if inlist(dquals`j',27, 28 , 29, 31, 32, 41, 42, 44)
	
	*Level 2
	*gcse a level
	replace edlev`j'=2 if dquals`j'==3`yearFilter'
	*sce standard 1-3
	replace edlev`j'=2 if dquals`j'==6`yearFilter'
	*nvq2
	replace edlev`j'=2 if dquals`j'==10`yearFilter'
	*Clerical bookkeepings
	replace edlev`j'=2 if dquals`j'==16`yearFilter'
	*Professional qualification 
	replace edlev`j'=2 if dquals`j'==23`yearFilter'
	
	*Level 3
	*GCE a* level
	replace edlev`j'=3 if dquals`j'==4`yearFilter'
	*SCE higher
	replace edlev`j'=3 if dquals`j'==7`yearFilter'
	*Certificate of 6th year studies
	replace edlev`j'=3 if dquals`j'==8`yearFilter'
	*University certificate not diploma
	replace edlev`j'=3 if dquals`j'==13`yearFilter'
	*Scotvec
	replace edlev`j'=3 if dquals`j'==14`yearFilter'
	*Scotbec
	replace edlev`j'=3 if dquals`j'==15`yearFilter'
	*NVQ 3
	replace edlev`j'=3 if dquals`j'==11`yearFilter'
	*Completion of trade apprenticeship
	replace edlev`j'=3 if dquals`j'==22`yearFilter'
	
	*Level 4
	*nvq level 4
	replace edlev`j'=4 if dquals`j'==12`yearFilter'
	*Nursing
	replace edlev`j'=4 if dquals`j'==17`yearFilter'
	*Teaching
	replace edlev`j'=4 if dquals`j'==18`yearFilter'
	*Other projessional degree
	replace edlev`j'=4 if dquals`j'==19`yearFilter'
	*university or cnaa degree
	replace edlev`j'=4 if dquals`j'==20`yearFilter'
	*masters or phd degree
	replace edlev`j'=4 if dquals`j'==21`yearFilter'
}
egen edlevRec=rowmax(edlev1-edlev3)

label var edlev "Original educational classification"
label var edlevRec "Recovered educational classification"

label define edlevRecLbl 	0 "No qualification" ///
							1 "GCSE D-G levels" ///
							2 "GCSE A levels" ///
							3 "GCE A* levels / trade apprenticeship" ///
							4 "Profesional degree / college degree"
							
label values edlevRec edlevRecLbl

label values edlev edlevRecLbl

log using "results/log_files/educationMapping.txt", text replace

tab edlevRec edlev

log close
