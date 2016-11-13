function plotClusteredHistrogram(Tp, groups, tag_groups, popularity, colors)
    tagNumber = size(Tp,2);
    figure, hold on;
    maxY = 0; pos = 0;
    for k = 1:size(groups,2)
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
        [~, maxind] = maxN(hist, 2);
        labels{k} = [tag_groups{k}{maxind(1)}, ' / ',tag_groups{k}{maxind(2)}];
    end
    legend(labels,'Location','northwest','Orientation','vertical','FontWeight','bold', 'Fontsize', 14);
    legend('boxoff');
end