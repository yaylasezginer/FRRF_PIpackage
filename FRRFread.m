
% Read .csv data outputs and compile into a single .mat dataset

% UPDATE WITH LOCAL DIRECTORY
frrf_dir = '/Users/yaylasez/Desktop/Pearl2024';

files = dir(frrf_dir); % Open data folder and read file names
data = contains({files.name},'_fit.csv'); % ID data files as .csv 
fn = {files(data).name}; % store the names of FRRF data files

FRRF = [];
for i = 1:numel(fn)
    
    filepath = [frrf_dir '/' fn{i}];
    dat = readtable(filepath);
    FRRF = [FRRF; dat];
    
end

% Save data to local folder with date
ds = datestr(datetime('today'));
save([frrf_dir '/FRRF_' ds],FRRF)
