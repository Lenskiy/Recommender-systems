ratings = 1:5; % ratings
%% All users: exact prediction
for r = ratings
    disp(num2str(round(100*[avgPrediction(end,1,r), stdPrediction(end,1,r)], 1)));
end
%% All users: including correlated genres
for r = ratings
    disp(num2str(round(100*[avgPredictionSim(end,1,r), stdPredictionSim(end,1,r)], 1)));
end
%% More active: exact prediction
for r = ratings
    disp(num2str(round(100*[avgPredictionExp(end,1,r), stdPredictionExp(end,1,r)], 1)));
end
%% More active: including correlated genres
for r = ratings
    disp(num2str(round(100*[avgPredictionSimExp(end,1,r), stdPredictionSimExp(end,1,r)], 1)));
end
%% Critics: exact prediction
for r = ratings
    disp(num2str(round(100*[avgPredictionCr(end,1,r), stdPredictionCr(end,1,r)], 1)));
end
%% Critics: including correlated genres
for r = ratings
    disp(num2str(round(100*[avgPredictionSimCr(end,1,r), stdPredictionSimCr(end,1,r)], 1)));
end
%% Less active: exact prediction
for r = ratings
    disp(num2str(round(100*[avgPredictionLA(end,1,r), stdPredictionLA(end,1,r)], 1)));
end

%% Less active: including correlated genres
for r = ratings
    disp(num2str(round(100*[avgPredictionSimLA(end,1,r), stdPredictionSimLA(end,1,r)], 1)));
end

%% Combined ratings: all users
round(100*[avgPredictionCombined(end,1), stdPredictionCombined(end,1)], 1)  % 1 genre correctly predicted 
round(100*[avgPredictionCombined(end,2), stdPredictionCombined(end,2)], 1)  % 2 genre correctly predicted 
round(100*[avgPredictionCombined(end,3), stdPredictionCombined(end,3)], 1)  % 3 genre correctly predicted 
round(100*[avgPredictionCombinedSim(end,3), stdPredictionCombinedSim(end,3)], 1) % 3 genre correctly predicted including correlated
%% Combined ratings: More active
round(100*[avgPredictionCombinedExp(end,1), stdPredictionCombinedExp(end,1)], 1) % 1 genre correctly predicted
round(100*[avgPredictionCombinedExp(end,2), stdPredictionCombinedExp(end,2)], 1) % 2 genre correctly predicted
round(100*[avgPredictionCombinedExp(end,3), stdPredictionCombinedExp(end,3)], 1) % 3 genre correctly predicted
round(100*[avgPredictionCombinedSimExp(end,3), stdPredictionCombinedSimExp(end,3)], 1) % 3 genre correctly predicted including correlated
%% Combined ratings: Critics
round(100*[avgPredictionCombinedCr(end,1), stdPredictionCombinedCr(end,1)], 1) % 1 genre correctly predicted
round(100*[avgPredictionCombinedCr(end,2), stdPredictionCombinedCr(end,2)], 1) % 2 genre correctly predicted
round(100*[avgPredictionCombinedCr(end,3), stdPredictionCombinedCr(end,3)], 1) % 3 genre correctly predicted
round(100*[avgPredictionCombinedSimCr(end,3), stdPredictionCombinedSimCr(end,3)], 1) % 3 genre correctly predicted including correlated
%% Combined ratings: Less active
round(100*[avgPredictionCombinedLA(end,1), stdPredictionCombinedLA(end,1)], 1) % 1 genre correctly predicted
round(100*[avgPredictionCombinedLA(end,2), stdPredictionCombinedLA(end,2)], 1) % 2 genre correctly predicted
round(100*[avgPredictionCombinedLA(end,3), stdPredictionCombinedLA(end,3)], 1) % 3 genre correctly predicted
round(100*[avgPredictionCombinedSimLA(end,3), stdPredictionCombinedSimLA(end,3)], 1) % 3 genre correctly predicted including correlated