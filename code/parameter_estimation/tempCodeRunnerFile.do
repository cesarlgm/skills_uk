   ivreg2 y_var (i.education#c.(x_social x_routine x_abstract)=i.education#c.(z_pi_social z_pi_routine z_pi_abstract))  $weight, nocons 

    ivreg2 y_var i.education#c.(x_social x_routine x_abstract)  $weight, nocons 