%% Data structures
%listened_ARTISTS
%userID \t artistID \t weight
%tagged_ARTISTS
%userID \t artistID \t tagID

addpath('../Utilities/');
addpath('../fastBayes/');
load('../Data/lastfm_2k.mat');

%% Build the tag histogram  and find the most popular tags
[hist_tags]  = histcounts(tagged_ARTISTS(:,3),'BinMethod', 'integers');
unTags = hist_tags(unique(tagged_ARTISTS(:,3)));
figure('Position', [100, 100, 648, 309]), hold on, grid on;
bar(unTags(1:999)); xlabel('tag id'); ylabel('times occured');
[~, popular_tags_ids] = maxN(hist_tags,10); % the most popular tags;
TAGS_name{popular_tags_ids,2}

tagsName = cell(size(TAGS_name,1), 1);
for k = 1:size(TAGS_name,1)
    tagsName{TAGS_name{k,1}} = TAGS_name{k,2};
end

tagsName{hist_tags == 1}

for k = 1:max(hist_tags)
    tagsUsed(k) = sum(hist_tags == k);
end
figure('Position', [100, 100, 648, 309]), hold on, grid on;
bar(tagsUsed(1:99)/sum(hist_tags)); xlabel('$k$', 'Interpreter', 'Latex'); ylabel('portion of all given tags');


%% Build L matrix: L(user, artist) =  times_listen(user,artist);
[L_, uniqueArtistsIDs] = userTimesArtists(listened_ARTISTS);
% figure, mesh(L_(1:1000,1:1000));title('Part of L matrix');
% xlabel('artists');ylabel('users');zlabel('times listened');

%% Build T matrix: T(artist,tag) = times_tagged(artist, tag);
[T, uniqueTagsIDs]= artistTags(tagged_ARTISTS, listened_ARTISTS);
% figure, mesh(T(1:1000,1:1000)); title('Part of T matrix');
% xlabel('tags');ylabel('artists');zlabel('times tagged');


%% Build correlation matrix
% C = buildCorMat(T);
% figure, imagesc(C(1:1000,1:1000)); title('Part of correlation matrix');
% xlabel('tags');ylabel('tags');colorbar;

%Example: tags 507 and 514 are very correlted 0.9999
% cor_tags = [507,  514];
% disp(['cor( ' TAGS_name{uniqueTagsIDs(cor_tags(1)),2} ' & ' TAGS_name{uniqueTagsIDs(cor_tags(2)),2} ') = ', num2str(C(cor_tags(1),cor_tags(2)))]);

%% Tag clustering
K = 20; % number of tag clusters, which are treated as genres
[Lp, Tp, prunedTagsIDs]= prepocessForClustering(L_, T, 5, 50);
[Lf, G, Tp, groups, tag_groups, popularity] = clusterTags(Lp, Tp, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs);


figure('Position', [100, 100, 648, 309]), hold on, grid on;
categoryPrior = sum(ceil(G))/ sum(sum(ceil(G)));
bar(categoryPrior);
axis([1,K, 0, max(categoryPrior) + 0.02])
xlabel('$c$','interpreter', 'latex');
ylabel('$p(c)$','interpreter', 'latex');
%% Build adjacency matrix and visualize clustered tags using the adjacency matrix 
A = buildCooccurrenceMatrix(Tp);
[H, colors] = visTagGraph(A, groups, popularity, uniqueTagsIDs, prunedTagsIDs, TAGS_name);
axis off



%% Clustering via Self Organising Map (SOM)
% net = selforgmap([4,6]);
% net = configure(net,Tp);
% net.trainParam.epochs = 10000;
% net = train(net,Tp);
% plotsompos(net,Tp)


% L = Lf;                  % avgPrediction2
% L = round(log2(Lf + 1)); % avgPrediction3
% L = round(log10(Lf + 1));% avgPrediction4
% L = double(Lf ~= 0);     % avgPrediction








