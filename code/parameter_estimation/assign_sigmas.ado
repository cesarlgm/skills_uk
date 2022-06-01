cap program drop assign_sigmas

program define assign_sigmas, rclass
    version 14.2 
    syntax, sigma_vec(name) job_index(name)

    create_beta_vector, sigma_vec(`sigma_vec')

    matrix assigned_sigma=job_index*r(beta)

    return matrix assigned_sigma=assigned_sigma
end


