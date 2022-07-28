

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