%% Convert 'F' to 1 and 'M' to 0
% Sex = zeros(length(Sex_), 1); 
% for k = 1:length(Sex)
%     if(cell2mat(Sex(k)) == 'F')
%         Sex(k) = 1;
%     end
% end

load('../Data/UsersInfo_1M.mat');
load('../Data/R_G_1M.mat');
G_ = bsxfun(@rdivide,G, sum(G')');
G_(isnan(G_)) = 0;
        
ageLabels = {'-17', '18-24', '25-34', '35-44', '45-49', '50-55', '56+'};
occupationLabels = {'other', 'academic/educator', 'artist', 'clerical/admin',...
    'college/grad student', 'customer service', 'doctor/health care', 'executive/managerial',...
    'farmer', 'homemaker', 'K-12 student', 'lawyer', 'programmer', 'retired'...
    'sales/marketing','scientist','self-employed','technician/engineer','tradesman/craftsman',...
    'unemployed','writer'};

totalUsers = length(UserID);
pSex = [sum(Sex), totalUsers - sum(Sex)]/totalUsers;
[pGenres, pUgivenG] = buildUserPrefenceModel(R, G_);
pGandU = bsxfun(@times, pUgivenG, pGenres);
pUsers = sum(pGandU, 2);
pGgivenU = bsxfun(@rdivide, pGandU,  pUsers);

for u = 1:;
    p = 
end
