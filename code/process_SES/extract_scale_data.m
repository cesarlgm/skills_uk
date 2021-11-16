function [skill_data,education_index,n_skills,index_names]=extract_scale_data(data)
    %Extracts information required for scale calibration
    index_names=data.Properties.VariableNames;
    index_names=index_names(4:end);
    
    skill_data=table2array(data);
    
    education_index=table2array(data(:,2));
    
    skill_data(:,1:3)=[];

    n_skills=size(skill_data,2);
end