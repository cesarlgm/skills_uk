function [initial_guess,lower_bounds]=create_initial_guess(n_scales,n_skills,n_educ,...
      n_indexes,n_initial_cond,n_scale_array)
    
    n_scale_array=n_scale_array-2;

    temp=rand(n_scales,n_initial_cond)*1/4;
    
    temp=mat2cell(temp,n_scale_array,n_initial_cond);

    for i=1:length(temp)
        temp_guess=cumsum(temp{i},1);
        if i==1
            scale_guess=temp_guess;
        else
            scale_guess=vertcat(scale_guess,temp_guess);
        end
    end

    scale_weight_guess=rand(n_skills,n_initial_cond);
    total_sum_guess=rand(n_educ-1,n_initial_cond)+1;
    index_weight_guess=2*rand((n_indexes-1)*(n_educ-1),n_initial_cond);

    initial_guess=vertcat(scale_guess,scale_weight_guess,total_sum_guess,index_weight_guess);

    %Here I create the vector of lower bounds
    start_sums=size(scale_guess,1)+size(scale_weight_guess,1);
    end_sums=start_sums+size(total_sum_guess,1);

    lower_bounds=zeros(size(initial_guess,1),1);

    lower_bounds(start_sums+1:end_sums,1)=1;
end