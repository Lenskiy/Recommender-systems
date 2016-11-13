

    
    for t = 1:size(T, 2)
        sumOverTags = sum(T, 2);
        for a = 1:size(T, 1)
            pAgivenT(a, t) = sumOverTags(a) / totalTags;
        end
    end