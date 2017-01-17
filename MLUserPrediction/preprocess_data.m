%% Data preparation: replace this section with new data. R is rating and G is category matrix
DB = '100k';
switch(DB)
    case '100k'
        load('R_G.mat');
        R(:, find(G(:,1) == 1)) = []; % Remove genre 1 - uknown 
        G(find(G(:,1) == 1), :) = []; % Remove genre 1 - uknown
        G(:, 1) = [];
        G = (G' ./ (ones(size(G,2), 1) * sum(G')))'; %convert to probabilities, each row sums up to one
    case '1M'
        load('R_G_1M.mat');
end



%% User profiles
%UserID::Gender::Age::Occupation::Zip-code
switch(DB)
    case '100k'
        occupations = importdata('/Users/artemlenskiy/Documents/Research/Data/recommender_systems/ml-100k/u.occupation', '\n');
        occupations_ind = [7 1 12 17 6 2 21 11 10 4 19 18 5 15 20 9 8 3 16 14 13];
        occupations_ind_fm = [14 1 12 9 8 2 21 11 10 4 19 18 5 15 20 17 6  3 16 7 13];
        
        fid = fopen('/Users/artemlenskiy/Documents/Research/Data/recommender_systems/ml-100k/u.user', 'rt')
        users = zeros(943, 4);
        for u = 1:943
            data = textscan(fid, '%s[^\n]');
            data = strsplit(cell2mat(data{1}),'|')
            users(u,1) = str2num(data{1});    % id
            users(u,2) = str2num(data{2});    % age
            if(strcmp(data{3}, 'M')) % gender
                users(u,3) = 0;
            else
                users(u,3) = 1;
            end

            %occupation
            for i = 1:length(occupations)
                if(strcmp(data{4},occupations{i}))
                    users(u,4) = find(occupations_ind_fm == i);
                    break;
                end
            end
            zip_codes{u} = data{5}; %zip codes
        end
        fid = fclose(fid);        
    case '1M'
        occupations = {'other'; 'academic/educator'; 'artist'; 'clerical/admin'; 'college/grad student';...
            'customer service'; 'doctor/health care';'executive/managerial'; 'farmer'; 'homemaker';...
            'K-12 student';'lawyer'; 'programmer'; 'retired';'sales/marketing'; 'scientist'; 'self-employed';...
            'technician/engineer'; 'tradesman/craftsman';'unemployed'; 'writer'};
        
        occupations_ind = [1 2 3 4 5 6 7 10 9 8 11 12 13 14 15 16 17 18 19 20 21];
        fid = fopen('/Users/artemlenskiy/Documents/Research/Data/recommender_systems/ml-1M/users.dat', 'rt');
        users = zeros(6040, 4);
        for u = 1:6040
            data = textscan(fid, '%s[^\n]');
            data = strsplit(cell2mat(data{1}),'::')
            users(u,1) = str2num(data{1});    % id
            users(u,2) = str2num(data{3});    % age
            if(strcmp(data{2}, 'M')) % gender
                users(u,3) = 0;
            else
                users(u,3) = 1;
            end
            
            users(u,4) = find(occupations_ind == (str2num(data{4}) + 1)); %occupation
            zip_codes{u} = data{5}; %zip codes
        end
        fid = fclose(fid);         
end





for u = 1:size(R,1)
        std_rated_movies(u) = std(R(u, R(u,:) ~= 0));
end
%% Devide users into two categories love_or_hate and preservative and plot in AGE-Occupation space
LH_ind = find(std_rated_movies > 1.0);
known_strategy = zeros(size(R,1),1);
known_strategy(LH_ind) = 1;
perserve_ind = find(std_rated_movies <= 1);
figure,hold on;
d1 = hist3([users(LH_ind,2) users(LH_ind,4)], {unique(users(:,2))-0.1, (min(users(:,4)):max(users(:,4))) - 0.1});
d2 = hist3([users(perserve_ind,2) users(perserve_ind,4)], {unique(users(:,2))-0.1 , min(users(:,4)):max(users(:,4))});
prior_LH = length(LH_ind) / length(users(:,3));
prior_perserve = length(perserve_ind) / length(users(:,3));
surf(prior_LH * d1/sum(sum(d1)),'FaceColor','g','FaceAlpha',.3);
surf(prior_perserve * d2/sum(sum(d2)),'FaceColor','r','FaceAlpha',.8);
hold off;
ax = gca;
set(ax, 'ytick', unique(users(:,2)));
ax.XTick = [1:length(occupations)];
ax.XTickLabel = occupations(occupations_ind);
ax.YTick = [1:length(unique(users(:,2)))];
ax.YTickLabel = unique(users(:,2));
set(gca, 'XTickLabelRotation', 90)
ylabel('age')
legend('Love and hate', 'Preservative');

%% Rating stragegy prediction based on age and occupation
PDF_LH = d1/sum(sum(d1));
PDF_perserve = d2/sum(sum(d2));
age_group = unique(users(users(:,3) == 0,2));
for i = 1:size(R,1)
    x = find(users(i,2) == age_group);
    y = users(i,4);
    if(PDF_LH(x,y) * prior_LH < PDF_perserve(x,y) * prior_perserve)
        predicted_rating_strategy(i) = 0;
    else
        predicted_rating_strategy(i) = 1;
    end
end

%Prediction rate
1 - sum(abs(predicted_rating_strategy' - known_strategy))/length(predicted_rating_strategy)



%% Devide users into two categories man and woman and plot in AGE-Occupation space
% figure, hold on, xlabel('age');
% plot(users(users(:,3) == 0,2), users(users(:,3) == 0,4), '.')
% plot(users(users(:,3) == 1,2), users(users(:,3) == 1,4), '.r')
figure,hold on;
d1 = hist3([users(users(:,3) == 0,2) users(users(:,3) == 0,4)], {unique(users(:,2))-0.1, (min(users(:,4)):max(users(:,4))) - 0.1});
d2 = hist3([users(users(:,3) == 1,2) users(users(:,3) == 1,4)], {unique(users(:,2))-0.1 , min(users(:,4)):max(users(:,4))});
prior_m = sum(users(:,3) == 0) / length(users(:,3));
prior_f = sum(users(:,3) == 1) / length(users(:,3));
surf(prior_m * d1/sum(sum(d1)),'FaceColor','g','FaceAlpha',.3);
surf(prior_f * d2/sum(sum(d2)),'FaceColor','r','FaceAlpha',.8);
hold off;
ax = gca;
set(ax, 'ytick', unique(users(:,2)));
ax.XTick = [1:length(occupations)];
ax.XTickLabel = occupations(occupations_ind);
ax.YTick = [1:length(unique(users(:,2)))];
ax.YTickLabel = unique(users(:,2));
set(gca, 'XTickLabelRotation', 90)
ylabel('age')
legend('Male', 'Female');

%% Gender prediction based on age and occupation
PDFm = d1/sum(sum(d1));
PDFf = d2/sum(sum(d2));
age_group = unique(users(users(:,3) == 0,2));
for i = 1:size(R,1)
    x = find(users(i,2) == age_group);
    y = users(i,4);
    if(PDFm(x,y) * prior_m > PDFf(x,y) * prior_f)
        predicted_g(i) = 0;
    else
        predicted_g(i) = 1;
    end
end

%prediction rate
1 - sum(abs(predicted_g' - users(:,3)))/length(predicted_g)
