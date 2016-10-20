function C = buildCorMat(T)
    %% Build correlation matrix
%     [T_cor, ~] = corr(T, 'rows','pairwise');
    numArtists = size(T, 1);
    T_norm = (T - ones(size(T,1),1) * mean(T));
    T_norm = T_norm ./ (ones(size(T,1),1) * std(T));
    T_norm(isnan(T_norm)) = 0;
    C = (T_norm' * T_norm) / numArtists; %replace the metric
    C(logical(eye(size(C)))) = 0;
end