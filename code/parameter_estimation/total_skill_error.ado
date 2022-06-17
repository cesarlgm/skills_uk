cap program drop total_skill_error

program define total_skill_error, rclass
    syntax varlist, at(name) 


    *Assigning theta's to the right vector position
    split_theta, theta(`at') n_educ($n_educ) l_A($ts_length)



    *I append all the pi's
    matrix define full_theta=r(theta1)
    forvalues e=2/$n_educ {
        matrix  define full_theta=full_theta \ r(theta`e')
    }


        
    di  rowsof(full_theta)
    matrix rownames full_theta=$ts_names
    matrix full_theta=full_theta'


    tempvar ts_skill
    matrix score `ts_skill'=full_theta if equation==2

    cap replace gmm_error=1-`ts_skill' if equation==2`if'
    cap generate  gmm_error=1-`ts_skill' if equation==2`if'
end