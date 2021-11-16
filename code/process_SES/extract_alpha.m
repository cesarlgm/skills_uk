function s_alpha=extract_alpha(alpha,varnames)
    s_alpha=array2table(transpose(alpha),'VariableNames',varnames);
end