%% Predicting clustered categories

% estUserPreferencesFn = @estimate_user_probability; %estimate_prior_probability;
% estLiklihoodFn = @estimate_multinomial_item_likelihood;
% estPosteriorProbabilityFn = @estimate_posterior_probability;

estUserPreferencesFn = @buildUserPrefenceModel; % slightly different from @estimate_user_probability
estLiklihoodFn = @estimateCondititonalBernoulli; %; estimateCondititonalMultinomial % estimateCondititonalBernoulli
estPosteriorProbabilityFn = @estimatePosteriorProbability;

testingPortion = [0.01, 0.05, 0.1:0.1:0.8];

Ntrials = 100;
Nclustering = 20;
avgPrediction1Ber  = cell(Nclustering, 1);
avgPrediction2Ber  = cell(Nclustering, 1);
stdPrediction1Ber  = cell(Nclustering, 1);
stdPrediction2Ber  = cell(Nclustering, 1);
avgPrediction1MN1 = cell(Nclustering, 1);
avgPrediction2MN1 = cell(Nclustering, 1);
stdPrediction1MN1 = cell(Nclustering, 1);
stdPrediction2MN1 = cell(Nclustering, 1);
avgPrediction1MN2 = cell(Nclustering, 1);
avgPrediction2MN2 = cell(Nclustering, 1);
stdPrediction1MN2 = cell(Nclustering, 1);
stdPrediction2MN2 = cell(Nclustering, 1);
avgPrediction1MN3 = cell(Nclustering, 1);
avgPrediction2MN3 = cell(Nclustering, 1);
stdPrediction1MN3 = cell(Nclustering, 1);
stdPrediction2MN3 = cell(Nclustering, 1);
avgPrediction1MN4 = cell(Nclustering, 1);
avgPrediction2MN4 = cell(Nclustering, 1);
stdPrediction1MN4 = cell(Nclustering, 1);
stdPrediction2MN4 = cell(Nclustering, 1);
 
