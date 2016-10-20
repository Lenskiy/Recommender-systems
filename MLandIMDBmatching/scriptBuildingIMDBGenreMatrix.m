genresList = {'Action', 'Adventure', 'Animation',... 
    'Children', 'Comedy', 'Crime', 'Documentary', 'Drama',...
    'Fantasy', 'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',...
    'Sci-Fi', 'Thriller', 'War', 'Western', 'Family', 'Biography', 'History', 'Music', 'Sport', 'Short', 'News'};

[G_imdb100k, toCheck] = buildIMDBGenreMatrix(titles100k, titlesMLLatest, idMLLatest, linksMLLatest, genresList);
zeroInds = find(sum(G_imdb100k(:, :, 1)') == 0);

%G = G(:,2:19); % if unknown genre has not been removed
G_ext = matchMovieToClosest(G_imdb100k, G);

G_ = G_imdb100k(:, 1:18, :);

G_ = G_imdb100k(:, 1:18);
G_(:,4) = G_imdb100k(:, 19);

checkMovieIDs = unique(toCheck);
for k = 1:length(checkMovieIDs)
    k/length(checkMovieIDs)
    genres = getGenersFromIMDBByIndex(checkMovieIDs(k), titles100k, titlesMLLatest, idMLLatest, linksMLLatest, genresList);
    genres(:, 4) = genres(:, 19);
    genres = genres(:,1:18);
    match = [];
    for j = 1:size(genres, 1)
        match(j) = sum(genres(j,:) .* G(checkMovieIDs(k), :));
    end
    [~, mind]= max(match);
    G_(checkMovieIDs(k), :) = genres(mind,:);
end

noGenresMoviesIND = find(sum(G_') == 0);

