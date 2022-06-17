
cap program drop split_theta

program define split_theta, rclass 
    version 14.2 
    syntax, theta(name)  n_educ(integer) l_A(integer) 
    local n_skills=4

    local n_jobs_year=`l_A'/`n_skills'

    *This creates the vectors of 
    forvalues e=1/`n_educ' {
        local start_index=1+(`e'-1)*`n_skills'
        local end_index=(`e')*`n_skills'
        matrix define temp_theta=`theta'[`start_index'..`end_index',1]
        
        mata: theta_mat=st_matrix("temp_theta")
        mata: output_mat=J(`n_jobs_year',1,theta_mat)
        mata: st_matrix("theta`e'",output_mat)

        return matrix theta`e'=theta`e'
    }
end



