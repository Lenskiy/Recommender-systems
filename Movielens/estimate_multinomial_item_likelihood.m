function [log_pic, pIgivenC] = estimate_multinomial_item_likelihood(R, puc, prior)
%Estimate likelihood p(d|c) = prod(T(w,d) * p(w|c))
    Nc = size(puc,2); % number of categoires  
    Nm = size(R,2); % number of items  
    log_pic = zeros(Nm, Nc);
    for c = 1:Nc
        %disp(['Processed ', num2str(c), ' categoires']);
        for m = 1:Nm
            %product of p(w|c) is replaced by the sum log(p|c) to solve
            %precision problem, caused by multiplictions of very small
            %numbers
            log_pic(m,c) = sum(double(R(:, m)).*log(puc(:,c))); 
            %log_pic(m,c) = prod(puc(:,c).^R(:, m));
        end
    end    
%     ItemRatings = sum(R);
%     pItemRatings = histcounts(ItemRatings, 'BinMethod', 'integers','Normalization' ,'count');
%     pItemRatings = pItemRatings(2:end);
%     pItemRatings = pItemRatings / sum(pItemRatings);
% %     timesRated = unique(ItemRatings);
% %     clear h
% %     for k = 1:length(timesRated)-1
% %         h(timesRated(k+1)) = sum(ItemRatings == timesRated(k+1));
% %     end
%     %sum(h .* [1:timesRated(end)])
%     pIgivenC = zeros(size(R, 2), Nc);
%     for m = 1:size(R, 2)
%         for c = 1:Nc
%             %for u = 1:size(R, 1)
%                 if(ItemRatings(m) ~= 0)
% %                    pIgivenC(m, c) = exp(log(prior(c)) + sum(log(1:sum(R(:, m)))) + sum(log(puc(:,c)).*R(:, m)));
%                      pIgivenC(m, c) = (log(pItemRatings(ItemRatings(m)))  + sum(log(1:ItemRatings(m))) + sum(R(:, m).*log(puc(:,c))) + log(prior(c))); %  - log(1:R(:, m)) % add for multinomial 
%                 end
%             %end
%         end
%     end
end