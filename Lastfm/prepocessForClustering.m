function [Lp, Tp, prunedTagsIDs]= prepocessForClustering(L, T, minTotalAssignedTagsPerArtist, minUsedTagsAtAll, uniqueArtistsIDs, tagged_ARTISTS)
    % prepocessing :
    % (a) remove rare tags
    prunedTagsIDs = find(sum(T) >= minUsedTagsAtAll );
    % (b) remove unpopular (assigned a few tags) artsits 
    [hist_tags_artists]  = histcounts(tagged_ARTISTS(:,2),'BinMethod', 'integers');
    prunedArtistsIDs = find(hist_tags_artists > minTotalAssignedTagsPerArtist);
    prunedAndUnqiueArtistIDs = intersect(prunedArtistsIDs, uniqueArtistsIDs);
    counter = 1;
    for i = 1:length(prunedAndUnqiueArtistIDs)
        pos = find(uniqueArtistsIDs == prunedAndUnqiueArtistIDs(i));
        if(~isempty(pos))
            prunedArtistsIDs_(counter) = pos; % different from prunedArtistsIDs
            counter = counter + 1;
        end
    end

    Tp = T(prunedArtistsIDs_, prunedTagsIDs);
    Lp = L(:,prunedArtistsIDs_);
end