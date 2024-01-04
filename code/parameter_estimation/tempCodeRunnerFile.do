        *Including only jobs I have observations for
        use "data/additional_processing/gmm_skills_dataset`1'", clear

        cap drop temp
        *Filtering by number of education levels in the job
        gegen temp=nunique(education) if equation==1&!missing(y_var), by(occupation year)
        egen n_educ=max(temp), by(occupation year)
        keep if n_educ==3

        *keep if inlist(occupation, 1121,1122)

        drop if missing(y_var)
        sort equation occupation year education


        egen n_obs=count(y_var) if equation==1, by(occupation year)