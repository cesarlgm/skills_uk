%This function identifies the ordering of the parameter vectors
function [e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index]=...
    get_occ_indexes(data)
    names=transpose(data.Properties.VariableNames);

    eqn_1_indexes=names(startsWith(names,"e1s"));
    eqn_3_indexes_n=names(startsWith(names,"en_"));
    eqn_3_indexes_d=names(startsWith(names,"ed_"));

    
    %Indexes for vector 1
    splitted_name=split(eqn_1_indexes,"_");
    e1_year_index=str2double(splitted_name(:,3));
    e1_occ_index=str2double(splitted_name(:,2));
    e1_skill_index=str2double(splitted_name(:,4));
    e1_code=e1_occ_index*100000+e1_year_index*10+e1_skill_index;


    %%dlnA_index gives the indexes in the dlnA vector
    [~,~,e1_d_ln_a_index]=unique(e1_code);

    %I assign equation1 elements
    e1_indexes=cell(3,1);
    e1_indexes{1,1}=e1_occ_index;
    e1_indexes{2,1}=e1_code;
    e1_indexes{3,1}=e1_d_ln_a_index;

     %Creating index vectors for equation 2
     splitted_e3=split(eqn_3_indexes_n,"_");
    
    %Equation 3 indexes

    %Job indexes
     e3_year_index=str2double(splitted_e3(:,6));
     e3_occ_index=str2double(splitted_e3(:,5));
     e3_skill_index=str2double(splitted_e3(:,3));
 
     e3_code=e3_occ_index*100000+e3_year_index*10+e3_skill_index;

     %Here I search the indexes of e3 into the dlnA indexes
     [~,e3_a_index]=ismember(e3_code,e1_code);
 
     %Education indexes
     %Numerator indexes
     e3n_educ_index=str2double(splitted_e3(:,4));
 
     %Denominator indexes
     splitted_e3=split(eqn_3_indexes_d,"_");
     e3d_educ_index=str2double(splitted_e3(:,4));
end
