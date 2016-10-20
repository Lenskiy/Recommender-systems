function [meanPredRate, stdPredRate] = compareMats(Gpred, Gtarget)
    pred = [];
    nonZeroMovies = 0;
    for i = 1:size(Gpred,1)
        if(sum((Gtarget(i,:))) ~= 0)
           pred(i) = sum(Gpred(i, :) & Gtarget(i,:))/sum(Gtarget(i,:));
           nonZeroMovies = nonZeroMovies + 1;
        end
    end
    meanPredRate = sum(pred)/nonZeroMovies;
    stdPredRate = std(pred);
end