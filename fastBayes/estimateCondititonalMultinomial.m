function logPr_ItemInCategory = estimateCondititonalMultinomial(R, Pr_UratedC)
    Nitems = size(R,2);     %number of items
    Nusers = size(R,1);       %number of users
    Ncategories = size(Pr_UratedC, 2);  %number of genres

    available_memory = 2^24; %30
    
    div_coef = ceil(size(R,1) * size(R,2) * 8  / available_memory);
    Nusers_part = floor(Nusers/div_coef);
    
    % Estimate conditional probability of Item i given Class c
    logPr_ItemInCategory = zeros(Nitems, Ncategories); % allocate memory
    for c = 1:Ncategories
        %[r, c]
        logPr_ItemInCategory_part = 0;
        for j = 1:div_coef - 1
            %Rt = full(R_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), :)); % in case then data is too large 
            Rt = R(((j - 1) * Nusers_part + 1):(j * Nusers_part), :);
            Pr_UratedC_temp_vec = Pr_UratedC(((j - 1) * Nusers_part + 1):(j * Nusers_part), c);
            logPr_ItemInCategory_part = logPr_ItemInCategory_part + sum(bsxfun(@times, Rt, Pr_UratedC_temp_vec));
        end
        %process the remainder part that is smaller than the block size Nusers_part
        Rt = R(((div_coef - 1) * Nusers_part + 1):Nusers, :);
        Pr_UratedC_temp_vec = log(Pr_UratedC(((div_coef - 1) * Nusers_part + 1):Nusers, c));
        logPr_ItemInCategory(:, c) = logPr_ItemInCategory_part + sum(bsxfun(@times, Rt, Pr_UratedC_temp_vec));
    end
end
