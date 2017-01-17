    Nc = size(G,2);
    ItemRatings = sum(R == 1);
    pItemRatings = histcounts(ItemRatings, 'BinMethod', 'integers','Normalization' ,'count');
    %pItemRatings = pItemRatings(2:end);
    pItemRatings = pItemRatings / sum(pItemRatings);
    pIgivenC = zeros(size(R, 2), Nc);
    for m = 1:size(R, 2)
        for c = 1:Nc
                %if(ItemRatings(m) ~= 0)
                    % log(pItemRatings(ItemRatings(m) + 1))
                     pIgivenC(m, c) = exp(log(pItemRatings(ItemRatings(m) + 1)) + sum(log(1:ItemRatings(m))) + sum(R(:, m).*log(pUgivenC(:,c))) + log(prior(c))) ; %  - log(1:R(:, m)) % add for multinomial 
                %end
        end
    end
    sum(sum(pIgivenC))%/pItemRatings(1)