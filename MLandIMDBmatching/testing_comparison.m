figure, hold on;
plot(sum(G_test(:, 1:18)))
plot(sum(G_star(:,:,5)));

[m, s] = compareMats(G, G_test(:,1:18))
[m, s] = compareMats(G_star, G_test(:,1:18))
[m, s] = compareMats(G_star, G)
r = 5;
[m, s] = compareMats(G(:,:), G_test(:,1:18))

%% 
noGenresMoviesIND = find(sum(G_ext') == 0)'
% zeroInds = find(sum(G_imdb100k(:, :, 1)') == 0)
G_z = zeros(Nitems, length(genresList));

%% 
LIA = zeros(Nitems,1);
for i = 1:Nitems
  LIA(i,1) =(ismember(G(i,:), G_test(i,1:18)));
end


LIA = ismember(G(:,:),G_test(:,1:18),'rows');
[LIA,LOCB] = ismember(G,G_test(:,1:18),'rows');
