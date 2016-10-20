function [G, toCheck] = buildIMDBGenreMatrix(titles, titlesMLLatest, movieIdMLLatest, linksMLLatest, genresList)
    apikey = '8be855ec';
    titles = lower(titles);
    titlesMLLatest = lower(titlesMLLatest);
    options = weboptions('Timeout', 100);
    G = zeros(size(titles,1), length(genresList));
    
    toCheck = [];
    for k = 1:length(titles)
        flag = 0; %more than one movie with a similar name;
        [title_only1, year_only1] = parseTitle(titles{k});
        for j = 1:length(titlesMLLatest)
            
            %[k, j]
            [title_only2, year_only2] = parseTitle(titlesMLLatest{j});
            %check if some pair match
            match = 0;
            for l = 1:length(title_only1)
                for m = 1:length(title_only2)
                    if(strcmp(title_only1{l}, title_only2{m}))
                        match = 1;
                    end
                end
            end
            if(match) % compare titles
                % compare years of production if years are given for both movies 
                if(year_only1 ~= 0 && year_only2 ~= 0)
                    if(abs(year_only1 - year_only2) > 1) % if years don't stand for more than a year, accept it
                        continue;
                    end
                end
                
                if(flag) % if set, a movie with the same name has alread matched
                    toCheck = [toCheck, k];  
                end
                flag = flag + 1;
                
                idMLLatest = movieIdMLLatest(j);
                loc = find(linksMLLatest(:,1) == idMLLatest);
                data = webread(['http://imdb.wemakesites.net/api/tt',... 
                    sprintf('%07d',linksMLLatest(loc, 2))], options);
%                 data = webread(['http://img.omdbapi.com/?i=tt',... 
%                     sprintf('%07d',linksMLLatest(loc, 2)), '&apikey=', apikey], options);                

                jsonobj = loadjson(data);
                if(~isempty(jsonobj.data))
                    disp([num2str(k),  titles{k} ,'|', titlesMLLatest{j}, '|' jsonobj.data.genres]);
                    for i = 1:length(jsonobj.data.genres)
                        for l = 1:length(genresList)
                            if(strcmp(lower(jsonobj.data.genres{i}), lower(genresList{l})))
                                G(k, l, flag) = 1;
                            end
                        end
                    end
                else
                    toCheck = [toCheck, k]; % The was not found in IMDB via imdb.wemakesites.net
                end
            end
        end
    end
end