function pc = estimate_prior_probability(C)
    hist = sum(C); % total number of documents in each category 
    total_docs = sum(sum(C)); % total number of documents
    pc = hist / total_docs; % estimate of the prior probability
end