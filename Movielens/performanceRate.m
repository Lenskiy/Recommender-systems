function [predictionRate, predictionSimRate] = performanceRate(log_posterior, G, trueGenreCategories, trueCategoriesIncSimilar)
    numItems = size(G,1);
    maxNumOfGenPerMovies = max(sum(G~=0, 2));
    
    %Allocate memory
    counterCorrectPrediction = zeros(maxNumOfGenPerMovies, 1);
    counterCorrectPredictionIncSimilar = zeros(maxNumOfGenPerMovies, 1);
    numMoviesNumGeners(numItems) = 0;
    predictionRate(maxNumOfGenPerMovies) = 0;
    predictionSimRate(maxNumOfGenPerMovies) = 0;
    
    for k = 1:numItems
        %counting correct prediction of exact categories 
%         true_categories = find(G(k,:) ~= 0);
        %counting correct prediction of exact and similar categories 
%         true_categories_inc_similar = [];
%         for g = true_categories % could be precalculated
%             true_categories_inc_similar = unique([true_categories_inc_similar, find(corMat(g,:) > corThreshold)]);
%         end  
        true_categories = trueGenreCategories{k};
        [~, estimated_category] = maxN(log_posterior(:, k), numel(true_categories));
        
        for c = 1:max(length(true_categories))
            overlap_pred = MY_intersect(estimated_category(1:c), true_categories);
            
            if(length(overlap_pred) == c)
                counterCorrectPrediction(c) = counterCorrectPrediction(c) + 1;
            end
            
            overlap_pred = MY_intersect(estimated_category(1:c), trueCategoriesIncSimilar{k});
            
            if(length(overlap_pred) == c)
                counterCorrectPredictionIncSimilar(c) = counterCorrectPredictionIncSimilar(c) + 1;
            end            
        end

        numMoviesNumGeners(k) = sum(sum(G') == k);
    end
    
    for k = 1:maxNumOfGenPerMovies
        predictionRate(k) = counterCorrectPrediction(k) / sum(numMoviesNumGeners(k:end));
        predictionSimRate(k) = counterCorrectPredictionIncSimilar(k) / sum(numMoviesNumGeners(k:end));
    end
end