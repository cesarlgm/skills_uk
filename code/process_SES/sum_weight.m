function [c,ceq]=sum_weight(weight)
    c=[];
    ceq=sum(exp(weight))-1;
end