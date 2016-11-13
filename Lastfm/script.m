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
K = 10; % number of tag clusters, which are treated as genres
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

testingPortion = [0.05, 0.1:0.1:0.8];

Ntrials = 100;
Nclustering = 50;
avgPredictionBer  = cell(Nclustering);
avgPredictionSimBer  = cell(Nclustering);
stdPredictionBer  = cell(Nclustering);
stdPredictionSimBer  = cell(Nclustering);
avgPrediction1 = cell(Nclustering);
avgPredictionSim1 = cell(Nclustering);
stdPrediction1 = cell(Nclustering);
stdPredictionSim1 = cell(Nclustering);
avgPrediction2 = cell(Nclustering);
avgPredictionSim2 = cell(Nclustering);
stdPrediction2 = cell(Nclustering);
stdPredictionSim2 = cell(Nclustering);
avgPrediction3 = cell(Nclustering);
avgPredictionSim3 = cell(Nclustering);
stdPrediction3 = cell(Nclustering);
stdPredictionSim3 = cell(Nclustering);
avgPrediction4 = cell(Nclustering);
avgPredictionSim4 = cell(Nclustering);
stdPrediction4 = cell(Nclustering);
stdPredictionSim4 = cell(Nclustering);
 
for k = 1:Nclustering
k
    [L, G, Tp, groups, tag_groups, popularity] = clusterTags(Lp, Tp, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs);
    tag_groups_all{k} = tag_groups;
    groups_all{k} = groups;
    % Bernoulli
    [avgPredictionBer{k}, stdPredictionBer{k},...
    avgPredictionSimBer{k}, stdPredictionSimBer{k}]...
    = estimateBayesianTagClusterPrediction(L, G, Ntrials, testingPortion, estUserPreferencesFn, @estimateCondititonalBernoulli, estPosteriorProbabilityFn);
    % Multinomial
    [avgPrediction1{k}, stdPrediction1{k},...
    avgPredictionSim1{k}, stdPredictionSim1{k}]...
    = estimateBayesianTagClusterPrediction(L, G, Ntrials, testingPortion, estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
    % round(log2(Lf + 1))
    [avgPrediction2{k}, stdPrediction2{k},...
    avgPredictionSim2{k}, stdPredictionSim2{k}]...
    = estimateBayesianTagClusterPrediction(round(log2(L + 1)), G, Ntrials, testingPortion,estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
    % round(log10(Lf + 1))
    [avgPrediction3{k}, stdPrediction3{k},...
    avgPredictionSim3{k}, stdPredictionSim3{k}]...
    = estimateBayesianTagClusterPrediction(round(log10(L + 1)), G, Ntrials, testingPortion,estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
    % double(Lf ~= 0)
    [avgPrediction4{k}, stdPrediction4{k},...
    avgPredictionSim4{k}, stdPredictionSim4{k}]...
    = estimateBayesianTagClusterPrediction(double(L ~= 0), G, Ntrials, testingPortion,estUserPreferencesFn, @estimateCondititonalMultinomial, estPosteriorProbabilityFn);
end


% visualizeCategoryPredictionRates(avgPrediction1(:, 1), stdPrediction1(:, 1), testingPortion, {'MN: 1 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
% visualizeCategoryPredictionRates(avgPredictionSim1(:, 1), stdPredictionSim1(:, 1), testingPortion, {'MN: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
% visualizeCategoryPredictionRates(avgPrediction1(:, 2), stdPrediction1(:, 2), testingPortion, {'MN: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
% visualizeCategoryPredictionRates(avgPredictionSim1(:, 2), stdPredictionSim1(:, 2), testingPortion, {'MN: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));


visualizeCategoryPredictionRates(avgPrediction1(:, 1), stdPrediction1(:, 1), testingPortion, {'MN: 1 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction2(:, 1), stdPrediction2(:, 1), testingPortion, {'MN log2: 1 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction3(:, 1), stdPrediction3(:, 1), testingPortion, {'MN log10: 1 category'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction4(:, 1), stdPrediction4(:, 1), testingPortion, {'Categorical : 1 category'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionBer(:, 1), stdPredictionBer(:, 1), testingPortion, {'Ber: 1 category'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPredictionSim1(:, 1), stdPredictionSim1(:, 1), testingPortion, {'MN: 1 w/ cor.'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim2(:, 1), stdPredictionSim2(:, 1), testingPortion, {'MN log2: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim3(:, 1), stdPredictionSim3(:, 1), testingPortion, {'MN log10: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim4(:, 1), stdPredictionSim4(:, 1), testingPortion, {'Categorical : 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSimBer(:, 1), stdPredictionSimBer(:, 1), testingPortion, {'Ber: 1 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPrediction1(:, 2), stdPrediction1(:, 2), testingPortion, {'MN: 2 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction2(:, 2), stdPrediction2(:, 2), testingPortion, {'MN log2: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction3(:, 2), stdPrediction3(:, 2), testingPortion, {'MN log10: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction4(:, 2), stdPrediction4(:, 2), testingPortion, {'Categorical : 2 category'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionBer(:, 2), stdPredictionBer(:, 2), testingPortion, {'Ber: 2 category'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPredictionSim1(:, 2), stdPredictionSim1(:, 2), testingPortion, {'MN: 2 w/ cor.'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim2(:, 2), stdPredictionSim2(:, 2), testingPortion, {'MN log2: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim3(:, 2), stdPredictionSim3(:, 2), testingPortion, {'MN log10: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim4(:, 2), stdPredictionSim4(:, 2), testingPortion, {'Categorical : 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSimBer(:, 2), stdPredictionSimBer(:, 2), testingPortion, {'Ber: 2 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));


visualizeCategoryPredictionRates(avgPrediction1(:, 3), stdPrediction1(:, 3), testingPortion, {'MN: 3 category'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction2(:, 3), stdPrediction2(:, 3), testingPortion, {'MN log2: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction3(:, 3), stdPrediction3(:, 3), testingPortion, {'MN log10: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPrediction4(:, 3), stdPrediction4(:, 3), testingPortion, {'Categorical: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionBer(:, 3), stdPredictionBer(:, 3), testingPortion, {'Ber: 3 category'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));



visualizeCategoryPredictionRates(avgPredictionSim1(:, 3), stdPredictionSim1(:, 3), testingPortion, {'MN: 3 w/ cor.'}, true, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim2(:, 3), stdPredictionSim2(:, 3), testingPortion, {'MN log2: 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '--', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim3(:, 3), stdPredictionSim3(:, 3), testingPortion, {'MN log10: 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-.', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSim4(:, 3), stdPredictionSim4(:, 3), testingPortion, {'Categorical : 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', ':', 'color', [0, 0.4470, 0.7410]));
visualizeCategoryPredictionRates(avgPredictionSimBer(:, 3), stdPredictionSimBer(:, 3), testingPortion, {'Ber: 3 w/ cor.'}, false, struct('LineWidth', 2, 'LineStyle', '-', 'color', [0.8500, 0.3250, 0.0980]));





