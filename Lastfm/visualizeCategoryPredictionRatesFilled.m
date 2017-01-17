function visualizeCategoryPredictionRatesFilled(avgPredicationRates, stdPredicationRates, t_list, labels, newPlot, params) 
    if(nargin == 4)
        newPlot = true;
    end
    plotProperties = fieldnames(params);
	ghandler = gca;
	ghandler.XTick = [1:(length(t_list))];
	ghandler.XTickLabel =  [t_list]*100;
    colors = ghandler.ColorOrder;
    colors(8, :) = [0 0 0];
    colors(9, :) = [0.1 .8 0.1];
    %close;
    Nrates = size(avgPredicationRates,3);
    if(newPlot)
        figure('Position', [100, 100, 648, 309]), hold on, grid on;
        %title(['Prediction based on ratings r = {1,2,3,4,5}']);
        xlabel('Portion of the total set used for training');
        ylabel('Prediction rate');           
    else
        min_Y = min(min(avgPredicationRates(:,1,:) - stdPredicationRates(:,1,:)), ghandler.YLim(1)) * 0.95;
        max_Y = max(max(avgPredicationRates(:,1,:) + stdPredicationRates(:,1,:)), ghandler.YLim(2)) * 1.05;
        %axis([0 (length(t_list) + 1) min_Y max_Y]);
    end
    

    for r = 1:Nrates
        mean_err = avgPredicationRates(:, 1, r);
        std_err = stdPredicationRates(:, 1, r);
        line([t_list(1:end-1) (t_list(2:end))], [mean_err(1:end-1)-std_err(1:end-1), (mean_err(2:end)-std_err(2:end))], 'color', [.4 .4 .4]);
        line([t_list(1:end-1) (t_list(2:end))], [mean_err(1:end-1)+std_err(1:end-1), (mean_err(2:end)+std_err(2:end))], 'color', [.4 .4 .4]);
        h = fill([t_list; flipud(t_list)]',[mean_err-std_err; flipud(mean_err+std_err)],[0, 0.4470, 0.7410],'linestyle','none');
        %set(h, 'color', [0, 0.4470, 0.7410]);
        set(h,'facealpha',.2);
        set(h,'edgealpha',.2)
        ax = line(t_list, mean_err, 'linestyle', '-', 'color', colors(r,:));            
        %ax = errorbar(avgPredicationRates(:,1, r), stdPredicationRates(:,1, r),'-', 'color', colors(r,:));

        for k = 1:length(plotProperties)
            set(ax, cell2mat(plotProperties(k)), getfield(params, cell2mat(plotProperties(k))));
            if(strcmp(cell2mat(plotProperties(k)), 'color'))
                set(h, 'facecolor', getfield(params, cell2mat(plotProperties(k))));
            end
        end
         %plot( prediction_incl_similar_array(:,1, r), 'color', ax.Color, 'LineStyle', ':');
    end
    
    %legend(gca,'off');
%    legend('hide');
%    legend(ax,labels, 'Location','best','Orientation','vertical','FontWeight','bold');
%    legend('show');
%    prevLabels = get(legend(gca),'String');
%	legend([prevLabels, labels],'Location','best','Orientation','vertical','FontWeight','bold');
%     legend(labels,'Location','best','Orientation','vertical','FontWeight','bold');
    %set(legend(gca),'DefaultAxesLineStyleOrder',{'-','--',':'})
	%legend('boxoff');
end