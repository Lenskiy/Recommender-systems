function visualizeCategoryPredictionRates(avgPredicationRates, stdPredicationRates, t_list, labels, newPlot, params) 
    if(nargin == 4)
        newPlot = true;
    end
    plotProperties = fieldnames(params);
    a = gca;
    colors = a.ColorOrder;
    colors(8, :) = [0 0 0];
    colors(9, :) = [0.1 .8 0.1];
    %close;
    Nrates = size(avgPredicationRates,3);
    if(newPlot)
        figure('Position', [100, 100, 648, 309]), hold on, grid on;
        %title(['Prediction based on ratings r = {1,2,3,4,5}']);
        xlabel('Training set (%)');
        ylabel('Prediction rate');           
    else
        min_Y = min(min(avgPredicationRates(:,1,:) - stdPredicationRates(:,1,:)), a.YLim(1)) * 0.95;
        max_Y = max(max(avgPredicationRates(:,1,:) + stdPredicationRates(:,1,:)), a.YLim(2)) * 1.05;
        axis([0 (length(t_list) + 1) min_Y max_Y]);
    end
    

    for r = 1:Nrates
            ax = errorbar(avgPredicationRates(:,1, r), stdPredicationRates(:,1, r),'-', 'color', colors(r,:));
            for k = 1:length(plotProperties)
                set(ax, cell2mat(plotProperties(k)), getfield(params, cell2mat(plotProperties(k))));
            end
            %plot( prediction_incl_similar_array(:,1, r), 'color', ax.Color, 'LineStyle', ':');
    end
	ghandler = gca;
	ghandler.XTick = [1:(length(t_list))];
	ghandler.XTickLabel =  [t_list]*100;
    prevLabels = get(legend(gca),'String');
	legend([prevLabels, labels],'Location','northwest','Orientation','vertical','FontWeight','bold');
	legend('boxoff');

end