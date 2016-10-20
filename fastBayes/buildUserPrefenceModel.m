function [Pr_Category, Pr_UratedC] = buildUserPrefenceModel(R, G)
    Nusers = size(R,1);     %number of users
    Ncategories = size(G,2);    %number of genres
    %G = logical(G);
    
    %Estimate prior probabilities 
    total_ratings = zeros(Ncategories,1);
    Pr_UratedC = zeros(Nusers, Ncategories); % allocate memory
    G_ = G';
    for c = 1:Ncategories
        Pr_UratedC_temp = sum(bsxfun(@times, R, G_(c,:)), 2);
        total_ratings(c) = sum(Pr_UratedC_temp);
        Pr_UratedC(:,c) = (Pr_UratedC_temp + 1) / (total_ratings(c) + Nusers);
    end
 
	Pr_Category = (sum(G) + 1)/( sum(sum(G)) + size(G,2));
    
end