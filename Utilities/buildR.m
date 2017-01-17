function [R, item_set_from_ratings] = buildR(RaitingsData)
    R(length(unique(RaitingsData(:,1))), length(unique(RaitingsData(:,2)))) = uint8(0);
    item_set_from_ratings = unique(RaitingsData(:,2));
    l = length(unique(RaitingsData(:,1)));
    for u = 1:l %u is for users
       user_u_idx = find(RaitingsData(:,1) == u);
       items_by_u = RaitingsData(user_u_idx,2);
       clear items_by_u_nogaps;
       for i = 1:length(items_by_u)
            items_by_u_nogaps(i) = find(item_set_from_ratings == items_by_u(i));
       end
       ratings_by_i = uint8(2*RaitingsData(user_u_idx,3) - 1);
       R(u, items_by_u_nogaps) = ratings_by_i;
       u/l
    end
end