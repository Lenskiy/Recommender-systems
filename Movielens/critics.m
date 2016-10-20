function [topCriticsInds, ratingPortion] = critics(numUsers, R)
    %find critics 
    for k = 1:size(R,1)
        stdUsersRating(k) = std(R(k, find(R(k, :) ~= 0)));
    end
    [~,inds] = sort(stdUsersRating, 'descend');
    totRatings = sum(sum(R ~= 0));
    topCriticsInds = inds(1:numUsers);
    ratingPortion = sum(sum(R(topCriticsInds, :) ~= 0))/totRatings % precentage of all given ratings
end