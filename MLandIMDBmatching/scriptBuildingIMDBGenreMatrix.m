addpath('../Utilities');

genresList = {'Action', 'Adventure', 'Animation',... 
    'Children''s', 'Comedy', 'Crime', 'Documentary', 'Drama',...
    'Fantasy', 'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',...
    'Sci-Fi', 'Thriller', 'War', 'Western', 'Family', 'Biography', 'History', 'Music', 'Sport', 'Short', 'News'};

% Build R and G from movielens
[R, item_set_from_ratings] = buildR(raitings1M);
G = buildG(movies1M, genresList, R, item_set_from_ratings);


% Build G by matching movie titles with IMDB
[G_imdb1M, toCheck] = buildIMDBGenreMatrix(movies1M, item_set_from_ratings, titlesMLLatest, idMLLatest, linksMLLatest, genresList);

% G = G(:,2:19); % if unknown genre has not been removed
% If two or more movies in IMDB matched a movie in MovieLens, choose the
% one that is close in terms of genres and save the resultant matrix to
% G_ext
G_ext = matchMovieToClosest(G_imdb1M, G);
zeroInds = find(sum(G_ext, 2) == 0);
% G_toCheck is manually chacked zeroInds
% Combine G_ext and G_toCheck
G_target = G_ext;
for  k = 1:length(zeroInds)
    G_target(zeroInds(k), :) = G_toCheck(zeroInds(k),:);
end
        
G_ = G_target(:, 1:18);
G_(:,4) = G_target(:, 19);
%G_ = G_imdb100k(:, 1:18, :);

% Compare G_ with the predicted G
figure, hold on 
plot(sum(G));
plot(sum(G_));
legend({'Movielens', 'IMDB'});


% 
% checkMovieIDs = unique(toCheck);
% for k = 1:length(checkMovieIDs)
%     k/length(checkMovieIDs)
%     genres = getGenersFromIMDBByIndex(checkMovieIDs(k), titles100k, titlesMLLatest, idMLLatest, linksMLLatest, genresList);
%     genres(:, 4) = genres(:, 19);
%     genres = genres(:,1:18);
%     match = [];
%     for j = 1:size(genres, 1)
%         match(j) = sum(genres(j,:) .* G(checkMovieIDs(k), :));
%     end
%     [~, mind]= max(match);
%     G_(checkMovieIDs(k), :) = genres(mind,:);
% end
% 
% noGenresMoviesIND = find(sum(G_') == 0);

