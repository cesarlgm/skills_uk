function skill_data=restructure_data(simulated_data)
    n_jobs=size(simulated_data,2);
    n_obs=size(simulated_data,1);
    n_skills=size(simulated_data,3);
    n_education=size(simulated_data,4);
    
    skill_data=zeros(n_jobs*n_obs*n_education,n_skills);
        obs_counter=1;
        for education=1:n_education
            for job=1:n_jobs 
                for obs=1:n_obs 
                    for skill=1:n_skills 
                        change_num=rand()>0.5;
                        candidate_data=simulated_data(obs,job,skill,education);
                        if candidate_data==0
                            skill_data(obs_counter,3+skill)=candidate_data+1;
                        else
                            skill_data(obs_counter,3+skill)=candidate_data+change_num+1;
                        end
                        skill_data(obs_counter,1:3)=[job,education,2006];
                    end
                    obs_counter=obs_counter+1;
                end
            end
        end
end