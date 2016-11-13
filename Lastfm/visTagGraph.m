function [H,  colors] = visTagGraph(A, groups, popularity, uniqueTagsIDs, prunedTagsIDs, TAGS_name)
    for i = 1:size(TAGS_name,1)
        TAGS_name_array{cell2mat(TAGS_name(i,1))} = TAGS_name(i,2);
    end

    for i = 1:length(prunedTagsIDs)
        tag_names{i} = cell2mat(TAGS_name_array{uniqueTagsIDs(prunedTagsIDs(i))});
    end

    H = graph(A, tag_names, 'upper','OmitSelfLoops');
    LWidths = round(log2(H.Edges.Weight) + 1);
    grapthHandler = plot(H,'LineWidth',LWidths,'Layout','subspace3', 'NodeLabel',[], 'Marker', 'none');
    %grapthHandler.NodeLabelMode = 'manual';
    %grapthHandler.NodeLabel = tag_names;
    grapthHandler.EdgeAlpha = 0.0;
    
    colors(1, :) = [     0    0.4470    0.7410];
    colors(2, :) = [0.8500    0.3250    0.0980];
    colors(3, :) = [0.9290    0.6940    0.1250];
    colors(4, :) = [0.4940    0.1840    0.5560];
    colors(5, :) = [0.4660    0.6740    0.1880];
    colors(6, :) = [0.3010    0.7450    0.9330];
    colors(7, :) = [0.6350    0.0780    0.1840];
    colors(8, :) = [1 0 0];
    colors(9, :) = [0 0.5 0];
    colors(10, :) = [0 0 1];
    colors(11, :) = [0 0.75 0.75];
    colors(12, :) = [0.75 0 0.75];
    colors(13, :) = [0.75 0.75 0];
    colors(14, :) = [0.25 0.25 0.2];    
    colors(15, :) = [0.1 .8 0.1];
    colors(16, :) = [0    0.7255    0.0902];
    colors(17, :) = [0.4706    0.5098    0.1922];
    colors(18, :) = [0    1.0000    0.7765];
    colors(19, :) = [1.0000    0.4314    0.254];
    colors(20, :) = [0.9098    0.3686    0.7451];

    set(groot,'defaultAxesColorOrder',colors);
    
    for i = 1:length(groups)
        %colors = [rand rand rand];
        for k = 1:length(groups{i})
            highlight(grapthHandler,groups{i}(k), 'NodeColor', colors(i,:), 'Markersize', round(log2(popularity(groups{i}(k)))+1));
        end
        for j = 1:length(groups{i})
            connected = neighbors(H,groups{i}(j));
            highlight(grapthHandler,groups{i}(j),connected,'EdgeColor',colors(i,:));
        end
    end
    
	for i=1:length(tag_names)
       for k = 1:length(groups)
        	if(sum(ismember(groups{k}, i)))
                break;
            end
       end
       text(grapthHandler.XData(i) + .1,grapthHandler.YData(i)  + .1, grapthHandler.ZData(i)  + .1,tag_names(i),'fontsize',round(log2(popularity(i) + 1)/log2(1.5)) + 1, 'FontWeight', 'bold', 'color', colors(k,:));
    end
end