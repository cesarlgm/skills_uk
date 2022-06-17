cap program drop assign_ts_theta

program define assign_ts_theta 
    syntax, theta(name) length(scalar) 

     foreach educ in $educ_lev {
        local start_index=1+(`e'-1)*`n_skills'
        local end_index=(`e')*`n_skills'
        matrix define temp_theta=`theta'[`start_index'..`end_index',1]
        matrix list temp_theta
        
        mata: theta_mat=st_matrix("temp_theta")
        mata: output_mat=J(`l_A',1,theta_mat)
        mata: st_matrix("theta`e'",output_mat)

        return matrix theta`e'=theta`e'
    }

end