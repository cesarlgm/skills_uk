function s_alpha=extract_alpha(solution,n_scales,indexes,varnames)
    no_scales=sum(n_scales-2);
    alpha=solution(no_scales+1:length(solution),1);

    %[D,b,~]=alpha_restrictions(indexes);

    s_alpha=alpha; %D*alpha+b;

    s_alpha=array2table(transpose(s_alpha),'VariableNames',varnames);
end