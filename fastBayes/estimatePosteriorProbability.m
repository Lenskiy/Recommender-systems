function Pr_CategoryGivenI = estimatePosteriorProbability(logPr_ItemInCategory, Pr_Category)
    Nitems = size(logPr_ItemInCategory,1);
    Ncategories = size(logPr_ItemInCategory,2);
    
    
    %Prior probability of an item
    logPr_Item = zeros(Nitems);
    %Posterior probability of the class
    Pr_CategoryGivenI = zeros(Ncategories, Nitems);
	logPr_Category = log(Pr_Category);
% 	for i = 1:Nitems
%         logPr_Item(i) = log(sum(exp(logPr_Category + logPr_ItemInCategory(i, :)))); % underflow here
%         Pr_CategoryGivenI(:, i) = logPr_Category + logPr_ItemInCategory(i, :);% -  logPr_Item(i,r);
% 	end
    for i = 1:Nitems
        Pr_CategoryGivenI(:,i) = logPr_ItemInCategory(i,:) + logPr_Category;
    end
end