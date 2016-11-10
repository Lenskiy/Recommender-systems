function visualizeHistogram(hist, t_list, labels, params)
    if(nargin < 4)
        plotProperties = [];
    else
        plotProperties = fieldnames(params);
    end
    figure('Position', [100, 100, 648, 309]), hold on, grid on;
	ax = bar(hist);
	for k = 1:length(plotProperties)
        set(ax, cell2mat(plotProperties(k)), getfield(params, cell2mat(plotProperties(k))));
    end
	%plot( prediction_incl_similar_array(:,1, r), 'color', ax.Color, 'LineStyle', ':');

	ghandler = gca;
	ghandler.XTick = [1:(length(hist))];
	ghandler.XTickLabel =  [t_list];
	legend(labels,'Location','northwest','Orientation','vertical','FontWeight','bold');
	legend('boxoff');
	xlabel('$r$', 'Interpreter', 'Latex');
	ylabel('$N(r)$', 'Interpreter', 'Latex');
end