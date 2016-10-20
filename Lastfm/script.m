%% Data structures
%listened_ARTISTS
%userID \t artistID \t weight
%tagged_ARTISTS
%userID \t artistID \t tagID

addpath('../Utilities/');
load('../Data/lastfm_2k.mat');

%% Build the tag histogram  and find the most popular tags
[hist_tags]  = histcounts(tagged_ARTISTS(:,3),'BinMethod', 'integers');
figure, bar(hist_tags(unique(tagged_ARTISTS(:,3)))); xlabel('tag id'); ylabel('times occured');
[~, popular_tags_ids] = maxN(hist_tags,50); % the most popular tags;
TAGS_name{popular_tags_ids,2}


%% Build L matrix: L(user, artist) =  times_listen(user,artist);
[L_, uniqueArtistsIDs] = userTimesArtists(listened_ARTISTS);
figure, mesh(L_(1:1000,1:1000));title('Part of L matrix');
xlabel('artists');ylabel('users');zlabel('times listened');

%% Build T matrix: T(artist,tag) = times_tagged(artist, tag);
[T, uniqueTagsIDs]= artistTags(tagged_ARTISTS, listened_ARTISTS);
figure, mesh(T(1:1000,1:1000)); title('Part of T matrix');
xlabel('tags');ylabel('artists');zlabel('times tagged');


%% Build correlation matrix
C = buildCorMat(T);
figure, imagesc(C(1:1000,1:1000)); title('Part of correlation matrix');
xlabel('tags');ylabel('tags');colorbar;

%Example: tags 507 and 514 are very correlted 0.9999
cor_tags = [507,  514];
disp(['cor( ' TAGS_name{uniqueTagsIDs(cor_tags(1)),2} ' & ' TAGS_name{uniqueTagsIDs(cor_tags(2)),2} ') = ', num2str(T_cor(cor_tags(1),cor_tags(2)))]);

%% Tag clustering
K = 20; % number of tag clusters, which are treated as genres
[Lp, Tp, prunedTagsIDs]= prepocessForClustering(L_, T, 5, 50, uniqueArtistsIDs, tagged_ARTISTS);
[Lf, G, groups, tag_groups, popularity] = clusterTags(Lp, Tp, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs);


%% Build adjacency matrix and visualize clustered tags using the adjacency matrix 
A = buildCooccurrenceMatrix(Tp);
H = visTagGraph(A, groups, popularity, uniqueTagsIDs, prunedTagsIDs, TAGS_name);

%% Clustering via Self Organising Map (SOM)
% net = selforgmap([4,6]);
% net = configure(net,Tp);
% net.trainParam.epochs = 10000;
% net = train(net,Tp);
% plotsompos(net,Tp)





