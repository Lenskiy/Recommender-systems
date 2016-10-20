function [T, uniqueTagsIDs] = artistTags(tagged_ARTISTS, listened_ARTISTS)
%% Build T matrix: T(artist,tag) = times_tagged(artist, tag);
    uniqueTagsIDs = unique(tagged_ARTISTS(:,3));
    Ntags    =  length(uniqueTagsIDs);
    uniqueArtistsIDs = unique(listened_ARTISTS(:,2));
    Nartists = length(uniqueArtistsIDs);
    
    T = zeros(Nartists, Ntags);
    for i = 1:Ntags
        selected_artist_ind = tagged_ARTISTS(:,3) == uniqueTagsIDs(i);
        tagged_artists = tagged_ARTISTS(selected_artist_ind,2);
        for j = 1:length(tagged_artists)
            selected_artist = find(uniqueArtistsIDs == tagged_artists(j));
            T(selected_artist, i) = T(selected_artist, i) + 1;
        end    
    end
end