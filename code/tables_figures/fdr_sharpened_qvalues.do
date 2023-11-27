
*========================================================================================
*This code is a modification from the sharpeneed p_values from Michael Anderson (ARE)
*=======================================================================================

* This code generates BKY (2006) sharpened two-stage q-values. BKY (2006) sharpened two-stage q-values are introduced in Benjamini, Krieger, and Yekutieli (2006), "Adaptive Linear Step-up Procedures that Control the False Discovery Rate", Biometrika, 93(3), 491-507

* Last modified: M. Anderson, 11/20/07
* Test Platform: Stata/MP 10.0 for Macintosh (Intel 32-bit), Mac OS X 10.5.1
* Should be compatible with Stata 10 or greater on all platforms
* Likely compatible with with Stata 9 or earlier on all platforms (remove "version 10" line below)

****  INSTRUCTIONS:
****    Please start with a clear data set
****	When prompted, paste the vector of p-values you are testing into the "pval" variable
****	Please use the "do" button rather than the "run" button to run this file (if you use "run", you will miss the instructions at the prompts)

*Preparing dataset for the testing

/*
{
    frames reset


    use "./data/temporary/LFS_industry_occ_file", clear


    tab $education year if inlist(year, 2001,2017) [aw=people], col nofreq

    gcollapse (sum) people obs, by($occupation  year $education)

    egen total_people=sum(people), by(year $occupation)

    generate empshare=people/total_people
    egen    occ_obs=sum(obs), by($occupation year)

    keep $occupation $education year empshare  *obs obs

    keep if inlist(year, 2001,2017)


    *FILTERING OCCUPATIONS
    *The chunck of code below gets the occupations that are in SES
    {
        frame create SES_occs
        frame change SES_occs
        do "code/process_SES/save_file_for_minimization.do"
        
        tempfile SES_file
        save `SES_file'

        keep bsoc00Agg year 
        duplicates drop 


        tempfile SES_occs
        save `SES_occs'
    }

    frame change default
    merge m:1 $occupation year using `SES_occs', keep(3) nogen

    replace observations=floor(observations)
    
    preserve
    {
        sort $occupation $education year
        fillin $occupation $education year
        
        egen temp=sum(observations), by($occupation year)
        generate in_year=temp>0
        replace empshare=0 if in_year==1&missing(empshare)
        by $occupation $education: generate d_empshare=empshare-empshare[_n-1]

        keep if year==2017
        
        keep $occupation $education d_empshare
        reshape wide d_empshare, i($occupation) j($education)

        tempfile empshare_file
        save `empshare_file'
    }
    restore

    

    
    cap drop p_value*
    foreach educ in 1 2 3 {
        generate p_value`educ'=.
        generate educ_level=$education==`educ'
        levelsof $occupation 
        foreach occupation in `r(levels)' {
            di `occupation'
            cap tab educ_level year if $occupation==`occupation' [fw=observation], chi
            cap replace p_value`educ'=`r(p)' if $occupation==`occupation'
        }
        cap drop educ_level
    }
    
   
    keep $occupation p_value*
    duplicates drop 

    merge m:1 $occupation using `empshare_file', keepusing(d_empshare*)
    
    duplicates  drop $occupation, force

}
*/
use "data/additional_processing/t_tests", clear

*I rename the p_values I want to test as:
rename p_value1 pval


version 10


