function [d_avg,occ_order,job_type_order]=compute_deviation(skill_indexes,occ_index,job_type_index)
    job_types=unique(job_type_index);
    for i=1:length(job_types)
        indexes=job_type_index==job_types(i);
        obs=sum(indexes);
        data=skill_indexes(indexes,:);
        grp=occ_index(indexes);
        iota=ones(obs,1);
        
        temp_data=(eye(obs)-(1/obs)*iota*iota')*data;
        job_temp=job_type_index(indexes);

        if i==1 
            d_avg=temp_data;
            occ_order=grp;
            job_type_order=job_temp;
        else
            d_avg=vertcat(d_avg,temp_data);
            occ_order=vertcat(occ_order,grp);
            job_type_order=vertcat(job_type_order,job_temp);
        end
    end
end