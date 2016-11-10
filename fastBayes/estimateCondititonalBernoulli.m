function logPr_ItemInCategory = estimateCondititonalBernoulli(R, Pr_UratedC)
    Nitems = size(R,2);                 %number of items
    R = double(R ~= 0);
    Nusers = size(R,1);       %number of users
    Ncategories = size(Pr_UratedC, 2);  %number of genres

    available_memory = 2^30; %30
    
    div_coef = ceil(size(R,1) * size(R,2) * 8  / available_memory);
    Nusers_part = floor(Nusers/div_coef);
    
    % Estimate conditional probability of Item i given Class c
    logPr_ItemInCategory = zeros(Nitems, Ncategories); % allocate memory

	for c = 1:Ncategories
        logPr_ItemInCategory_part = 0;
        for j = 1:div_coef - 1
            %j/div_coef
            sliceOfUsers = ((j - 1) * Nusers_part + 1):(j * Nusers_part);
            Rt = R(sliceOfUsers, :);
            Rt_neg = ~Rt;
            Pr_UratedC_temp_vec = Pr_UratedC(sliceOfUsers, c);
            t = bsxfun(@power, Pr_UratedC_temp_vec, Rt) .* bsxfun(@power, 1 - Pr_UratedC_temp_vec, Rt_neg);
            logPr_ItemInCategory_part = logPr_ItemInCategory_part +  sum(log(t));
        end
        %process the remainder part that is smaller than the block size Nusers_part
        sliceOfUsers = ((div_coef - 1) * Nusers_part + 1):Nusers;
        Rt = R(sliceOfUsers, :);
        Rt_neg = ~Rt;
        Pr_UratedC_temp_vec = Pr_UratedC(sliceOfUsers, c);
        t = bsxfun(@power, Pr_UratedC_temp_vec, Rt) .* bsxfun(@power, (1 - Pr_UratedC_temp_vec), Rt_neg);
        logPr_ItemInCategory(:, c) = logPr_ItemInCategory_part...
            + sum(log(t));         
    end
end