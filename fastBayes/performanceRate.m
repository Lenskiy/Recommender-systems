function [predictionRate1, predictionRate2] = performanceRate(log_posterior, G, trueGenreCategories1, trueGenreCategories2)
    numItems = size(G,1);
    maxNumOfGenPerMovies = max(sum(G~=0, 2));
    
    %Allocate memory
    counterCorrectPrediction1 = zeros(maxNumOfGenPerMovies, 1);
    counterCorrectPrediction2 = zeros(maxNumOfGenPerMovies, 1);
    numMoviesNumGeners(maxNumOfGenPerMovies) = 0;
    predictionRate1(maxNumOfGenPerMovies) = 0;
    predictionRate2(maxNumOfGenPerMovies) = 0;
    
    for k = 1:numItems
        %counting correct prediction of exact categories 
%         true_categories = find(G(k,:) ~= 0);
        %counting correct prediction of exact and similar categories 
%         true_categories_inc_similar = [];
%         for g = true_categories % could be precalculated
%             true_categories_inc_similar = unique([true_categories_inc_similar, find(corMat(g,:) > corThreshold)]);
%         end  
        true_categories = trueGenreCategories1{k};
        [~, estimated_category] = maxN(log_posterior(:, k), numel(true_categories));
        
        for c = 1:max(length(true_categories))
            % Check if the predicted C categories is wihtin the most C probable categories
            overlap_pred = MY_intersect(estimated_category(1:c), true_categories(1:c));
            
            if(length(overlap_pred) == c)
                counterCorrectPrediction1(c) = counterCorrectPrediction1(c) + 1;
            end
            % Check if the predicted C categories is wihtin the all true categories
            overlap_pred = MY_intersect(estimated_category(1:c), trueGenreCategories2{k}); 
            
            if(length(overlap_pred) == c)
                counterCorrectPrediction2(c) = counterCorrectPrediction2(c) + 1;
            end            
        end
    end

    for k = 1:maxNumOfGenPerMovies
        numMoviesNumGeners(k) = sum(sum(ceil(G), 2) == k);
    end
    
    for k = 1:maxNumOfGenPerMovies
        predictionRate1(k) = counterCorrectPrediction1(k) / sum(numMoviesNumGeners(k:end));
        predictionRate2(k) = counterCorrectPrediction2(k) / sum(numMoviesNumGeners(k:end));
    end
end