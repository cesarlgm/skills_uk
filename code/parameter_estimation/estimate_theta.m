function theta=estimate_theta(beta_theta,job_type)
    n_types=length(unique(job_type));
    vector_size=size(beta_theta,1)/n_types;

    %v_sizes is just the vector of sizes that mat2cell requires for
    %splitting adequately the vector
    v_sizes=repmat(vector_size,n_types,1);

    beta_cell=mat2cell(beta_theta,v_sizes,1);
    theta_cell=cell(n_types);

    for i=1:n_types 
        %correction term
        correction=-beta_cell{1}(1)+beta_cell{i}(1);
        theta_cell{i}=beta_cell{i}./(correction+beta_cell{1});
    end

    theta=vertcat(theta_cell{:});
end