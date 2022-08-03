    do "code/process_SES/save_file_for_minimization.do" $education

    do "code/process_SES/compute_skill_indexes.do"

    rename $education education


    gcollapse (mean) chands-clisten, by(education)

    foreach variable of varlist chands-clisten {
        tw connected `variable' education, yscale(range(0 1)) ylab(0(.1)1) ytitle(Average answer) xlab(1(1)3) title(`variable')
        graph export "results/figures/average_`variable'.png", replace
    }
