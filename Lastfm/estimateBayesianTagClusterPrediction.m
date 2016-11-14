function [avgPrediction1, stdPrediction1,... 
          avgPrediction2, stdPrediction2]...
        = estimateBayesianTagClusterPrediction(...
          R, pG, G, Ntrials, trainingPortion,...
          estUserPreferencesFn,...
          estLiklihoodFn,...
          estPosteriorProbabilityFn)
        
    corThreshold = 0.1; % two generes are consideted to be similar if their cor. coef is above corThreshold
    testingPortion = 0.2;
    
    Nitems = size(R,2);
    Ncatergoies = size(pG,2);
    maxNumOfGenPerMovies = max(sum(pG~=0, 2));
    [corMat, ~] = corr(pG, 'rows','pairwise');
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
    avgPrediction1 = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    stdPrediction1 = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    avgPrediction2 = zeros(length(trainingPortion), maxNumOfGenPerMovies);
    stdPrediction2 = zeros(length(trainingPortion), maxNumOfGenPerMovies);  
    
    %calculate genre prediction for different sizes of the training set 
    parfor j = 1:length(trainingPortion)
        disp([num2str(j/length(trainingPortion))]);
        
        % allocate memory
        Nitems_test = floor(Nitems*testingPortion);
        counterPredictionRate1 = zeros(Ntrials, maxNumOfGenPerMovies);
        counterPredictionRate2 = zeros(Ntrials, maxNumOfGenPerMovies);
        
        % do Ntrials, then claculate the statistics
        for k = 1:Ntrials
            % select training samples randomly
            training_subset_ind = randperm(Nitems, floor(Nitems * trainingPortion(j)));
            % choose remaining samples that are not part of training set
            testing_subset_ind =  setdiff(1:Nitems, training_subset_ind);   
            testing_subset_ind =  testing_subset_ind(randperm(length(testing_subset_ind), floor(Nitems*testingPortion)));

            pG_train = pG(training_subset_ind,:);
            pG_test = pG(testing_subset_ind,:);
            %G_train = G(training_subset_ind,:);
            G_test = G(testing_subset_ind,:);
            
            trueCategories = cell(Nitems_test, 1);
            trueTopCategories = cell(Nitems_test, 1);
            for l = 1:Nitems_test
                %counting correct prediction of exact categories
                [svals, sinds] = sort(pG_test(l,:), 'descend');
                trueCategories{l} = sinds(find(svals > 0));
                %trueGenreCategories{l} = find(G_test(l,:) ~= 0);
                trueTopCategories{l} = find(G_test(l,:) ~= 0);
%                 for g = trueGenreCategories{l} 
%                     trueCategoriesIncSimilar{l} = unique([trueCategoriesIncSimilar{l}, find(corMat(g,:) > corThreshold)]);
%                 end   
            end
 
            %prior_train = estimate_prior_probability(G_train);
%             for r = 1:numRtype
                [prior_train, puc_train] = estUserPreferencesFn(R(:, training_subset_ind), pG_train);
                log_pic_test = estLiklihoodFn(R(:, testing_subset_ind), puc_train);
                log_posterior_test = estPosteriorProbabilityFn(log_pic_test, prior_train);
                %[performance, performanceSim] = performanceRate(log_posterior_test, pG_test, trueCategories, trueTopCategories);
                performance1 = performanceRate1(log_posterior_test, pG_test, trueCategories);
                performance2 = performanceRate2(log_posterior_test, G_test, trueTopCategories);
                counterPredictionRate1(k, 1:length(performance1)) = performance1;
                counterPredictionRate2(k, 1:length(performance2))  = performance2;
%             end          
        end
        % Calculate the statistics
        avgPrediction1(j, :, :) = mean(counterPredictionRate1);
        stdPrediction1(j, :, :) = std(counterPredictionRate1);
        avgPrediction2(j, :, :) = mean(counterPredictionRate2);
        stdPrediction2(j, :, :) = std(counterPredictionRate2);      
    end
end