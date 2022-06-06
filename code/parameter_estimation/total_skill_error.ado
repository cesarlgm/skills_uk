cap program drop total_skill_error

program define total_skill_error, rclass
    syntax, at(name)

    *First I divide parameters into its components
    {
        qui divide_parameters, parameters(`at')

        return list
        foreach number in  n_sigma n_theta n_lambda n_educ n_ln_A {
            di "`number'"
            local `number'=`r(`number')'
        }

        matrix define sigma=r(sigma)
        matrix define theta=r(theta)
        matrix define raw_lambda=r(raw_lambda)
    }


    *Assigning theta's to the right vector position
    split_theta, theta(theta) n_educ($n_educ) l_A($ts_length)

    *I append all the pi's
    matrix define full_theta=r(theta1)
    forvalues e=2/$n_educ {
        matrix  define full_theta=full_theta \ r(theta`e')
    }
        
    matrix dir
    matrix rownames full_theta=$ts_names
    matrix full_theta=full_theta'


    tempvar ts_skill
    matrix score `ts_skill'=full_theta if equation==2

    cap replace equation_error=`y_var'-`ts_skill' if equation==2`if'
    cap generate  equation_error=`y_var'-`ts_skill' if equation==2`if'
end