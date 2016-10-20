function genres = getGenersFromIMDBByIndex(id, titles, titlesMLLatest, movieIdMLLatest, linksMLLatest, genresList)
    [genres, ~] = buildIMDBGenreMatrix(titles(id), titlesMLLatest, movieIdMLLatest, linksMLLatest, genresList);
    
    genres = squeeze(genres);
    if(size(genres,2) < size(genres,1))
        genres = genres';
    end
end