function [theta_matrix,comparative]=extract_solution(solution, size_vector)
    %Split parameter vector into parameter type
    splitted_vector=assign_parameters(solution,size_vector);

    %Extracting dlnA vector
    %First I create the full restricted dlna
    d_ln_a=splitted_vector{2};

    %Now I get the theta vector
    theta=splitted_vector{1};

    %Sigma vector
    sigmas=splitted_vector{3};

    theta_matrix=reshape(theta,4,3);
    theta_matrix=transpose(theta_matrix);

    row_names={'Low','Mid','High'};
    col_names={'Manual','Social','Routine','Abstract'};
    
    theta_matrix=array2table(theta_matrix,'VariableNames', col_names,'RowNames',row_names);

    
    %Next I compute the comparative advantage
    comparative=theta_matrix;
    comparative.Manual=theta_matrix.Manual./theta_matrix.Manual;
    comparative.Social=theta_matrix.Social./theta_matrix.Manual;
    comparative.Routine=theta_matrix.Routine./theta_matrix.Manual;
    comparative.Abstract=theta_matrix.Abstract./theta_matrix.Manual;

end


