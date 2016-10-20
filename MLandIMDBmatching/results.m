%% Preidction basd on G_
G_star = zeros(Nitems,Ngenres - 1);
resultG = zeros(Nitems, 1);
resultG_star = zeros(Nitems,Nrates);
Gtemp = zeros(5,18);
for i =1:Nitems
    i
    n = sum(G_test(i,1:18));
%     for r = 1:Nrates
%         r;
%         n = sum(G_test(i,1:18));
%         %[maxValues, maxValueIndices] = maxN(Pr_CategoryGivenI(:,i,r), n);
%         %Gtemp(r, maxValueIndices) = 1;
%         numGeners = length(find(G_test(i,:) == 1));
%         resultG_star(i,r) = length(intersect(find(G_test(i,:) == 1), find(G_star(i,:) == 1)))/numGeners;
%         disp(mean(resultG_star(i,r)));
%     end
    %[maxValues, maxValueIndices] = maxN(Pr_CategoryGivenI(:,i,5), n);
    %[maxValues, maxValueIndices] = maxN(sum(squeeze(Pr_CategoryGivenI(:,i,[1:3,5]))'), n);
    [maxValues, maxValueIndices] = maxN(sum(squeeze(Pr_CategoryGivenI(:,i,:))'), n);
    G_star(i,maxValueIndices) = 1;
    resultG(i) = length(intersect(find(G_test(i,:) == 1), find(G(i,:) == 1)))/numGeners;
end
disp(mean(resultG))
disp(mean(resultG_star))
