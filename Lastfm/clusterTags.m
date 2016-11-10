function [Lf, G, Tp, groups, tagGroups, popularity] = clusterTags(L, T, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs)
    uniqueTagsIDs = unique(tagged_ARTISTS(:,3));

    opts = statset('Display','iter','UseParallel', true, 'MaxIter', 10000);

    [idxbest, Cbest, sumDbest, Dbest] = kmeans(T', K,'Distance','correlation', 'Start', 'cluster','EmptyAction', 'drop', 'Replicates', 10);
    
    for i = 1:K
        groups{i} = find(idxbest == i);
        count = 1;
        for j = 1:length(TAGS_name)
            tag_id = find(TAGS_name{j,1} == uniqueTagsIDs(prunedTagsIDs(groups{i})));
            if(~isempty(tag_id))
                tagGroups{i}{count} = TAGS_name{j,2};
                count = count + 1;
            end
        end
    end
    popularity = sum(T);
    
    % Build genre matrix G based on the clustered T
    Gtemp = zeros(size(T,1), K);
    for i = 1:size(T,1)
        Gtemp(i,:) = histcounts(idxbest(T(i,:) ~= 0),'BinLimits',[1,K]', 'Normalization', 'probability');
    end
    nonnan_id = find(~isnan(sum(Gtemp,2)));
    G = Gtemp(nonnan_id, :);
    Lf = L(:, nonnan_id);
    Tp = T(nonnan_id, :);
end