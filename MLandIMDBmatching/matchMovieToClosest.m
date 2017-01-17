function Gp = matchMovieToClosest(G_, G)

    indZeros = find(sum(G_(:,:,2)') ~= 0);
    Gp = G_(:,:,1);
    for k = 1:length(indZeros)
        match = [];
        for j = 1:size(G_,3)
            match(j) = sum(G_(indZeros(k),1:size(G,2),j) .* G(indZeros(k), :));
        end
        [~, mind]= max(match);
        Gp(indZeros(k), :) = G_(indZeros(k),:,mind);        
    end
%     checkMovieIDs = unique(toCheck);
%     for k = 1:length(checkMovieIDs)
%         k/length(checkMovieIDs)
%         genres = getGenersFromIMDBByIndex(checkMovieIDs(k), titlesToMatch, titlesMLLatest, idMLLatest, linksMLLatest, genresList);
% %         genres(:, 4) = genres(:, 19);
% %         genres = genres(:,1:18);
%         match = [];
%         for j = 1:size(genres, 1)
%             match(j) = sum(genres(j,:) .* G(checkMovieIDs(k), :));
%         end
%         [~, mind]= max(match);
%         G(checkMovieIDs(k), :) = genres(mind,:);
%     end
end