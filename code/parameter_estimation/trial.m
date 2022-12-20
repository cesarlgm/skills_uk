

parameter=0.5*ones(n_total_parameters,1);

%%

v=get_v_matrix(parameter,z_matrix,y_matrix,s_matrix,...
    size_vector,e1_dln_a_index,e1_educ_index,e1_occ_index,e3_a_index,e3n_educ_index,e3d_educ_index);