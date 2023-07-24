function dlnA=get_dlnA(pi_estimates,sigma_estimates)
    pi_estimates=renamevars(pi_estimates,["estimate"],"pi");
    pi_estimates=pi_estimates(:,["occupation","year","skill", "pi"]);

    sigma_estimates=renamevars(sigma_estimates,"estimate","sigma");

    dlnA=outerjoin(pi_estimates,sigma_estimates,'Type','left','MergeKeys',true);

    dlnA.dlnA=dlnA.pi.*(dlnA.sigma./(dlnA.sigma-1));
end