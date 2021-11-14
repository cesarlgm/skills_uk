function [solution,i_matrix]=solve_weight_problem(data,education_vector,scale_solution,skill_indexes)
    n_educ=length(unique(education_vector));

    %Step 1: compute the index matrix for mid and high_education level
    [i_matrix,n_indexes]=create_index_matrix(data,skill_indexes,scale_solution,education_vector);

    options = optimset('PlotFcns',@optimplotfval,'TolX',1e-10,'MaxFunEvals',10000e3);
    
    p=transpose(2:7);


    %Anonymizing the function
    fun=@(p)square_error_wg(p,i_matrix,n_indexes);
    
    n_parameters=(n_indexes-1)*(n_educ-1)
    parameter0=ones(n_parameters,1);

    %Solving the problem
    solution=fmincon(fun,parameter0,[],[],[],[],zeros(n_parameters,1),[],[],options);

end