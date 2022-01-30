function full_weights=transform_weights(scale_weights,restricted_weights,alpha_restrictions)   
    D=alpha_restrictions{1,1};
    b=alpha_restrictions{3,1};

    if restricted_weights==0
        full_weights=restricted_weights;
    else
        full_weights=D*scale_weights+b;
    end
end