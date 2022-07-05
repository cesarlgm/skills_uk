%==========================================================================
%CREATE SOLUTION ARRAY
%Description> this function is wrapper for the theta estimation problem.
%==========================================================================

%Arguments
% skill_data> skill fata coming from the SES

% empshares> changes in employment shares in core jobs comming from the
% LFS.

% index_composition> vector indivating mapping of skills to skill indexes.

% n_initial_cond> number of initial guesses to compute. All guesses are
% generated randomly out of a uniform distribution. Code is slightly
% modified to make sure that the initial conditions fit the problem
% restrictions.

%==========================================================================

%OUTPUT
function solution= solve_skill_problem(skill_path,empshare_path,index_composition, ...
    n_initial_cond, tolerance,max_iter,restricted_weights)

    %STRUCTURE OF THE PARAMETER VECTOR
    % Scales - scale weights
    
      [skill_data,skill_obs_tracker,n_skills,index_names]=extract_scale_data(skill_path);
    
    [empshares,empshare_tracker]=extract_share_data(empshare_path);
    
    %Compute number of scales in the data
    n_scale_vector=count_n_scales(skill_data);
    
    %STEP 2: create matrix of dummies for the scales
        % - In this step I also create an index indicating with scales are 
        %   normalized to zero (-1) and to (1).
    [scale_dummies,normalize_index]=create_scale_dummies(skill_data);
    
    %STEP 3: create the matrices of non-negativity restrictions 
    [scale_mult_matrix,minimization_input]= ...
        create_scaling_matrix(scale_dummies,skill_data);

    %STEP 4: add weight normalizations if needed.
    if restricted_weights==1
        alpha_restrictions=create_alpha_restrictions(index_composition);
    else
        alpha_restrictions=[];
    end

    
    observation_trackers={skill_obs_tracker,empshare_tracker};
    
    data={scale_dummies,scale_mult_matrix,empshares,skill_data};
    
    computation_information={n_skills,index_composition,normalize_index,n_scale_vector};

    %%
    %CREATING INITIAL GUESS
    n_scales=sum(computation_information{3}==0);
    n_weights=sum(index_composition);
    old_scales=create_initial_guess(n_scales,n_weights,...
        1,computation_information{4});

    %Step 1: split the vector into scales and weights
    [scale_vector,scale_weights]=split_parameters(...
        old_scales,computation_information);

    %Step 2: I take the scale observations and compute skill indexes
    skill_indexes=create_skill_index(scale_vector, ...
        scale_weights,data,computation_information);
    %%

    %Write while loop here
    deviation=1000;
    n=0;
    while (deviation>tolerance)||(n<max_iter) 
        %loop over thetas here

        %I just want a function that takes parameters and spits out a
        %theta
        new_theta=get_theta(parameter_vector, ...
            data, observation_trackers,computation_information);

        %Now I use that theta to estimate the scales
        new_scales=get_scales(new_theta,old_scales, data, ...
        computation_information,minimization_input,job_type_index);

        %update the loop trakers
        deviation=norm(new_theta-old_theta);
        n=n+1;
        
        %update the parameters I search for
        old_scales=new_scales;
        old_theta=new_theta;
    end
    
    
    fun=@(p)error_wrapper(p, data,observation_trackers,computation_information);

    [solution,MSE]=fmincon(fun,trial_vector,parameter_restriction_matrix,restriction_b,[],[],lower_bounds, ...
               upper_bounds,[],options);

    %Create solution array goes into the shelf now, while I figure this out
    %[solution_array,MSE_array,n_educ]= ...
     %   create_solution_array(fun, n_initial_cond, ...
      %  scale_restriction_mat,computation_information,observation_trackers);


    %[scale_array,alpha_array,theta_array,theta_matrix_array, ...
     %   skill_index_array]=extract_solution(solution_array,index_names,n_educ,...
      %  data,computation_information,observation_trackers);
end