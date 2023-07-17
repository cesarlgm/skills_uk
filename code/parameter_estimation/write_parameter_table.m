function [theta_table,pi_table,sigma_table]=write_parameter_table(solution,size_vector,pi_key,beta_key,standard_errors)
    

    %Step 1: separate vector into components
    splitted_vector=assign_parameters(solution,size_vector);
    splitted_se=assign_parameters(standard_errors,size_vector);

    theta=splitted_vector{1};
    pi=splitted_vector{2};
    beta=splitted_vector{3};

    theta_se=splitted_se{1};
    pi_se=splitted_se{2};
    beta_se=splitted_se{3};

    %Step 2: add the estimates to the pi table
    pi_key.estimate=pi;
    pi_table=pi_key;
    pi_table.se=pi_se;
    pi_table.t=pi_table.estimate./pi_table.se;

    %Step 3: create theta table
    theta_code=[11;12;13;14;21;22;23;24;31;32;33;34];
    theta_education=floor(theta_code/10);
    theta_skill=theta_code-floor(theta_code/10)*10;

    theta_table=array2table([theta_code,theta_education,theta_skill],'VariableNames',{'theta_code','education','skill'});
    theta_table.estimate=theta;
    theta_table.se=theta_se;

    %Step 4: create the table with sigma estimates
    sigma=1./(1-beta);
    sigma_table=beta_key;
    sigma_table.estimate=sigma;
end