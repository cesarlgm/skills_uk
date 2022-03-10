*===============================================================================
*Creates the collapsed LFS databases
*===============================================================================


forvalues year=2000/2017{
	if `year'>2008 {
		local industry_cw in0792dm
		local industry indd07m
	}
	else {
		local industry_cw indd92m
		local industry indd92m
	}
	forvalues quarter=1/4 {
		if `year'!=2004 | `quarter'!=1 {
			use "./data/raw/LFS/`year'q`quarter'", clear
			
			display "`year'q`quarter'"
			
			rename *, lower


			*Note here I am dropping the people that say they don't know
			g year=`year'
			g quarter= `quarter'
			g edlevLFS=.
			if  inrange(`year',1997, 2003) {
					replace edlevLFS=4 if inrange(hiqual,1,14)
					replace edlevLFS=3 if inrange(hiqual,15,24)
					replace edlevLFS=2 if inrange(hiqual,25,30)
					replace edlevLFS=1 if inrange(hiqual,31,39)
					replace edlevLFS=0 if hiqual==40	
			}
			else if inrange(`year',2004,2005) {
				if `year'==2005&`quarter'>1 {
					*Add code for hiqual4
					replace edlevLFS=4 if inrange(hiqual5,1,15)
					replace edlevLFS=3 if inrange(hiqual5,16,28)
					replace edlevLFS=2 if inrange(hiqual5,29,35)
					replace edlevLFS=1 if inrange(hiqual5,36,47)
					replace edlevLFS=0 if inlist(hiqual5, 48)
				}
				else {
					replace edlevLFS=4 if inrange(hiqual4,1,15)
					replace edlevLFS=3 if inrange(hiqual4,16,26)
					replace edlevLFS=2 if inrange(hiqual4,27,32)
					replace edlevLFS=1 if inrange(hiqual4,33,44)
					replace edlevLFS=0 if hiqual4==45		
				}
			}
			else if inrange(`year',2006,2007){
				replace edlevLFS=4 if inrange(hiqual5,1,15)
				replace edlevLFS=3 if inrange(hiqual5,16,28)
				replace edlevLFS=2 if inrange(hiqual5,29,35)
				replace edlevLFS=1 if inrange(hiqual5,36,47)
				replace edlevLFS=0 if inlist(hiqual5, 48)
			}
			else if inrange(`year',2008,2010) {
				replace edlevLFS=4 if inrange(hiqual8,1,15)
				replace edlevLFS=3 if inrange(hiqual8,16,28)
				replace edlevLFS=2 if inrange(hiqual8,29,35)
				replace edlevLFS=1 if inrange(hiqual8,36,48)
				replace edlevLFS=0 if inlist(hiqual8, 49)
			}
			else if inrange(`year',2011,2014) {
				replace edlevLFS=4 if inrange(hiqual11,1,29)
				replace edlevLFS=3 if inrange(hiqual11,30,46)
				replace edlevLFS=2 if inrange(hiqual11,47,57)
				replace edlevLFS=1 if inrange(hiqual11,58,78)
				replace edlevLFS=0 if inlist(hiqual11,79)
			}
			else if inrange(`year',2015,2017) {
				replace edlevLFS=4 if inrange(hiqual15,1,29)
				replace edlevLFS=3 if inrange(hiqual15,30,47)
				replace edlevLFS=2 if inrange(hiqual15,48,59)
				replace edlevLFS=1 if inrange(hiqual15,60,83)
				replace edlevLFS=0 if inlist(hiqual15,84)
			}
		
			label define edlevLFSLbl 0 "No qualification" 	///
				1 "GCSE D-G level" 							///
				2 "GCSE A-C level" 							///
				3 "GCE A* level / trade apprenticeship" 	///
				4 "Bachelor degree +"
			label values edlevLFS edlevLFSLbl
	
			*Filtering the LFS
			qui do "code/process_LFS/filter_LFS.do" `year' `quarter'

			do "code/process_LFS/convert_income.do" `year' `quarter'
			
			local collap=0
			*Now I collapse them
			if inrange(`year',1997,2000) {
				rename socmain b_soc90
				local occupation b_soc90
				local collap=1
				local weight pwt07
			}
			else if `year'==2001& `quarter'==1 {
			}
			else if (`year'==2001&`quarter'>=2)|inrange(`year',2002,2010){
				rename soc2km bsoc2000
				local occupation bsoc2000
				local collap=1
				if `year'==2001&`quarter'==2{
					local weight pwt07
				}
				else if `year'>=2002|(`year'==2001&`quarter'>=3) {
					local weight pwt14
				}
			}
			else if inrange(`year',2011,2017){
				rename sc102km bsoc2000
				local occupation bsoc2000
				local collap=1
				if `year'==2011 & `quarter'<=2 {
					local weight 	pwt14
				}
				else {
					local weight 	pwt18
				}
			}
			
			if `collap'==1{
				g	waveWeight=`weight'
				
				*Here I save the LFS database at the individual level
				save "data/temporary/LFS`year'q`quarter'_indiv", replace
				

				gstats winsor grossWkPayMain, cut($wave_cuts)
				gstats winsor grossPay, cut($wave_cuts)
				gstats winsor hourpay, cut($wave_cuts)
				
				generate al_wkpay=log(grossWkPayMain)
				generate al_hourpay=log(hourpay)

			
				*Pay measures are available only for people in government schemes or who are employees
				drop if missing(grossPay)|missing(grossWkPayMain)|missing(hourpay)

				g observations=1/waveWeight
				

				*This part collapses by quarter and the adequate occupation
				*classification of the year
				
				gcollapse (sum) observations (count) people=age  ///
					(mean) $continuous_list [fw=waveWeight], ///
					by(year quarter edlevLFS `occupation' `industry_cw') fast
				
				*Check this cross walks

				*What do I mean here?
				*Here I fix with the cross walk that is  wrong at the moment
				if inrange(`year',1997,2000) {
					joinby `occupation' using "data/temporary/crossWalk9000"
				}
				
				
				*Then I collage at the appropriate bsoc2000 level
				foreach variable in observations people $continuous_list {
					cap replace `variable'=	`variable'*cwWeight
				}
				
				preserve
					gcollapse (sum) people observations $continuous_list, ///
						by(bsoc2000 year quarter edlevLFS `industry_cw')
						
					rename `industry_cw' industry_cw	
					*Here everything is averages by category
					save "data/temporary/LFS`year'q`quarter'_collapsed", replace
				restore
				
				*Saving files for employment share computation
				{
					preserve
						gcollapse (sum) people observations $continuous_list, ///
							by(bsoc2000 `industry_cw'  year quarter edlevLFS)
							
						rename `industry_cw' industry_cw
						*Here everything is averages by category
						save "data/temporary/LFS`year'q`quarter'_industry_cw", replace
					restore
				}
			}
			
		}
	}
}
