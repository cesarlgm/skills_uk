grscheme, ncolor(6) style(tableau)

*Graph with averages
{
    do "code/process_SES/save_file_for_minimization.do" $education

    do "code/process_SES/compute_skill_indexes.do"

    rename $education education


    gcollapse (mean) chands-clisten, by(education)

    foreach variable of varlist chands-clisten {
        tw connected `variable' education, yscale(range(0 1)) ylab(0(.1)1) ytitle(Average answer) xlab(1(1)3) title(`variable')
        graph export "results/figures/average_`variable'.png", replace
    }


    local figure_name "results/figures/average_manual.tex"
    local figure_path "../results/figures"
    local figure_list average_chands average_cstrengt average_cstamina 
    local figure_title "Manual index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')



    local figure_name "results/figures/average_routine.tex"
    local figure_path "../results/figures"
    local figure_list average_brepeat average_bme4 average_bvariety average_cplanme 
    local figure_title "Routine index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')


    local figure_name "results/figures/average_social.tex"
    local figure_path "../results/figures"
    local figure_list  average_cpeople  average_cteamwk average_clisten  average_cspeech average_cpersuad  average_cteach
    local figure_title "Social index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')

    local figure_name "results/figures/average_abstract.tex"
    local figure_path "../results/figures"
    local figure_list   average_cwritelg average_clong  average_ccalca average_cpercent average_cstats average_cplanoth average_csolutn average_canalyse
    local figure_title "Abstract index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')
}

{
    do "code/process_SES/save_file_for_minimization.do" $education

    do "code/process_SES/compute_skill_indexes.do"
    *Put a loop on this and I will be fine
    rename $education education

    foreach skill of varlist  chands-clisten {
        preserve 
        xi i.`skill', noomit

        gcollapse (mean) _*, by(education)

        reshape long _I`skill'_, i(education) j(category)

        separate _I`skill', by(education) 
        tw line (_I`skill'_1 _I`skill'_2 _I`skill'_3 category), recast(connected) ///
            legend(order(1 "Low" 2 "Mid" 3 "High")) title(`skill')
        graph export "results/figures/distribution_`skill'.png", replace
        restore
    }


    local figure_name "results/figures/distribution_manual.tex"
    local figure_path "../results/figures"
    local figure_list distribution_chands distribution_cstrengt distribution_cstamina 
    local figure_title "Manual index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')



    local figure_name "results/figures/distribution_routine.tex"
    local figure_path "../results/figures"
    local figure_list distribution_brepeat distribution_bme4 distribution_bvariety distribution_cplanme 
    local figure_title "Routine index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')


    local figure_name "results/figures/distribution_social.tex"
    local figure_path "../results/figures"
    local figure_list  distribution_cpeople  distribution_cteamwk distribution_clisten  distribution_cspeech distribution_cpersuad  distribution_cteach
    local figure_title "Social index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')

    local figure_name "results/figures/distribution_abstract.tex"
    local figure_path "../results/figures"
    local figure_list   distribution_cwritelg distribution_clong  distribution_ccalca distribution_cpercent distribution_cstats distribution_cplanoth distribution_csolutn distribution_canalyse
    local figure_title "Abstract index variables"
    local figure_key    fig:key
    local figure_notes "figure note"
    local figlabs       `""""'

    latexfigure using `figure_name', path(`figure_path') ///
        figurelist(`figure_list') rowsize(3) title(`figure_title') ///
        key(`figure_key') note(`figure_notes')

}