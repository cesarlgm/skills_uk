function beta=OLS(y,X)
    beta=(X'*X)\X'*y;
end