*Applying sharpening of p_values
{
	* Collect the total number of p-values tested

	quietly sum pval
	local totalpvals = r(N)

	* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

	quietly gen int original_sorting_order = _n
	quietly sort pval
	quietly gen int rank = _n if pval != .

	* Set the initial counter to 1 

	local qval = 1

	* Generate the variable that will contain the BKY (2006) sharpened q-values

	gen bky06_qval = 1 if pval != .

	* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.


	while `qval' > 0 {
		* First Stage
		* Generate the adjusted first stage q level we are testing: q' = q/1+q
		local qval_adj = `qval' / ( 1 + `qval' )
		* Generate value q'*r/M
		gen fdr_temp1 = `qval_adj' * rank / `totalpvals'
		* Generate binary variable checking condition p(r) <= q'*r/M
		gen reject_temp1 = ( fdr_temp1 >= pval ) if pval != .
		* Generate variable containing p-value ranks for all p-values that meet above condition
		gen reject_rank1 = reject_temp1 * rank
		* Record the rank of the largest p-value that meets above condition
		egen total_rejected1 = max( reject_rank1 )

		* Second Stage
		* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
		local qval_2st = `qval_adj' * ( `totalpvals' / ( `totalpvals' - total_rejected1[1] ) )
		* Generate value q_2st*r/M
		gen fdr_temp2 = `qval_2st' * rank / `totalpvals'
		* Generate binary variable checking condition p(r) <= q_2st*r/M
		gen reject_temp2 = ( fdr_temp2 >= pval ) if pval != .
		* Generate variable containing p-value ranks for all p-values that meet above condition
		gen reject_rank2 = reject_temp2 * rank
		* Record the rank of the largest p-value that meets above condition
		egen total_rejected2 = max( reject_rank2 )

		* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
		replace bky06_qval = `qval' if rank <= total_rejected2 & rank != .
		* Reduce q by 0.001 and repeat loop
		drop fdr_temp* reject_temp* reject_rank* total_rejected*
		local qval = `qval' - .001
	}


	quietly sort original_sorting_order
    cap drop original_sorting_order
    cap drop rank
	pause off

	display "Code has completed."
	display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
	display	"Sorting order is the same as the original vector of p-values"

	* Note: Sharpened FDR q-vals can be LESS than unadjusted p-vals when many hypotheses are rejected, because if you have many true rejections, then you can tolerate several false rejections too (this effectively just happens for p-vals that are so large that you are not going to reject them regardless).

}

rename pval p_value1
rename bky06_qval bky06_qval_zero


rename p_value1_mean pval
version 10


*Applying sharpening of p_values
{
	* Collect the total number of p-values tested

	quietly sum pval
	local totalpvals = r(N)

	* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

	quietly gen int original_sorting_order = _n
	quietly sort pval
	quietly gen int rank = _n if pval != .

	* Set the initial counter to 1 

	local qval = 1

	* Generate the variable that will contain the BKY (2006) sharpened q-values

	gen bky06_qval = 1 if pval != .

	* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.


	while `qval' > 0 {
		* First Stage
		* Generate the adjusted first stage q level we are testing: q' = q/1+q
		local qval_adj = `qval' / ( 1 + `qval' )
		* Generate value q'*r/M
		gen fdr_temp1 = `qval_adj' * rank / `totalpvals'
		* Generate binary variable checking condition p(r) <= q'*r/M
		gen reject_temp1 = ( fdr_temp1 >= pval ) if pval != .
		* Generate variable containing p-value ranks for all p-values that meet above condition
		gen reject_rank1 = reject_temp1 * rank
		* Record the rank of the largest p-value that meets above condition
		egen total_rejected1 = max( reject_rank1 )

		* Second Stage
		* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
		local qval_2st = `qval_adj' * ( `totalpvals' / ( `totalpvals' - total_rejected1[1] ) )
		* Generate value q_2st*r/M
		gen fdr_temp2 = `qval_2st' * rank / `totalpvals'
		* Generate binary variable checking condition p(r) <= q_2st*r/M
		gen reject_temp2 = ( fdr_temp2 >= pval ) if pval != .
		* Generate variable containing p-value ranks for all p-values that meet above condition
		gen reject_rank2 = reject_temp2 * rank
		* Record the rank of the largest p-value that meets above condition
		egen total_rejected2 = max( reject_rank2 )

		* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
		replace bky06_qval = `qval' if rank <= total_rejected2 & rank != .
		* Reduce q by 0.001 and repeat loop
		drop fdr_temp* reject_temp* reject_rank* total_rejected*
		local qval = `qval' - .001
	}


	quietly sort original_sorting_order
	pause off
	set more on

	display "Code has completed."
	display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
	display	"Sorting order is the same as the original vector of p-values"

	* Note: Sharpened FDR q-vals can be LESS than unadjusted p-vals when many hypotheses are rejected, because if you have many true rejections, then you can tolerate several false rejections too (this effectively just happens for p-vals that are so large that you are not going to reject them regardless).

}

rename pval p_value1_mean
rename bky06_qval bky06_qval_mean


cap drop survived_BKY_zero
generate survived_BKY_zero=bky06_qval_zero<.1&coef1>0

cap drop survived_BKY_mean
generate survived_BKY_mean=bky06_qval_mean<.1&coef1>0

keep occupation year survived_BKY*

save "data/additional_processing/survived_BKY", replace 


