function [n_positive_bs,significant_positive,positive_bs,t_stat_bs]=get_n_positive_bs(solution, standard_errors,size_vector)
    separated_parameters=assign_parameters(solution,size_vector);
    separated_errors=assign_parameters(standard_errors,size_vector);

    bs=separated_parameters{3};
    bs_se=separated_errors{3};

    t_stat=bs./bs_se;

    critical_value=norminv(.95);
    
    positive_bs=bs(bs>0);
    t_stat_bs=bs_se(bs>0);

    is_positive_bs=t_stat>critical_value;

    n_positive_bs=sum(bs>0);
    significant_positive=sum(is_positive_bs);
end