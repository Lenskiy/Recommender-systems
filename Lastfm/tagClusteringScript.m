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
K = 10; % number of tag clusters, which are treated as genres
[Lp, Tp, prunedTagsIDs]= prepocessForClustering(L_, T, 5, 50);
% K-means based clustering
[Lf, G, Tp, groups, tag_groups, popularity] = clusterTags(Lp, Tp, K, TAGS_name, tagged_ARTISTS, prunedTagsIDs);

%% Build adjacency matrix and visualize clustered tags using the adjacency matrix 
A = buildCooccurrenceMatrix(Tp);
[H, colors] = visTagGraph(A, groups, popularity, uniqueTagsIDs, prunedTagsIDs, TAGS_name);
axis off


tagNumber = size(Tp,2);
figure, hold on;
minY = 0; maxY = 0; pos = 0;
for k = 1:K
    hist = sum(Tp(:,groups{k}(:)));
    x = pos + 1: pos + length(hist);
    stem(x, hist, 'marker', 'none');
    maxY = max([maxY, max(hist)]);
    for j = 1:length(hist)
        maxY = max([max(hist) + length(tag_groups{k}{j}) + 5, maxY]);
        text(x(j), hist(j) + length(tag_groups{k}{j}) + 5, tag_groups{k}{j}, 'FontSize', round(log2(popularity(groups{k}(j)) + 1)/log2(1.8)), 'color', colors(k,:),'rotation',90);
    end
    axis([0, tagNumber, 0, maxY]);
    pos = pos + length(hist);
    %labels{k} = ['cluster: ' num2str(k)];
    [maxval, maxind] = maxN(hist, 2);
    labels{k} = [tag_groups{k}{maxind(1)}, ' / ',tag_groups{k}{maxind(2)}];
end
legend(labels,'Location','northwest','Orientation','vertical','FontWeight','bold', 'Fontsize', 14);
legend('boxoff');


%         if((-1)^k < 0)
%             textPos = - (j + 1) * textStep;
%         else
%             textPos =  (j + 1) * textStep + max(hist) + 10;
%         end
