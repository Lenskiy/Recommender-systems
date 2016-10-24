function [avgPrediction, stdPrediction,... 
          avgPredictionSim, stdPredictionSim,...
          avgPredictionCombined, stdPredictionCombined,...
          avgPredictionCombinedSim, stdPredictionCombinedSim]...
        = estimateBayesianGenrePrediction(...
          R, G, Ntrials, trainingPortion,...
          estUserPreferencesFn,...
          estLiklihoodFn,...
          estPosteriorProbabilityFn)
        
    corThreshold = 0.1; % two generes are consideted to be similar if their cor. coef is above corThreshold
    testingPortion = 0.2;
    
    numRtype = sum((unique(R) ~= 0));
    Nitems = size(R,2);
    Ncatergoies = size(G,2);
    maxNumOfGenPerMovies = max(sum(G~=0, 2));
    [corMat, ~] = corr(G, 'rows','pairwise');
%     corMat(logical(eye(size(corMat)))) = 0;
%     imagesc(corMat), hold on;
%     colorbar;
%     ax = gca;
%     ax.XTick = [1:Ngenres];
%     ax.YTick = [1:Ngenres];
%     ax.XTickLabel = movie_genre;
%     ax.YTickLabel = movie_genre;
%     set(gca, 'XTickLabelRotation', 45)
%     
%     [i, j] = find(corMat > corThreshold);
%     upperInd = i > j;
%     plot(i(upperInd),j(upperInd), '.r','MarkerSize', 20);

    
%     Rs = zeros(size(R, 1), size(R, 2), numRtype);
%     for r = 1:numRtype
%         Rs(:,:,r) = (R == r);
%     end
    
    %preallocate memory to store results
    avgPrediction = zeros(length(trainingPortion), maxNumOfGenPerMovies, numRtype);
    stdPrediction = zeros(length(trainingPortion), maxNumOfGenPerMovies, numRtype);
    avgPredictionSim = zeros(length(trainingPortion), maxNumOfGenPerMovies, numRtype);
    stdPredictionSim = zeros(length(trainingPortion), maxNumOfGenPerMovies, numRtype);  
    avgPredictionCombined = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    stdPredictionCombined = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    
    %calculate genre prediction for different sizes of the training set 
    parfor j = 1:length(trainingPortion)
        disp([num2str(j/length(trainingPortion))]);
        
        % allocate memory
        Nitems_test = floor(Nitems*testingPortion);
        counterPredictionRate = zeros(Ntrials, maxNumOfGenPerMovies, numRtype);
        counterSimPredictionRate = zeros(Ntrials, maxNumOfGenPerMovies, numRtype);
        counterCombinedPredictionRate = zeros(Ntrials, maxNumOfGenPerMovies);
        counterCombinedSimPredictionRate = zeros(Ntrials, maxNumOfGenPerMovies);
        combinedLogPosterior = zeros(Ncatergoies, Nitems_test, numRtype);
        log_posterior_combined_test = zeros(Ncatergoies, Nitems_test);
        
        % do Ntrials, then claculate the statistics
        for k = 1:Ntrials
            % select training samples randomly
            training_subset_ind = randperm(Nitems, floor(Nitems * trainingPortion(j)));
            % choose remaining samples that are not part of training set
            testing_subset_ind =  setdiff(1:Nitems, training_subset_ind);   
            testing_subset_ind =  testing_subset_ind(randperm(length(testing_subset_ind), floor(Nitems*testingPortion)));

            G_train = G(training_subset_ind,:);
            G_test = G(testing_subset_ind,:);
            
            trueGenreCategories = cell(Nitems_test);
            trueCategoriesIncSimilar = cell(Nitems_test);
            for l = 1:Nitems_test
                %counting correct prediction of exact categories 
                trueGenreCategories{l} = find(G_test(l,:) ~= 0);
                for g = trueGenreCategories{l}  % could be precalculated
                    trueCategoriesIncSimilar{l} = unique([trueCategoriesIncSimilar{l}, find(corMat(g,:) > corThreshold)]);
                end   
            end
 
            %prior_train = estimate_prior_probability(G_train);
            for r = 1:numRtype
                [prior_train, puc_train] = estUserPreferencesFn(R(:, training_subset_ind) == r, G_train);
                log_pic_test = estLiklihoodFn(R(:, testing_subset_ind) == r, puc_train);
                log_posterior_test = estPosteriorProbabilityFn(log_pic_test, prior_train);
                combinedLogPosterior(:,:,r) = log_posterior_test;
                [performance, performanceSim] = performanceRate(log_posterior_test, G_test, trueGenreCategories, trueCategoriesIncSimilar);
                counterPredictionRate(k, 1:length(performance), r) = performance;
                counterSimPredictionRate(k, 1:length(performanceSim), r)  = performanceSim;
            end
            
            for i = 1:Nitems_test
                log_posterior_combined_test(:, i) = sum(squeeze(combinedLogPosterior(:,i,:)), 2);
            end
                [performance, performanceSim] = performanceRate(log_posterior_combined_test, G_test, trueGenreCategories, trueCategoriesIncSimilar);               

                counterCombinedPredictionRate(k, 1:length(performance)) = performance;
                counterCombinedSimPredictionRate(k, 1:length(performanceSim))  = performanceSim;             
        end
        % Calculate the statistics
        avgPrediction(j, :, :) = mean(counterPredictionRate);
        stdPrediction(j, :, :) = std(counterPredictionRate);
        avgPredictionSim(j, :, :) = mean(counterSimPredictionRate);
        stdPredictionSim(j, :, :) = std(counterSimPredictionRate);
        avgPredictionCombined(j, :) = mean(counterCombinedPredictionRate);
        stdPredictionCombined(j, :) = std(counterCombinedPredictionRate);
        avgPredictionCombinedSim(j, :) = mean(counterCombinedSimPredictionRate);
        stdPredictionCombinedSim(j, :) = std(counterCombinedSimPredictionRate);          
    end
end