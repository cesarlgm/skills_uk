%==========================================================================
%CREATE SOLUTION ARRAY
%Description> this function is wrapper for the theta estimation problem
%==========================================================================


function [solution_array,MSE_array,n_educ]=create_solution_array(fun, ...
    n_initial_cond,scale_restriction_mat,computation_information,observation_trackers)

        n_skills=computation_information{1};
        normalize_index=computation_information{3};
        n_scale_vector=computation_information{4};


        solution_array={};
        MSE_array={};

        %STEP 1
        %First I create the matrix of initial conditions
        n_scales=sum(normalize_index==0);

        n_educ=length(unique(observation_trackers{1}(:,2)));

        initial_guess=create_initial_guess(n_scales,n_skills,n_initial_cond,n_scale_vector);

        n_parameters=size(initial_guess,1);


        parfor i=1:n_initial_cond 
            display(i)
            [solution,MSE]=fmincon(fun,initial_guess(:,i),parameter_restriction_matrix,restriction_b,[],[],lower_bounds, ...
               upper_bounds,[],options);
            solution_array{i}=solution;
            MSE_array{i}=MSE;
        end
end