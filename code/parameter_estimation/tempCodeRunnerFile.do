    foreach job in $jobs {
        qui summ  year if occ_id==`job'&equation==3
        if `r(N)'!=0 {
            cap generate ezn_index_`job'_temp1=0
            ereplace  ezn_index_`job'_temp1= rowtotal(index*) if occ_id==`job'&equation==3
            replace ezn_index_`job'_temp1=0 if missing(ezn_index_`job'_temp1)
           

            cap generate ezn_index_`job'_temp2=0
            ereplace  ezn_index_`job'_temp2= sum(index*) if occ_id==`job'&equation==3
            replace ezn_index_`job'_temp2=0 if missing(ezn_index_`job'_temp2)

            cap generate ezn_index_`job'_temp3=0
            ereplace  ezn_index_`job'_temp3=  0.5(ezn_index_`job'_temp2-ezn_index_`job'_temp1) if occ_id==`job'&equation==3
            replace ezn_index_`job'_temp3=0 if missing(ezn_index_`job'_temp3)

            local var_counter=`var_counter'+1
        }
    }