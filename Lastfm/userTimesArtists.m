function [L, uniqueArtistsIDs] = userTimesArtists(listened_ARTISTS)
    %% Build L matrix: L(user, artist) =  times_listen(user,artist);
    %Possible modification: R(user, artist) = times_listen(user,artist) > min_times ? 1 : 0;
    uniqueUsersIDs = unique(listened_ARTISTS(:,1));
    uniqueArtistsIDs = unique(listened_ARTISTS(:,2));
    Nusers   =  length(uniqueUsersIDs);
    Nartists =  length(uniqueArtistsIDs);    
    L = zeros(Nusers, Nartists);
     
    for i = 1:Nusers
        selected_user_ind = listened_ARTISTS(:,1) == uniqueUsersIDs(i);
        listened_artists = listened_ARTISTS(selected_user_ind,2);
        for j = 1:length(listened_artists)
            selected_artist = uniqueArtistsIDs == listened_artists(j);
            L(i, selected_artist) = listened_ARTISTS(listened_artists(j),3);
        end
    end
end
