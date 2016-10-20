movie_genre = {'Action', 'Adventure', 'Animation',... 
    ['Children' char(39) 's'], 'Comedy', 'Crime', 'Documentary', 'Drama',...
    'Fantasy', 'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',...
    'Sci-Fi', 'Thriller', 'War', 'Western'};

%% Data preparation: replace this section with new data. R is rating and G is category matrix
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

%% Split data into training and testing sets
Nusers = size(R,1);
Nitems = size(R,2);
numRtype = sum((unique(R) ~= 0));
maxNumOfGenPerMovies = max(sum((G~=0)'));

trainingPortion = 0.8;
testingPortion = 0.35;

training_subset_ind = randperm(Nitems, floor(Nitems * trainingPortion)); % select training samples randomly
testing_subset_ind =  setdiff(1:Nitems, training_subset_ind); % choose remaining samples that are not part of training set
%select portion of them
%testing_subset_ind =  testing_subset_ind(randperm(length(testing_subset_ind), floor(Nitems*testingPortion)));
clear R_train R_test
for r = 1:numRtype 
    R_ = zeros(Nusers, Nitems, 'uint8');
    R_(:, :) = (R == r);
    R_train(:, :, r) = R_(:, training_subset_ind);
    R_test(:, :, r) = R_(:, testing_subset_ind);
end
G_train = G(training_subset_ind,:);
G_test = G(testing_subset_ind,:);

r = 3;



%% Estimate prior and likelihoods 
prior_train = estimate_prior_probability(G_train);

% The Posterior and the likelihood 
% $$ p(d|c) = prod[ p(w|c)^{N_{d,w}} ] $$, 
% both depends on p(w|c). The estimation of the conditional probability p(w|c)
% is the learning process and is performed on the training set.
% To estimate pwc = p(w|c) count the number of occurences of the word w in C,
puc_train = estimate_user_probability(R_train(:,:,r), G_train);

% Estimate Likelihood p(d|c)
log_pic = estimate_multinomial_item_likelihood(R_train(:,:,r), puc_train);


%% Apply Bayesian rule to estimate posterior probability of class given a document

log_posterior = estimate_posterior_probability(log_pic, prior_train);
%
% *Classification of the training set*
%
classified = naive_classifer(log_posterior);

performanceRate(log_posterior, G_train)

%% Testing procedure

log_pic_test = estimate_multinomial_item_likelihood(R_test(:,:,r), puc_train);
log_posterior_test = estimate_posterior_probability(log_pic_test, prior_train);
%
% *Classification of the testing set*
%
% Naive Bayes classifier simply assigns the category with the highest probability
classified = naive_classifer(log_posterior_test);

performanceRate(log_posterior_test, G_test)

%% Homework assignment
% (a) Implement the estimate_bernoulli_document_likelihood function, and analog
% of the given estimate_multinomial_document_likelihood function.
% Use multivariate Bernoulli event model. The Bernoulli  model does not take
% into account the number of times the word occurred in the document and
% given as 
% $$ p(d|c) = \Pi_{i=1}^{|words|} h(T(w,t)) \cdot p(w_i|c) + (1 - h(T(w,t)) \cdot (1 - p(w_i|c)) $$
% , where $$ h(x) $$ = {0 if $$ x $$ = 0; 1 if 0 < $$ x $$} .
%
% (b) Compare the prediction rates on the both testing and training sets for the 
% multinomial and multivariate and Benoulli event models.

