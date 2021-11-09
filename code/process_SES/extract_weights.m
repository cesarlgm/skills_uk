function s_weights=extract_weights(weight_sol,n_educ)
    n_weights=length(weight_sol);
    s_weights=reshape(weight_sol,n_weights/(n_educ-1),n_educ-1);
    s_weights=horzcat(ones(size(s_weights,1),1),s_weights);
    s_weights=vertcat(ones(1,size(s_weights,2)),s_weights);
    s_weights=transpose(s_weights);

    row_names={'Low','Mid','High'};
    col_names={'Manual','Routine','Abstract','Social'};

    s_weights=array2table(s_weights,'VariableNames', col_names,'RowNames',row_names);
end