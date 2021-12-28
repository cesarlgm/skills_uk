%wrapper of theta estimation
function [theta,job_type]=theta_wrapper(skill_indexes,data,observation_trackers)
    %Step 1: structure average data to estimate the thetas
    regression_data=create_regression_data(skill_indexes,...
        data,observation_trackers);

    %STEP 2: estimate beta
    [beta,~,job_type]=estimate_beta_theta(regression_data);

    %STEP 3: estimate theta
    theta=estimate_theta(beta,job_type);
end