function [leastActiveUsersInds, ratingPortion] = leastActiveUsers(numUsers, R)
%least active users
    for k = 1:size(R,1)
        expertUsersRating(k) = sum(R(k, find(R(k, :) ~= 0)));
    end
    [s,inds] = sort(expertUsersRating, 'ascend');
    totRatings = sum(sum(R ~= 0));
    leastActiveUsersInds = inds(1:numUsers);
    ratingPortion = sum(sum(R(leastActiveUsersInds, :) ~= 0))/totRatings; % precentage of all given ratings

end