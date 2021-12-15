function [skill_data,skill_obs_tracker,n_skills,index_names]=extract_scale_data(path)
    %Order of the data is:
    %Job type, occupation, year, skills
   
    data=readtable(path);

    index_names=data.Properties.VariableNames;
    index_names=index_names(4:end);
    
    skill_data=table2array(data);
    
    education_index=table2array(data(:,'education'));
    
    occ_index=table2array(data(:,'occupation'));

    year_index=table2array(data(:,'year'));

    skill_obs_tracker=[occ_index,education_index,year_index];
    
    skill_data(:,1:3)=[];

    n_skills=size(skill_data,2);
end