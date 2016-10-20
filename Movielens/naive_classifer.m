function classified = naive_classifer(posterior)
	% Find maximum value and index for each document 
    [~, classified]= max(posterior,[], 1);
end