cap program drop gmm_error 

program define gmm_error, eclass 
    syntax [if], at(name) job_index(name)

    if "`if'"=="" { 
        local if
    }
    else {
        local if &`if'
    } 


    total_skill_error, at(`at')

    di "we ok"
    equation_3_error, at(`at')
end