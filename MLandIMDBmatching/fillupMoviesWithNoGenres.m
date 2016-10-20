function G = fillupMoviesWithNoGenres(G, linksMLLatest, genresList)
    options = weboptions('Timeout', 100);
    indsNoGenres = find(sum(G') == 0);
    
    for k = 1:length(indsNoGenres)
        k
        data = webread(['http://imdb.wemakesites.net/api/tt',... 
                    sprintf('%07d',linksMLLatest(indsNoGenres(k), 2))], options);
        jsonobj = loadjson(data);
        for i = 1:length(jsonobj.data.genres)
            for l = 1:length(genresList)
                if(strcmp(lower(jsonobj.data.genres{i}), lower(genresList{l})))
                    G(indsNoGenres(k), l) = 1;
                end
            end
        end
    end
end