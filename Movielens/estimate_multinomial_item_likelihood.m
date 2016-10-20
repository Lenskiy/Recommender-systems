function log_pic = estimate_multinomial_item_likelihood(R, puc)
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
        end
    end
end