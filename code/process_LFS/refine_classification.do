*
local thresh_list  `0'
local factor 4

foreach thresh in `thresh_list' {
    cap drop ref_job_type`thresh'
    generate ref_job_type`thresh'=job_type_`thresh'
    local low 1
    local high 2
    replace ref_job_type`thresh'=`low' if excess_`thresh'`low'>`factor'*excess_`thresh'`high'&job_type_`thresh'==`low'`high'
    replace ref_job_type`thresh'=`high' if excess_`thresh'`low'<1/(`factor')*excess_`thresh'`high'&job_type_`thresh'==`low'`high'
    
    
    local low 2
    local high 3
    replace ref_job_type`thresh'=`low' if excess_`thresh'`low'>`factor'*excess_`thresh'`high'&job_type_`thresh'==`low'`high'
    replace ref_job_type`thresh'=`high' if excess_`thresh'`low'<1/(`factor')*excess_`thresh'`high'&job_type_`thresh'==`low'`high'
    
    local low 1
    local high 3
    replace ref_job_type`thresh'=`low' if excess_`thresh'`low'>`factor'*excess_`thresh'`high'&job_type_`thresh'==`low'`high'
    replace ref_job_type`thresh'=`high' if excess_`thresh'`low'<1/(`factor')*excess_`thresh'`high'&job_type_`thresh'==`low'`high'
}
