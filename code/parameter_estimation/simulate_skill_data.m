function simulated_data=simulate_skill_data(theta_2,p_2,n_jobs,job_size)
   %maximum gap can be min(p_2,1_p_2)
    range=0.5*min(min(1-theta_2.*p_2,p_2));

    data=zeros(job_size,n_jobs,2,2);

    for education=1:2 
        data(:,:,:,education)=simulate_education(theta_2(education),p_2(education) ... 
            ,n_jobs,range,job_size);
    end
    simulated_data=restructure_data(data);
end