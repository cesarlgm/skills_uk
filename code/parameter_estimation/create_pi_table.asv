function pi_table=create_pi_table(pi_vector,pi_key)
    
    pi_index=transpose(1:size(pi_vector));

    pi_table=array2table([pi_index,pi_vector],'VariableNames',{'code','pi'});

    pi_table=join(pi_key,pi_table);
end