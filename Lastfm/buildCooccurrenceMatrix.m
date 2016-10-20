function A = buildCooccurrenceMatrix(T)
    %% Build tag co-occurance matrix (adjacency matrix for graph representation)
    A = zeros(size(T,2), size(T,2));
    for i = 1:size(T,2)
        artists_tagged = find(T(:,i) ~= 0);
        for j = 1:length(artists_tagged)
            given_tags = find(T(artists_tagged(j),:));
            for k = 1:length(given_tags)
                A(i, given_tags(k)) = A(i, given_tags(k)) + min(T(artists_tagged(j),i), T(artists_tagged(j),given_tags(k)));
            end
        end
    end
    A(logical(eye(size(A)))) = 0;
    A = triu(A);
end