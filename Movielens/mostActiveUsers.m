function [mostActiveUsersInds, ratingPortion] = mostActiveUsers(numUsers, R)
%most active users
    for k = 1:size(R,1)
        expertUsersRating(k) = sum(R(k, find(R(k, :) ~= 0)));
    end
    [~, inds] = sort(expertUsersRating, 'descend');
    totRatings = sum(sum(R ~= 0));
    mostActiveUsersInds = inds(1:numUsers);
    ratingPortion = sum(sum(R(mostActiveUsersInds, :) ~= 0))/totRatings; % precentage of all given ratings
end