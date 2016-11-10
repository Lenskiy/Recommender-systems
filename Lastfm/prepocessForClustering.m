function [Lp, Tp, prunedTagsIDs]= prepocessForClustering(L, T, minTotalAssignedTagsPerArtist, minUsedTagsAtAll)
    % prepocessing :
    % (a) remove rare tags
    prunedTagsIDs = find(sum(T) >= minUsedTagsAtAll);
    Tp = T(:, prunedTagsIDs);
    % (b) remove unpopular (assigned a few tags) artsits 
    prunedArtistsIDs = find(sum(Tp, 2) >= minTotalAssignedTagsPerArtist);
    Tp = Tp(prunedArtistsIDs, :);
    Lp = L(:,prunedArtistsIDs);
%     [hist_tags_artists]  = histcounts(tagged_ARTISTS(:,3),'BinMethod', 'integers');
%     prunedArtistsIDs = find(hist_tags_artists > minTotalAssignedTagsPerArtist);
%     counter = 1;
%     for i = 1:length(prunedArtistsIDs)
%         pos = find(uniqueArtistsIDs == prunedArtistsIDs(i));
%         if(~isempty(pos))
%             prunedArtistsIDs_(counter) = pos; % different from prunedArtistsIDs
%             counter = counter + 1;
%         end
%     end
    
    
    
    
    
end