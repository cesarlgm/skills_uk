function theta_table=create_theta_table(theta)
    %I assign education and skill indexes
    theta_code=[11;12;13;14;21;22;23;24;31;32;33;34];

    theta_table=array2table([theta_code,theta], 'VariableNames', {'code','theta'});

    theta_table.education=floor(theta_table.code/10);
    theta_table.skill=theta_table.code-theta_table.education*10;

    theta_table=theta_table(:,{'code','education','skill','theta'});
end