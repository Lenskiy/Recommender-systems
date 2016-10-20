function [pc, puc] = estimate_user_probability(R, C)
    %estimates probability of a user given category p(u|c)
    Nc = size(C,2);
    Nu = size(R,1);
    puc = zeros(Nu, Nc);
    for c = 1:Nc % Estimate conditional probability for all categories
        %disp(['Processed ', num2str(c), ' categories']);
        for w = 1:Nu % Counter number of times word w occurs in all documents
            puc(w,c) = 1 + double(R(w,:)) * C(:,c); % Add 1 to avoid zero probability
        end
        puc(:,c) = puc(:,c) / (Nu + sum(puc(:,c))); % Add Nw in the denominator to compensate for added 1
    end
    
    %estimates prior probability p(c)
	hist = sum(C); % total number of documents in each category 
    total_docs = sum(sum(C)); % total number of documents
    pc = hist / total_docs; % estimate of the prior probability
end