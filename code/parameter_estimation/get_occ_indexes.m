%This function identifies the ordering of the parameter vectors
function [e1_code,e1_d_ln_a_index,e1_educ_index,e1_occ_index]=...
    get_occ_indexes(data,n_skills)
    names=transpose(data.Properties.VariableNames);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Equation 1 indexes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    eqn_1_indexes=names(startsWith(names,"e1s"));

    %Indexes for vector 1
    splitted_name=split(eqn_1_indexes,"_");
    e1_year_index=str2double(splitted_name(:,5));
    e1_occ_index=str2double(splitted_name(:,4));
    e1_education_index=str2double(splitted_name(:,3));
    e1_skill_index=str2double(splitted_name(:,2));
    
    e1_code=e1_occ_index*100000+e1_year_index*10+e1_skill_index;

    e1_theta_code=e1_education_index*10+e1_skill_index;

    %%dlnA_index gives the indexes in the dlnA vector
    [~,~,e1_d_ln_a_index]=unique(e1_code);

    if n_skills==3 
        theta_code=[11;12;13;21;22;23;31;32;33];
    elseif n_skills==4
        theta_code=[11;12;13;14;21;22;23;24;31;32;33;34];
    end

    %This part fixes the issue with the theta indexes in e1 when the pi's
    %are restricted to be zero
    [~,e1_educ_index]=ismember(e1_theta_code,theta_code);
end
