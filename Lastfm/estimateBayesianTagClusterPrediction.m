function [avgPrediction, stdPrediction,... 
          avgPredictionSim, stdPredictionSim]...
        = estimateBayesianTagClusterPrediction(...
          R, G, Ntrials, trainingPortion,...
          estUserPreferencesFn,...
          estLiklihoodFn,...
          estPosteriorProbabilityFn)
        
    corThreshold = 0.1; % two generes are consideted to be similar if their cor. coef is above corThreshold
    testingPortion = 0.2;
    
    Nitems = size(R,2);
    Ncatergoies = size(G,2);
    maxNumOfGenPerMovies = max(sum(G~=0, 2));
    [corMat, ~] = corr(G, 'rows','pairwise');
% %   plot category Correaltion matrix
%     corMat(logical(eye(size(corMat)))) = 0;
%     imagesc(corMat), hold on;
%     colorbar;
%     ax = gca;
%     ax.XTick = [1:Ncatergoies];
%     ax.YTick = [1:Ncatergoies];
% %     ax.XTickLabel = movie_genre;
% %     ax.YTickLabel = movie_genre;
%     set(gca, 'XTickLabelRotation', 45)
    
%     [i, j] = find(corMat > corThreshold);
%     upperInd = i > j;
%     plot(i(upperInd),j(upperInd), '.r','MarkerSize', 20);
    
    %preallocate memory to store results
    avgPrediction = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    stdPrediction = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    avgPredictionSim = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    stdPredictionSim = zeros(length(trainingPortion), maxNumOfGenPerMovies);  
    
    %calculate genre prediction for different sizes of the training set 
    parfor j = 1:length(trainingPortion)
        disp([num2str(j/length(trainingPortion))]);
        
        % allocate memory
        Nitems_test = floor(Nitems*testingPortion);
        counterPredictionRate = zeros(Ntrials, maxNumOfGenPerMovies);
        counterSimPredictionRate = zeros(Ntrials, maxNumOfGenPerMovies);
        
        % do Ntrials, then claculate the statistics
        for k = 1:Ntrials
            % select training samples randomly
            training_subset_ind = randperm(Nitems, floor(Nitems * trainingPortion(j)));
            % choose remaining samples that are not part of training set
            testing_subset_ind =  setdiff(1:Nitems, training_subset_ind);   
            testing_subset_ind =  testing_subset_ind(randperm(length(testing_subset_ind), floor(Nitems*testingPortion)));

            G_train = G(training_subset_ind,:);
            G_test = G(testing_subset_ind,:);
            
            trueGenreCategories = cell(Nitems_test, 1);
            trueCategoriesIncSimilar = cell(Nitems_test, 1);
            for l = 1:Nitems_test
                %counting correct prediction of exact categories
                [svals, sinds] = sort(G_test(l,:), 'descend');
                trueGenreCategories{l} = sinds(find(svals > 0));
                %trueGenreCategories{l} = find(G_test(l,:) ~= 0);
                for g = trueGenreCategories{l} 
                    trueCategoriesIncSimilar{l} = unique([trueCategoriesIncSimilar{l}, find(corMat(g,:) > corThreshold)]);
                end   
            end
 
            %prior_train = estimate_prior_probability(G_train);
%             for r = 1:numRtype
                [prior_train, puc_train] = estUserPreferencesFn(R(:, training_subset_ind), G_train);
                log_pic_test = estLiklihoodFn(R(:, testing_subset_ind), puc_train);
                log_posterior_test = estPosteriorProbabilityFn(log_pic_test, prior_train);
                [performance, performanceSim] = performanceRate(log_posterior_test, G_test, trueGenreCategories, trueGenreCategories);
                counterPredictionRate(k, 1:length(performance)) = performance;
                counterSimPredictionRate(k, 1:length(performanceSim))  = performanceSim;
%             end          
        end
        % Calculate the statistics
        avgPrediction(j, :, :) = mean(counterPredictionRate);
        stdPrediction(j, :, :) = std(counterPredictionRate);
        avgPredictionSim(j, :, :) = mean(counterSimPredictionRate);
        stdPredictionSim(j, :, :) = std(counterSimPredictionRate);      
    end
end