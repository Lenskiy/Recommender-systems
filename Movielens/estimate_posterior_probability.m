function logpcd = estimate_posterior_probability(log_likelihood, prior)
    % p(c|d) = p(d|c) * p(d)
    Nd = size(log_likelihood,1);
    Nc = size(log_likelihood,2);
    logpcd = zeros(Nc, Nd);
    for c = 1:Nc
        logpcd(c,:) = log_likelihood(:,c) + log(prior(c));
    end
end