for k = 1:Nclustering
k
    [L, pG, G, Tp, groups, tag_groups, popularity] = clusterTags(Lp, Tp, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs);
    tag_groups_all{k} = tag_groups;
    groups_all{k} = groups;
    % Bernoulli
    [avgPrediction1Ber{k}, stdPrediction1Ber{k},...
    avgPrediction2Ber{k}, stdPrediction2Ber{k}]...
    = estimateBayesianTagClusterPrediction(L, pG, G, Ntrials, testingPortion, estUserPreferencesFn, @estimateCondititonalBernoulli, estPosteriorProbabilityFn);
    % Multinomial
    [avgPrediction1MN1{k}, stdPrediction1MN1{k},...
    avgPrediction2MN1{k}, stdPrediction2MN1{k}]...
    = estimateBayesianTagClusterPrediction(L, pG,  G, Ntrials, testingPortion, estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
    % round(log2(Lf + 1))
    [avgPrediction1MN2{k}, stdPrediction1MN2{k},...
    avgPrediction2MN2{k}, stdPrediction2MN2{k}]...
    = estimateBayesianTagClusterPrediction(round(log2(L + 1)), pG,  G, Ntrials, testingPortion,estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
    % round(log10(Lf + 1))
    [avgPrediction1MN3{k}, stdPrediction1MN3{k},...
    avgPrediction2MN3{k}, stdPrediction2MN3{k}]...
    = estimateBayesianTagClusterPrediction(round(log10(L + 1)), pG,  G, Ntrials, testingPortion,estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
    % double(Lf ~= 0)
    [avgPrediction1MN4{k}, stdPrediction1MN4{k},...
    avgPrediction2MN4{k}, stdPrediction2MN4{k}]...
    = estimateBayesianTagClusterPrediction(double(L ~= 0), pG,  G, Ntrials, testingPortion,estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
end


% visualizeCategoryPredictionRates(avgPrediction1(:, 1), stdPrediction1(:, 1), testingPortion, {'MN: 1 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
% visualizeCategoryPredictionRates(avgPredictionSim1(:, 1), stdPredictionSim1(:, 1), testingPortion, {'MN: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
% visualizeCategoryPredictionRates(avgPrediction1(:, 2), stdPrediction1(:, 2), testingPortion, {'MN: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
% visualizeCategoryPredictionRates(avgPredictionSim1(:, 2), stdPredictionSim1(:, 2), testingPortion, {'MN: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
avgPrediction1K20 = zeros(length(testingPortion), 19);
stdPrediction1K20 = zeros(length(testingPortion), 19);
avgPrediction2K20 = zeros(length(testingPortion), 19);
stdPrediction2K20 = zeros(length(testingPortion), 19);
avgPrediction3K20 = zeros(length(testingPortion), 19);
stdPrediction3K20 = zeros(length(testingPortion), 19);
avgPrediction4K20 = zeros(length(testingPortion), 19);
stdPrediction4K20 = zeros(length(testingPortion), 19);
avgPredictionBerK20 = zeros(length(testingPortion), 19);
stdPredictionBerK20 = zeros(length(testingPortion), 19);

avgPredictionSim1K20 = zeros(length(testingPortion), 19);
stdPredictionSim1K20 = zeros(length(testingPortion), 19);
avgPredictionSim2K20 = zeros(length(testingPortion), 19);
stdPredictionSim2K20 = zeros(length(testingPortion), 19);
avgPredictionSim3K20 = zeros(length(testingPortion), 19);
stdPredictionSim3K20 = zeros(length(testingPortion), 19);
avgPredictionSim4K20 = zeros(length(testingPortion), 19);
stdPredictionSim4K20 = zeros(length(testingPortion), 19);
avgPredictionSimBerK20 = zeros(length(testingPortion), 19);
stdPredictionSimBerK20 = zeros(length(testingPortion), 19);

for k = 1:Nclustering
    rowsInds = 1:size(avgPrediction1MN1{k},1);
    colsInds = 1:size(avgPrediction1MN1{k},2);
    avgPrediction1K20(rowsInds, colsInds) =... 
    avgPrediction1K20(rowsInds, colsInds) +...
    avgPrediction1MN1{k};
    stdPrediction1K20(rowsInds, colsInds) =...
    stdPrediction1K20(rowsInds, colsInds) +...
    stdPrediction1MN1{k};

    rowsInds = 1:size(avgPrediction1MN2{k},1);
    colsInds = 1: size(avgPrediction1MN2{k},2);
    avgPrediction2K20(rowsInds, colsInds) =... 
    avgPrediction2K20(rowsInds, colsInds) +...
    avgPrediction1MN2{k};
    stdPrediction2K20(rowsInds, colsInds) =...
    stdPrediction2K20(rowsInds, colsInds) +...
    stdPrediction1MN2{k};


    rowsInds = 1:size(avgPrediction1MN3{k},1);
    colsInds = 1: size(avgPrediction1MN3{k},2);
    avgPrediction3K20(rowsInds, colsInds) =... 
    avgPrediction3K20(rowsInds, colsInds) +...
    avgPrediction1MN3{k};
    stdPrediction3K20(rowsInds, colsInds) =...
    stdPrediction3K20(rowsInds, colsInds) +...
    stdPrediction1MN3{k};


    rowsInds = 1:size(avgPrediction1MN4{k},1);
    colsInds = 1: size(avgPrediction1MN4{k},2);
    avgPrediction4K20(rowsInds, colsInds) =... 
    avgPrediction4K20(rowsInds, colsInds) +...
    avgPrediction1MN4{k};
    stdPrediction4K20(rowsInds, colsInds) =...
    stdPrediction4K20(rowsInds, colsInds) +...
    stdPrediction1MN4{k};

    rowsInds = 1:size(avgPrediction1Ber{k},1);
    colsInds = 1: size(avgPrediction1Ber{k},2);
    avgPredictionBerK20(rowsInds, colsInds) =... 
    avgPredictionBerK20(rowsInds, colsInds) +...
    avgPrediction1Ber{k};
    stdPredictionBerK20(rowsInds, colsInds) =...
    stdPredictionBerK20(rowsInds, colsInds) +...
    stdPrediction1Ber{k};





    rowsInds = 1:size(avgPrediction2MN1{k},1);
    colsInds = 1: size(avgPrediction2MN1{k},2);
    avgPredictionSim1K20(rowsInds, colsInds) =... 
    avgPredictionSim1K20(rowsInds, colsInds) +...
    avgPrediction2MN1{k};
    stdPredictionSim1K20(rowsInds, colsInds) =...
    stdPredictionSim1K20(rowsInds, colsInds) +...
    stdPrediction2MN1{k};

    rowsInds = 1:size(avgPrediction2MN2{k},1);
    colsInds = 1: size(avgPrediction2MN2{k},2);
    avgPredictionSim2K20(rowsInds, colsInds) =... 
    avgPredictionSim2K20(rowsInds, colsInds) +...
    avgPrediction2MN2{k};
    stdPredictionSim2K20(rowsInds, colsInds) =...
    stdPredictionSim2K20(rowsInds, colsInds) +...
    stdPrediction2MN2{k};


    rowsInds = 1:size(avgPrediction2MN3{k},1);
    colsInds = 1: size(avgPrediction2MN3{k},2);
    avgPredictionSim3K20(rowsInds, colsInds) =... 
    avgPredictionSim3K20(rowsInds, colsInds) +...
    avgPrediction2MN3{k};
    stdPredictionSim3K20(rowsInds, colsInds) =...
    stdPredictionSim3K20(rowsInds, colsInds) +...
    stdPrediction2MN3{k};


    rowsInds = 1:size(avgPrediction2MN4{k},1);
    colsInds = 1: size(avgPrediction2MN4{k},2);
    avgPredictionSim4K20(rowsInds, colsInds) =... 
    avgPredictionSim4K20(rowsInds, colsInds) +...
    avgPrediction2MN4{k};
    stdPredictionSim4K20(rowsInds, colsInds) =...
    stdPredictionSim4K20(rowsInds, colsInds) +...
    stdPrediction2MN4{k};

    rowsInds = 1:size(avgPrediction2Ber{k},1);
    colsInds = 1: size(avgPrediction2Ber{k},2);
    avgPredictionSimBerK20(rowsInds, colsInds) =... 
    avgPredictionSimBerK20(rowsInds, colsInds) +...
    avgPrediction2Ber{k};
    stdPredictionSimBerK20(rowsInds, colsInds) =...
    stdPredictionSimBerK20(rowsInds, colsInds) +...
    stdPrediction2Ber{k};

end
avgPrediction1K20 = avgPrediction1K20 / Nclustering;
stdPrediction1K20 = stdPrediction1K20 / Nclustering;
avgPrediction2K20 = avgPrediction2K20 / Nclustering;
stdPrediction2K20 = stdPrediction2K20 / Nclustering;
avgPrediction3K20 = avgPrediction3K20 / Nclustering;
stdPrediction3K20 = stdPrediction3K20 / Nclustering;
avgPrediction4K20 = avgPrediction4K20 / Nclustering;
stdPrediction4K20 = stdPrediction4K20 / Nclustering;
avgPredictionBerK20 = avgPredictionBerK20 / Nclustering;
stdPredictionBerK20 = stdPredictionBerK20 / Nclustering;

avgPredictionSim1K20 = avgPredictionSim1K20 / Nclustering;
stdPredictionSim1K20 = stdPredictionSim1K20 / Nclustering;
avgPredictionSim2K20 = avgPredictionSim2K20 / Nclustering;
stdPredictionSim2K20 = stdPredictionSim2K20 / Nclustering;
avgPredictionSim3K20 = avgPredictionSim3K20 / Nclustering;
stdPredictionSim3K20 = stdPredictionSim3K20 / Nclustering;
avgPredictionSim4K20 = avgPredictionSim4K20 / Nclustering;
stdPredictionSim4K20 = stdPredictionSim4K20 / Nclustering;
avgPredictionSimBerK20 = avgPredictionSimBerK20 / Nclustering;
stdPredictionSimBerK20 = stdPredictionSimBerK20 / Nclustering;

visualizeCategoryPredictionRates(avgPrediction1K20(:, 1), stdPrediction1K20(:, 1), testingPortion, {'MN: 1 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction2K20(:, 1), stdPrediction2K20(:, 1), testingPortion, {'MN log2: 1 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction3K20(:, 1), stdPrediction3K20(:, 1), testingPortion, {'MN log10: 1 category'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction4K20(:, 1), stdPrediction4K20(:, 1), testingPortion, {'Categorical : 1 category'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionBerK20(:, 1), stdPredictionBerK20(:, 1), testingPortion, {'Ber: 1 category'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPredictionSim1K20(:, 1), stdPredictionSim1K20(:, 1), testingPortion, {'MN: 1 w/ cor.'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim2K20(:, 1), stdPredictionSim2K20(:, 1), testingPortion, {'MN log2: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim3K20(:, 1), stdPredictionSim3K20(:, 1), testingPortion, {'MN log10: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim4K20(:, 1), stdPredictionSim4K20(:, 1), testingPortion, {'Categorical : 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSimBerK20(:, 1), stdPredictionSimBerK20(:, 1), testingPortion, {'Ber: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPrediction1K20(:, 2), stdPrediction1K20(:, 2), testingPortion, {'MN: 2 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction2K20(:, 2), stdPrediction2K20(:, 2), testingPortion, {'MN log2: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction3K20(:, 2), stdPrediction3K20(:, 2), testingPortion, {'MN log10: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction4K20(:, 2), stdPrediction4K20(:, 2), testingPortion, {'Categorical : 2 category'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionBerK20(:, 2), stdPredictionBerK20(:, 2), testingPortion, {'Ber: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPredictionSim1K20(:, 2), stdPredictionSim1K20(:, 2), testingPortion, {'MN: 2 w/ cor.'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim2K20(:, 2), stdPredictionSim2K20(:, 2), testingPortion, {'MN log2: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim3K20(:, 2), stdPredictionSim3K20(:, 2), testingPortion, {'MN log10: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim4K20(:, 2), stdPredictionSim4K20(:, 2), testingPortion, {'Categorical : 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSimBerK20(:, 2), stdPredictionSimBerK20(:, 2), testingPortion, {'Ber: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPrediction1K20(:, 3), stdPrediction1K20(:, 3), testingPortion, {'MN: 3 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction2K20(:, 3), stdPrediction2K20(:, 3), testingPortion, {'MN log2: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction3K20(:, 3), stdPrediction3K20(:, 3), testingPortion, {'MN log10: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction4K20(:, 3), stdPrediction4K20(:, 3), testingPortion, {'Categorical: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionBerK20(:, 3), stdPredictionBerK20(:, 3), testingPortion, {'Ber: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));



visualizeCategoryPredictionRates(avgPredictionSim1K20(:, 3), stdPredictionSim1K20(:, 3), testingPortion, {'MN: 3 w/ cor.'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim2K20(:, 3), stdPredictionSim2K20(:, 3), testingPortion, {'MN log2: 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim3K20(:, 3), stdPredictionSim3K20(:, 3), testingPortion, {'MN log10: 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim4K20(:, 3), stdPredictionSim4K20(:, 3), testingPortion, {'Categorical : 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSimBerK20(:, 3), stdPredictionSimBerK20(:, 3), testingPortion, {'Ber: 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));




