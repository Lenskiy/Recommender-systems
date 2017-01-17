movie_genre = {'Action', 'Adventure', 'Animation',... 
    ['Children' char(39) 's'], 'Comedy', 'Crime', 'Documentary', 'Drama',...
    'Fantasy', 'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',...
    'Sci-Fi', 'Thriller', 'War', 'Western'};

addpath('../Utilities/');
addpath('../fastBayes/');
addpath('../Data/');
DB = '100k';

switch(DB)
    case '100k'
        load('R_G.mat');
        R(:, find(G(:,1) == 1)) = []; % Remove genre 1 - uknown 
        G(find(G(:,1) == 1), :) = []; % Remove genre 1 - uknown
        G(:, 1) = [];
        G_ = bsxfun(@rdivide,G, sum(G')');%convert to probabilities, each row sums up to one
        G_(isnan(G_)) = 0; 
    case '1M'
        load('R_G_1M.mat');
        G_ = bsxfun(@rdivide,G, sum(G')');
        G_(isnan(G_)) = 0;
    case '20M'
        load('R_G_20M.mat'); 
        G_ = bsxfun(@rdivide,G, sum(G')');
        G_(isnan(G_)) = 0;
end

%% 
Nusers = size(R,1);     %number of users
Nitems = size(R,2);     %number of items
Ncategories = size(G,2);    %number of genres
Nrates = max(max(R));   %number of rates

%% Plot figures for the paper     
%logPr_ItemInCategory = estimateCondititonalBernoulli(R, Pr_UratedC)
for r = 1:Nrates
    [prior, pUgivenC(:,:,r)] = buildUserPrefenceModel(R == r, G);
    log_pic(:,:,r) = estimate_bernoulli_item_likelihood(R == r, pUgivenC(:,:,r), prior);
    log_posterior(:,:, r) = estimatePosteriorProbability(log_pic(:,:,r), prior);
end
pUandC = bsxfun(@times, pUgivenC, prior);
pU = sum(pUandC,2);
pCgivenU = bsxfun(@rdivide, pUandC(:,:,:), pU(:,1,:));
%% plot user's profile
u = 4;
figure, hold on, plot(pCgivenU(u,:,1)), plot(pCgivenU(u,:,2)), plot(pCgivenU(u,:,3)), plot(pCgivenU(u,:,4)), plot(pCgivenU(u,:,5))
legend('r = 1', 'r = 2', 'r = 3', 'r = 4', 'r = 5');
xticks(1:length(movie_genre))
xticklabels(movie_genre);
ax = gca;
ax.XTickLabelRotation=45;

kl = zeros(Nusers, Nitems);
for j = 1:Nusers       
    Nrated = sum(R(j,:) == r); %The number of movies user has rated
    kl(j,:) = kldivergence(log(pCgivenU(j,:,r)), log_posterior(:,:,r)); % Calcuate the divergance for user j and all movies
    %Recommend the same number of movies as the number user rated as r i.e.Nrated
    [maxValues, maxValueIndices] = maxN(kl(j,:), Nrated); 
    recommended{j} = maxValueIndices;
    success_rate(j) = length(intersect(find(R(j,:) == r), recommended{j}))/Nrated;
end
figure, plot(success_rate)
