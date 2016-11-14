function [Lf, pG, G, Tp, groups, tagGroups, tagsPopularity] = clusterTags(L, T, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs)
    uniqueTagsIDs = unique(tagged_ARTISTS(:,3));
    
    opts = statset('Display','iter','UseParallel', true, 'MaxIter', 10000);

    [idxbest, centroids, sumDbest, Dbest] = kmeans(T', K,'Distance','correlation', 'Start', 'cluster','EmptyAction', 'drop', 'Replicates', 10);

%     for i = 1:K
%         groups{i} = find(idxbest == i);
%         count = 1;
%         for j = 1:length(TAGS_name)
%             tag_id = find(TAGS_name{j,1} == uniqueTagsIDs(prunedTagsIDs(groups{i})));
%             if(~isempty(tag_id))
%                 tagGroups{i}{count} = TAGS_name{j,2};
%                 count = count + 1;
%             end
%         end
%     end

% Build genre matrix G based on the clustered T
%     Gtemp = zeros(size(T,1), K);
%     for i = 1:size(T,1)
%         Gtemp(i,:) = histcounts(idxbest(T(i,:) ~= 0),'BinLimits',[1,K]', 'Normalization', 'probability');
%     end

    pAandT = T/sum(sum(T));
    pAnadC = zeros(size(T,1), K);
    %pC = zeros(K, 1);
    tagsPopularity = sum(T);
    
	for k = 1:K
        groups{k} = find(idxbest == k);
        %pC(k) = sum(tagsPopularity(groups{k}))/sum(tagsPopularity);
        for a = 1:size(T,1)
            pAnadC(a, k) = pAnadC(a, k) +  sum(pAandT(a, groups{k}));
        end
        count = 1;
        for j = 1:length(TAGS_name)
            tag_id = find(TAGS_name{j,1} == uniqueTagsIDs(prunedTagsIDs(groups{k})));
            if(~isempty(tag_id))
                tagGroups{k}{count} = TAGS_name{j,2};
                count = count + 1;
            end
        end        
    end
    
    %pAgivenC = pAnadC ./ pC';
    pA = sum(pAnadC,2);
    pCgivenA = pAnadC ./ pA;
    
    
    nonnan_id = find(~isnan(sum(pCgivenA,2)));
    pG = pCgivenA(nonnan_id, :);
    Lf = L(:, nonnan_id);
    Tp = T(nonnan_id, :);
    G = ceil(reduceGtoNcategories(pG, 3, centroids));
end