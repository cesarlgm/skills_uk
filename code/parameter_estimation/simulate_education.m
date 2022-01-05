%this function generates observations by education level

function education_data=simulate_education(theta_2,p_2,n_jobs,range,job_size)
    p_1=1-theta_2*p_2;
    
    p_1_probs=p_1+(-1+2*rand(n_jobs,1))*range;

    education_data=zeros(job_size,n_jobs,2);

    %generate manual skill data
    for i=1:n_jobs 
        education_data(:,i,1)=simulate_job(job_size,p_1_probs(i));
        education_data(:,i,2)=simulate_job(job_size,p_2);
    end
end

