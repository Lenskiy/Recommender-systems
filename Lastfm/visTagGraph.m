function H = visTagGraph(A, groups, popularity, uniqueTagsIDs, prunedTagsIDs, TAGS_name)
    for i = 1:size(TAGS_name,1)
        TAGS_name_array{cell2mat(TAGS_name(i,1))} = TAGS_name(i,2);
    end

    for i = 1:length(prunedTagsIDs)
        tag_names{i} = cell2mat(TAGS_name_array{uniqueTagsIDs(prunedTagsIDs(i))});
    end

    H = graph(A, tag_names, 'upper','OmitSelfLoops');
    LWidths = round(log2(H.Edges.Weight) + 1);
    grapthHandler = plot(H,'LineWidth',LWidths,'Layout','force');
    grapthHandler.NodeLabelMode = 'manual';
    grapthHandler.NodeLabel = tag_names;
    grapthHandler.EdgeAlpha = 0.01;

    for i = 1:length(groups)
        colors = [rand rand rand];
        for k = 1:length(groups{i})
            highlight(grapthHandler,groups{i}(k),'NodeColor',colors, 'Markersize', round(log2(popularity(groups{i}(k)))+1));
        end
        for j = 1:length(groups{i})
            connected = neighbors(H,groups{i}(j));
            highlight(grapthHandler,groups{i}(j),connected,'EdgeColor',colors);
        end
    end
end