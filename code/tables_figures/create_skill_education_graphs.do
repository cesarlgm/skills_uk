*==========================================================================
*Education graphs
*==========================================================================

do "code/process_SES/save_file_for_minimization.do" $education

rename $education education

foreach variable in $routine {
    replace `variable'=1-`variable'
}


eststo clear
foreach variable in $manual {
    eststo `variable': regress `variable' i.education    
}


foreach variable in $routine {
    eststo `variable': regress `variable' i.education    
}

foreach variable in $abstract {
    eststo `variable': regress `variable' i.education    
}


foreach variable in $social {
    eststo `variable': regress `variable' i.education    
}


*Writing graphs
coefplot chands || cstrengt || cstamina, bylabels("Hand accuracy" "Strength" "Stamina") base vert drop(_cons) label
graph export "results/figures/skill_education_manual.png", replace

coefplot  brepeat || bme4 || bvariety || cplanme , base vert drop(_cons)  bylabels("Less repetitive" "Discretion" "Variety" "Planning own time") 
graph export "results/figures/skill_education_adaptability.png", replace

coefplot  cpeople || cteamwk || clisten || cspeech || cpersuad || cteach , bylabels("Dealing with ppl" "Teamwork" "Listening" "Making speeches" "Persuation" "Teaching") base vert drop(_cons)
graph export "results/figures/skill_education_social.png", replace

coefplot   cwritelg || clong || ccalca || cpercent || cstats || cplanoth || csolutn || canalyse , base vert drop(_cons) bylabels("Writing" "Reading" "Basic math" "Fractions / percentages" "Advanced math" "Planning others' time" "Problem solving" "Complex problems")
graph export "results/figures/skill_education_abstract.png", replace



