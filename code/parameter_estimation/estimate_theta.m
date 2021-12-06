function theta=estimate_theta(beta_theta,job_type)
    n_types=length(unique(job_type));
    vector_size=size(beta_theta,1)/n_types;

    v_sizes=repmat(vector_size,n_types,1);

    beta_cell=mat2cell(beta_theta,v_sizes,1);
    theta_cell={};

    for i=1:n_types 
        theta_cell{i}=beta_cell{i}./beta_cell{1};
    end

    theta=vertcat(theta_cell{:});
end