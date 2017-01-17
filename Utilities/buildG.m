function G = buildG(movies, movieGenres, R, item_set_from_ratings)
    for i = 1:size(movies,1)
        moviesID(i) = movies{i,1};
    end

    G = zeros(size(R, 2), length(movieGenres));
    for i = 1:length(moviesID)
        i
        ind = find(moviesID(i) == item_set_from_ratings);
        if(~isempty(ind))
            for c = 1:length(movieGenres)
                for j = 2:size(movies,2)
                    if(strcmp(movies{i,j}, movieGenres{c}))
                        G(ind, c) = 1;
                    end
                end
            end
        end
    end
end
