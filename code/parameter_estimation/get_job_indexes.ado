cap program drop get_job_indexes 

program define get_job_indexes, rclass
    version 14.2
    syntax, nda(integer)

    local n_jobs: word count of $jobs

    matrix define job_index=J(`nda',`n_jobs'-1,0)

    local counter=1
    local job_counter=1
    foreach job in $jobs {
        foreach year in $years {
            local index_counter
            foreach index in $index_list {
                qui summ  `index' if occ_id==`job'&year_id==`year'
                if `r(N)'!=0 {
                    matrix job_index[`counter',`job_counter']=1
                    local ++counter                    
                }
            }
        }
        local ++job_counter
    }
    return matrix job_index=job_index
end