function [scale_matrix,alpha_vec,s_weights,MSE,index_matrix]=solve_skill_problem(data,index_composition)
    %STRUCTURE OF THE PARAMETER VECTOR
    % Scales - scale weights - index weights 
    
    %STEP 1: extract data required for calibration of scales
    [skill_data,education_index,n_skills,index_names]=extract_scale_data(data);

    %STEP 2: create matrix of dummies for the scales
        % - In this step I also create an index indicating with scales are 
        %   normalized to zero (-1) and to (1).
    [skill_dummies,normalize_index]=create_scale_dummies(skill_data);
    
    %STEP 3: create the matrices of non-negativity restrictions 
    [scale_mult_matrix,scale_restriction_mat]=create_scaling_matrix(skill_dummies,skill_data);

    %STEP 4: set up initial condition
    %in the to do> handle the initial condition
    n_scales=sum(normalize_index==0);
    n_educ=length(unique(education_index));
    n_indexes=length(index_composition);

    %parameter0=transpose([0.222579700657215,0.805915707554167,0.805934255512936,0.998742098480153,0.998753548886498,0.998759395160812,0.988453838035417,0.988454324399959,0.988454643404971,0.268104124114063,0.270362961075603,0.453779683934298,0.284155521668228,0.32396871550592,0.465747332247708,0.283388060944434,0.291911760201956,0.999689697420195,0.999716612484963,0.999750308598423,0.000012087123588704,6.74430860574033E-05,0.0457083770487271,0.817572150744241,0.892346102038369,0.892358765167264,0.0746904166643458,0.489138219930771,0.723176281516481,0.162148714673458,0.44411378742385,0.760574778420233,1.13787670194296E-05,3.35993452899801E-05,5.79782400666725E-05,0.95568806148284,0.955689575984563,0.955715177974054,0.00028266608974846,0.000490027065999569,0.000633699604492,0.97761574994023,0.988787925826292,0.992652765015978,0.226806873696037,0.50872580499229,0.778595679594773,0.132375248541863,0.438751590280475,0.771912191447761,0.000460671536995092,0.000478939365235358,0.000509850082433456,0.999996164262167,0.999997761749677,0.999998697141552,0.999998140523949,0.999999119547604,0.999999501737552,0.00948107158860159,0.00953213215598239,0.018938917250085,0.15907239066474,0.125441806659596,0.130020889801743,0.0306043687342344,0.0033618962325284,0.00420445036520223,0.0467232040026071,4.18328512281006E-07,4.92720365184944E-08,0.00344533542900382,0.149365178327892,0.00229285914866229,0.467041364170443,1.5665746476365E-08,8.74601615739359E-08,0.00378440501170678,0.0245447076756775,0.0922429939712351,0.457402862945524,1.08358140655004,1.17000993048979,0.148535768182651,0.82461224468476,1.36556864186467]);
    parameter0=create_initial_guess(n_scales,n_skills,n_educ,n_indexes);

    fun=@(p)error_function(p,skill_dummies,normalize_index,index_composition, ...
        scale_mult_matrix,education_index);

    n_parameters=size(parameter0,1);

    %STEP 5
    %fix size of mrestruction matrix
    missing_columns=n_parameters-size(scale_restriction_mat,2);
    restriction_size=size(scale_restriction_mat,1);
    parameter_restriction_matrix=horzcat(scale_restriction_mat, ...
           zeros(restriction_size,missing_columns));
    restriction_b=zeros(restriction_size,1);

    upper_bounds=vertcat(ones(n_scales,1),Inf*ones(missing_columns,1));

    %STEP 5: solve the problem
    options = optimset('PlotFcns',@optimplotfval,'TolX',1e-10,'MaxFunEvals',10000e3);
    
    [solution,MSE]=fmincon(fun,parameter0,parameter_restriction_matrix,restriction_b,[],[],zeros(n_parameters,1), ...
       upper_bounds,[],options);

    [scale_matrix,alpha_vec,s_weights,index_matrix]=extract_solution(solution,normalize_index, ...
        n_skills, n_educ,index_names,skill_data,skill_dummies,scale_mult_matrix,index_composition);
end