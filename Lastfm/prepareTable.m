for cat = 1:5
disp(num2str(100 * [avgPrediction(end,cat) stdPrediction(end,cat)], 3));
disp(num2str(100 * [avgPredictionSim(end,cat) stdPredictionSim(end,cat)], 3));
end;

for cat = 1:5
disp(num2str(100 * [avgPrediction2(end,cat) stdPrediction2(end,cat)], 3));
disp(num2str(100 * [avgPredictionSim2(end,cat) stdPredictionSim2(end,cat)], 3));
end;