function [ones_matrix,s_matrix]=get_s_matrix(data)
    names=transpose(data.Properties.VariableNames);
    s_names=startsWith(names,["e1s_"]);
        
    ones_matrix=table2array(data(data.equation==1,s_names));


    s_names=startsWith(names,["e2_"]);
        
    s_matrix=table2array(data(data.equation==2,s_names));

end