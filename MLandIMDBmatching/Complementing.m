%% Build the User Preference Model

[Pr_Category Pr_UratedC] = buildUserPrefenceModel(R, G);

%% G_* computation

[Pr_Category, Pr_UratedC] = buildUserPrefenceModel(R, G);
logPr_ItemInCategory = estimateCondititonalPrLikelihood(Pr_UratedC, R);
Pr_CategoryGivenI = estimatePosteriorProbability(logPr_ItemInCategory, Pr_Category);
