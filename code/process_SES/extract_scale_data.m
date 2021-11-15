function [skill_data,education_index,n_skills]=extract_scale_data(data)
    %Extracts information required for scale calibration
    skill_data=table2array(data);
    
    education_index=data(:,2);
    
    skill_data(:,1:3)=[];

    n_skills=size(skill_data,2);
end