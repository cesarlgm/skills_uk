function question=simulate_job(job_size,p)
    question=zeros(job_size,1);
    rand_num=rand(job_size,1);
    question(rand_num<p,1)=1;
end