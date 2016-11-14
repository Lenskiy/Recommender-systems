function G = reduceGtoNcategories(pG, toNcategories, centroids)
% sum(sum(G > 0.3, 2) > 0)
% G_ = zeros(size(G, 1), size(G, 2));
% G_(find(G > 0.33)) = 1;
%  h = histcounts(sum(G_,2), 'BinMethod', 'integers');
% figure, stem(h)

    G = pG;
    distVec = pdist(centroids,'correlation');
    distMat = squareform(distVec,'tomatrix');
    distMat(logical(eye(size(distMat)))) = inf;
    for k = 1:size(G,1)
       [mvals, minds] = maxN(G(k, :), toNcategories);
       nonZeroTopInds = minds(find(mvals > 0));
       nonZeroInds = find(G(k, :) ~= 0);
       toMerge = setdiff(nonZeroInds, nonZeroTopInds);
       for l = 1:numel(toMerge)
           [mval, mind]= min(distMat(toMerge(l), nonZeroTopInds));
           G(k, nonZeroTopInds(mind)) = G(k, nonZeroTopInds(mind)) + G(k, toMerge(l));
           G(k, toMerge(l)) = 0;
       end
    end
end