function [titles, year_only] = parseTitle(org_title)

    par_open_pos_ = regexp(org_title, '\('); % position of openning parenthesis i.e in (1995)
    par_close_pos_ = regexp(org_title, '\)'); % position of closing parenthesis i.e in (1995)
    
    if(length(par_open_pos_) ~= length(par_close_pos_)) % number of closing and openning parenthesis does not match
        titles{1} = org_title;                         % return titles as is
        year_only = 0;
        return;
    end
    title_only = org_title;
    %check if there are nested parenthesis
    par_open_pos = par_open_pos_;
    par_close_pos = par_close_pos_;
    if(1 < length(par_close_pos))
        for k = 1:length(par_open_pos_) - 1
            if(par_close_pos_(k) > par_open_pos_(k + 1))
                par_open_pos(k + 1) = -1;
                par_close_pos(k) = -1;
            end
        end
        par_open_pos = par_open_pos(find(par_open_pos ~= -1));
        par_close_pos = par_close_pos(find(par_close_pos ~= -1));
    end
    
    shift = [0 cumsum(par_close_pos - (par_open_pos -1))];
	if(~isempty(par_open_pos))
        for k = length(par_open_pos):-1:1
            year_only = str2num(org_title(par_open_pos(k)+1:par_close_pos(k)-1));
            if(~isempty(year_only))
                title_only(par_open_pos(k):par_close_pos(k)) = [];
                par_open_pos(k+1:end) = par_open_pos(k + 1:end) - shift(k + 1);
                par_close_pos(k+1:end) = par_close_pos(k + 1:end) - shift(k + 1);
                par_open_pos(k) = [];
                par_close_pos(k) = [];
                break;
            end
        end
        
        for k = 1:length(par_open_pos)
            titles{k} = title_only((par_open_pos(k) + 1:par_close_pos(k) - 1) - shift(k));
            title_only((par_open_pos(k):par_close_pos(k)) - shift(k)) = [];
        end
    else
        year_only = 0;
        title_only = org_title;
    end
    
    titles{length(par_open_pos) + 1} = title_only;
    
    if(isempty(year_only)) %in the case if year has not been detect, set it to zero
        year_only = 0;
    end
    
    if(isempty(title_only))
        return;
    end
    
    for j = 1:length(titles)
        % remove articles "the" followed or precededby space
        ind = strfind(titles{j}, 'the ');
        ind = [ind strfind(titles{j}, 'The ')];
        for k = 1:length(ind)
            titles{j} = [titles{j}(1:ind(k)-1 - 4*(k - 1)) titles{j}(ind(k) + 4 - 4*(k - 1):end)];
        end
        ind = [];
        ind = [ind strfind(titles{j}, ' the')];
        ind = [ind strfind(titles{j}, ' The')];
        for k = 1:length(ind)
            titles{j} = [titles{j}(1:ind(k)-1 - 4*(k - 1)) titles{j}(ind(k) + 4 - 4*(k - 1):end)];
        end
        
        ind = [];
        ind = [ind strfind(titles{j}, 'a.k.a.')];
        for k = 1:length(ind)
            titles{j} = [titles{j}(1:ind(k)-1 - 6*(k - 1)) titles{j}(ind(k) + 6 - 6*(k - 1):end)];
        end
        
        %replace and with &
        ind = [];
        ind = [ind strfind(titles{j}, 'and')];
        for k = 1:length(ind)
            titles{j} = [titles{j}(1:ind(k)-1 - 3*(k - 1)), '&' ,titles{j}(ind(k) + 3 - 3*(k - 1):end)]; 
        end      
        
        %remove commas
        ind = strfind(titles{j}, ',');
        for k = 1:length(ind)
            titles{j} = [titles{j}(1:ind(k) - 1 - (k - 1) ) titles{j}(ind(k) + 1 - (k - 1):end)];
        end

        %remove spaces in the beginning an the end
        if(~isempty(titles{j})) % Check the title is not empty
            k = 1;
            while(k < length(titles{j}) && titles{j}(k) == ' ')
                k = k + 1;
            end
            titles{j} = titles{j}(k:end);
        end

        if(~isempty(titles{j})) % Check the title is not empty
            k = length(titles{j});
            while(0 < k && titles{j}(k) == ' ')
                k = k - 1;
            end

            titles{j} = titles{j}(1:k);
        end
    end
end