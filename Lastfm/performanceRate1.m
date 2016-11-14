function [predictionRate] = performanceRate1(Gpost, Gtarget, trueGenreCategories)
    numItems = size(Gtarget,1);
    maxNumOfCatPerItem = max(sum(Gtarget~=0, 2));
    
    %Allocate memory
    counterCorrectPrediction = zeros(maxNumOfCatPerItem, 1);
    numItemsInCats(maxNumOfCatPerItem) = 0;
    predictionRate(maxNumOfCatPerItem) = 0;
    
    for k = 1:numItems
        true_categories = trueGenreCategories{k};
        [~, estimated_category] = maxN(Gpost(:, k), numel(true_categories));
        
        for c = 1:max(length(true_categories))
            % Check if the predicted C categories is wihtin the most C probable categories
            overlap_pred = MY_intersect(estimated_category(1:c), true_categories(1:c));
            
            if(length(overlap_pred) == c)
                counterCorrectPrediction(c) = counterCorrectPrediction(c) + 1;
            end           
        end
    end

    for k = 1:maxNumOfCatPerItem
        numItemsInCats(k) = sum(sum(ceil(Gtarget), 2) == k);
    end
    
    for k = 1:maxNumOfCatPerItem
        predictionRate(k) = counterCorrectPrediction(k) / sum(numItemsInCats(k:end));
    end
end