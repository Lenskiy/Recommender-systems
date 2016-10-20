addpath('../Utilities/');
addpath('../fastBayes/');
% List of movie geners in Movielens 100K dataset
movie_genre = {'Action', 'Adventure', 'Animation',... 
    ['Children' char(39) 's'], 'Comedy', 'Crime', 'Documentary', 'Drama',...
    'Fantasy', 'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',...
    'Sci-Fi', 'Thriller', 'War', 'Western'};

%% Data preparation: replace this section with new data. R is rating and G is category matrix
DB = '20M';
switch(DB)
    case '100k'
        load('../Data/R_G.mat');
        R(:, find(G(:,1) == 1)) = []; % Remove genre 1 - uknown 
        G(find(G(:,1) == 1), :) = []; % Remove genre 1 - uknown
        G(:, 1) = [];
        G_ = bsxfun(@rdivide,G, sum(G')');%convert to probabilities, each row sums up to one
        G_(isnan(G_)) = 0; 
    case '1M'
        load('../Data/R_G_1M.mat');
        G_ = bsxfun(@rdivide,G, sum(G')');
        G_(isnan(G_)) = 0;
    case '20M'
        load('../Data/R_G_20M.mat'); 
        G_ = bsxfun(@rdivide,G, sum(G')');
        G_(isnan(G_)) = 0;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ntrials = 1000;
% estUserPreferencesFn = @estimate_user_probability; %estimate_prior_probability;
% estLiklihoodFn = @estimate_multinomial_item_likelihood;
% estPosteriorProbabilityFn = @estimate_posterior_probability;

estUserPreferencesFn = @buildUserPrefenceModel; % slightly different from @estimate_user_probability
estLiklihoodFn = @estimateCondititonalMultinomial; %estimateCondititonalBernoulli;
estPosteriorProbabilityFn = @estimatePosteriorProbability;

testingPortion = [0.05, 0.1:0.1:0.8];
[avgPrediction, stdPrediction,...
 avgPredictionSim, stdPredictionSim,...
 avgPredictionCombined, stdPredictionCombined,...
 avgPredictionCombinedSim, stdPredictionCombinedSim]...
 = estimateBayesianGenrePrediction(R, G, Ntrials, testingPortion, estUserPreferencesFn, estLiklihoodFn, estPosteriorProbabilityFn);

[topCriticsInds, ratingPortion] = critics(1836, R);
[mostActiveUsersInds, ratingPortion] = mostActiveUsers(466, R);
[leastActiveUsersInds, ratingPortion] = leastActiveUsers(4110, R);

for r = 1:5
    h_ratings(r, 1) = 0.3 * sum(sum(R == r));
    h_ratings(r, 2) = sum(sum(R(topCriticsInds,:) == r));
    h_ratings(r, 3) = sum(sum(R(mostActiveUsersInds,:) == r));
    h_ratings(r, 4) = sum(sum(R(leastActiveUsersInds,:) == r));
end

visualizeHistogram(h_ratings, [1, 2, 3, 4, 5], {'all users', 'critics', 'most active', 'least active'});


[avgPredictionCr, stdPredictionCr,...
 avgPredictionSimCr, stdPredictionSimCr,...
 avgPredictionCombinedCr, stdPredictionCombinedCr,...
 avgPredictionCombinedSimCr, stdPredictionCombinedSimCr]...
 = estimateBayesianGenrePrediction(R(topCriticsInds, :), G, Ntrials, testingPortion, estUserPreferencesFn, estLiklihoodFn, estPosteriorProbabilityFn);


[avgPredictionExp, stdPredictionExp,...
 avgPredictionSimExp, stdPredictionSimExp,...
 avgPredictionCombinedExp, stdPredictionCombinedExp,...
 avgPredictionCombinedSimExp, stdPredictionCombinedSimExp]...
 = estimateBayesianGenrePrediction(R(mostActiveUsersInds, :), G, Ntrials, testingPortion, estUserPreferencesFn, estLiklihoodFn, estPosteriorProbabilityFn);


[avgPredictionLA, stdPredictionLA,...
 avgPredictionSimLA, stdPredictionSimLA,...
 avgPredictionCombinedLA, stdPredictionCombinedLA,...
 avgPredictionCombinedSimLA, stdPredictionCombinedSimLA]...
 = estimateBayesianGenrePrediction(R(leastActiveUsersInds, :), G, Ntrials, testingPortion, estUserPreferencesFn, estLiklihoodFn, estPosteriorProbabilityFn);

%combined ratings
visualizeCategoryPredictionRates(avgPredictionCombined, stdPredictionCombined, testingPortion, {'All users'}, true, struct('Color', 'k', 'LineStyle', ':', 'Linewidth', 2));
visualizeCategoryPredictionRates(avgPredictionCombinedCr, stdPredictionCombinedCr, testingPortion, {'Critics'}, false, struct('Color', 'k', 'LineStyle', '--'));
visualizeCategoryPredictionRates(avgPredictionCombinedExp, stdPredictionCombinedExp, testingPortion, {'Most active'}, false, struct('Color', 'k', 'LineStyle', '-.'));
visualizeCategoryPredictionRates(avgPredictionCombinedLA, stdPredictionCombinedLA, testingPortion, {'Least active'}, false, struct('Color', 'k', 'LineStyle', '-'));

labels = {'r = 1', 'r = 2','r = 3','r = 4','r = 5'};
visualizeCategoryPredictionRates(avgPrediction, stdPrediction, testingPortion, labels, true, struct('LineWidth', 2, 'LineStyle', '-'));
visualizeCategoryPredictionRates(avgPredictionSim, stdPredictionSim, testingPortion, labels, false, struct('Linewidth', 1, 'LineStyle', ':'));



visualizeCategoryPredictionRates(avgPredictionCr, stdPredictionCr, testingPortion, labels, true, struct('LineWidth', 2, 'LineStyle', '-'));
visualizeCategoryPredictionRates(avgPredictionSimCr, stdPredictionSimCr, testingPortion, labels, false, struct('Linewidth', 1, 'LineStyle', ':'));


visualizeCategoryPredictionRates(avgPredictionExp, stdPredictionExp, testingPortion, labels, true, struct('LineWidth', 2, 'LineStyle', '-'));
visualizeCategoryPredictionRates(avgPredictionSimExp, stdPredictionSimExp, testingPortion, labels, false, struct('Linewidth', 1, 'LineStyle', ':'));


visualizeCategoryPredictionRates(avgPredictionLA, stdPredictionLA, testingPortion, labels, true, struct('LineWidth', 2, 'LineStyle', '-'));
visualizeCategoryPredictionRates(avgPredictionSimLA, stdPredictionSimLA, testingPortion, labels, false, struct('Linewidth', 1, 'LineStyle', ':'));



