%% Data structures
%listened_ARTISTS
%userID \t artistID \t weight
%tagged_ARTISTS
%userID \t artistID \t tagID

addpath('../Utilities/');
addpath('../fastBayes/');
load('../Data/lastfm_2k.mat');

%% Build L matrix: L(user, artist) =  times_listen(user,artist);
[L_, uniqueArtistsIDs] = userTimesArtists(listened_ARTISTS);
% figure, mesh(L_(1:1000,1:1000));title('Part of L matrix');
% xlabel('artists');ylabel('users');zlabel('times listened');

%% Build T matrix: T(artist,tag) = times_tagged(artist, tag);
[T, uniqueTagsIDs]= artistTags(tagged_ARTISTS, listened_ARTISTS);
% figure, mesh(T(1:1000,1:1000)); title('Part of T matrix');
% xlabel('tags');ylabel('artists');zlabel('times tagged');

%% Tag clustering
K = 20; % number of tag clusters, which are treated as genres
[Lp, Tp, prunedTagsIDs]= prepocessForClustering(L_, T, 5, 50);
% K-means based clustering
[Lf, G, Tp, groups, tag_groups, popularity] = clusterTags(Lp, Tp, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs);

%% Build adjacency matrix and visualize clustered tags using the adjacency matrix 
A = buildCooccurrenceMatrix(Tp);
[H, colors] = visTagGraph(A, groups, popularity, uniqueTagsIDs, prunedTagsIDs, TAGS_name);
axis off

%% Visualize clustered tags
plotClusteredHistrogram(Tp, groups, tag_groups, popularity, colors);


