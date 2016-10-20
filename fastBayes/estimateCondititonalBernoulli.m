function logPr_ItemInCategory = estimateCondititonalBernoulli(Pr_UratedC, R)
    Nitems = size(R,2);                 %number of items
    
    Nusers = size(R,1);       %number of users
    Ncategories = size(Pr_UratedC, 2);  %number of genres

    available_memory = 2^20; %30
    
    div_coef = ceil(size(R,1) * size(R,2) * 8  / available_memory);
    Nusers_part = floor(Nusers/div_coef);
    
    % Estimate conditional probability of Item i given Class c
    logPr_ItemInCategory = zeros(Nitems, Ncategories, Nrates); % allocate memory

	for c = 1:Ncategories
        logPr_ItemInCategory_part = 0;
        t = 1;
        for j = 1:div_coef - 1
            %j/div_coef
            Rt = R(((j - 1) * Nusers_part + 1):(j * Nusers_part), :);
            Rt_neg = ~Rt;
            Pr_UratedC_temp_vec = Pr_UratedC(((j - 1) * Nusers_part + 1):(j * Nusers_part), c);
            t = t .* (bsxfun(@times, Rt, Pr_UratedC_temp_vec)...
                + bsxfun(@times, Rt_neg, 1 - Pr_UratedC_temp_vec));
        end
        logPr_ItemInCategory_part = logPr_ItemInCategory_part +  sum(log(t));
        %process the remainder part that is smaller than the block size Nusers_part
        Rt = R(((div_coef - 1) * Nusers_part + 1):Nusers, :);
        Rt_neg = ~Rt;
        Pr_UratedC_temp_vec = Pr_UratedC(((div_coef - 1) * Nusers_part + 1):Nusers, c);
        logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory_part...
            + sum(log(bsxfun(@times, Rt, Pr_UratedC_temp_vec)...
            + bsxfun(@times, Rt_neg, (1 - Pr_UratedC_temp_vec))));         
    end

end