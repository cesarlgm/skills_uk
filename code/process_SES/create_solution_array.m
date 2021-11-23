function [solution_array,MSE_array,n_educ]=create_solution_array(fun, ...
    n_initial_cond,  normalize_index,scale_restriction_mat,education_index,...
    index_composition,n_scale_vector)

        n_skills=sum(index_composition);

        solution_array={};
        MSE_array={};

        %STEP 1
        %First I create the matrix of initial conditions
        n_scales=sum(normalize_index==0);
        n_educ=length(unique(education_index));
        n_indexes=length(index_composition);


        [initial_guess,lower_bounds]=create_initial_guess(n_scales,n_skills,n_educ,...
            n_indexes,n_initial_cond,n_scale_vector);

        n_parameters=size(initial_guess,1);

        
        %STEP 2
        %fix size of mrestruction matrix
        missing_columns=n_parameters-size(scale_restriction_mat,2);
        restriction_size=size(scale_restriction_mat,1);
        parameter_restriction_matrix=horzcat(scale_restriction_mat, ...
               zeros(restriction_size,missing_columns));
        size(parameter_restriction_matrix)
        restriction_b=zeros(restriction_size,1);
        
        %STEP 3: create the vector of upper bounds
        upper_bounds=vertcat(ones(n_scales,1),Inf*ones(missing_columns,1));


        %STEP 5: solve the problem
        options = optimset('TolX',1e-10,'MaxFunEvals',10000e3);

        parfor i=1:n_initial_cond 
            display(i)
            [solution,MSE]=fmincon(fun,initial_guess(:,i),parameter_restriction_matrix,restriction_b,[],[],lower_bounds, ...
               upper_bounds,[],options);
            solution_array{i}=solution;
            MSE_array{i}=MSE;
        end
end