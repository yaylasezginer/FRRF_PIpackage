
% Read .csv data outputs and compile into a single .mat dataset

% Step 1. Read in Data

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

FRRF.mdate = datenum(FRRF.DATE) + datenum(FRRF.TIME);

ds = datestr(datetime('today'));
save([frrf_dir '/FRRF_' ds], 'FRRF')

% Step 2. Identify PI curve data

[PIind, curve_id] = PIfind(FRRF.Light_1, FRRF.mdate);

FRRF_PI = FRRF(PIind,:); 
FRRF_PI.curve_id = curve_id;

save([frrf_dir '/FRRF_PI' ds], 'FRRF_PI')
hold off

% Step 3. Run each curve through a PI model fitting function

% Define inputs
n = unique(curve_id);
savedir = '/Users/yaylasez/Desktop/Pearl2024/Figures/PIfigs';
algorithm = 'ETRa';
mused = 1; % Only use simple no photoinhibition model

% Pre-allocate saved arrays
PAR = [];
ETR = [];
ETR_err = [];
NPQ = [];
PI = table;

figure
for i = 1:numel(n)
    ind = find(curve_id == n(i));
    
    % Use FRRF_PIanalysis function to calculate ETR and then run ETR and
    % light data through a photosynthesis irradiance model 
    
    fig_dir = [savedir '/fig_' num2str(n(i))];
    
    [l, ps, ps_err, PI.pmax(i), PI.pmax_err(i), PI.ek(i), PI.ek_err(i),PI.alpha(i), PI.alpha_err(i),...
        PI.beta(i), PI.beta_err(i), PI.R2(i), npq, PI.mused(i), modelfit]...
        = FRRF_PIanalysis(FRRF_PI(ind,:), algorithm, fig_dir,mused);
    clf
    
    % Save outputs
    PAR = [PAR; l];
    ETR = [ETR; ps];
    ETR_err = [ETR_err; ps_err];
    NPQ = [NPQ; npq];
    
end

% Criteria for good data
model_fit = R2 > 0.99;
pmax_conf = pmax_err < 0.2*pmax;
ek_conf = ek_err < 0.2*ek;
alpha_conf = alpha_err < 0.2*alpha;
keep = all([model_fit', pmax_conf', ek_conf', alpha_conf'],2);

% Save derived parameters
PI_clean = PI(model_fit,:);
PI_clean.curve_ID = n(model_fit);