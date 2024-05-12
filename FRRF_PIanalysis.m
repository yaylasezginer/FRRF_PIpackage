function [l, ps, ps_err, pmax, pmax_err,ek, ek_err,alpha,alpha_err, beta, beta_err, R2, NPQ, mused, modelfit] = FRRF_PIanalysis(frrf, algorithm, savedir,mused)

% INPUT
% FRRF - table output from FRRF data. Table should include data for a
% single PI curve.
% algorithm - 'ETRa' or 'ETRk'.
% savedir - optional parameter with dir path to save figures
%
% OUTPUT
% l = par (uE)
% ps = ETR (e RCII^-1 s^-1)
% PI curve shape parameters = pmax (etr units), ek (par units), alpha (etr/par units)
% R2 = fit r2
% NPQ = npq at each light level, unitless. Can fiddle with npq algorithm -
% currently set to return npq_nsv
% mused = photoinhibition or regular curve fit
% modelfit = matlab fit structure 

par_ind = contains(frrf.Properties.VariableNames, 'Light_');
par = sum(table2array(frrf(:,par_ind)),2);
dark = par == 0;

fvfm = mean(frrf.Fv_Fm(dark));
sigma = mean(frrf.Sig(dark));
fo = mean(frrf.Fo(dark));
sigma_prime = frrf.Sig;
fo_prime = fo ./ (fvfm + fo./frrf.Fm);
fqfv = frrf.Fv ./ fo_prime;
fqfm = frrf.Fv_Fm;
tau = (frrf.Alp1QA .* frrf.Tau1QA + frrf.Alp2QA .* frrf.Tau2QA + frrf.Alp3QA .* frrf.Tau3QA) * 1E-6; % convert to seconds

npq_nsv = fo_prime./(frrf.Fm - fo_prime);
npq = (mean(frrf.Fm(dark)) - frrf.Fm)./mean(frrf.Fm(dark));

%etra = par .* fqfv .* sigma_prime * 6.022E-3; 
etra = par .* fqfm .* sigma .* fvfm^-1 * 6.022E-3; 

% Keep par within range of light relavent to in-situ levels 
keep = par < 1000;

% Analyze PI curve - extract parameters

[l, ps, ps_err, pmax, pmax_err, ek, ek_err, alpha, alpha_err, beta, beta_err, R2, mused, modelfit] = PvI_ys4(par(keep), etra(keep),2,mused);

NPQ = ones(size(l));
for i = 1:numel(l)
    NPQ(i) = nanmean(npq_nsv(par == l(i)));
    if isnan(l(i))
        NPQ(i) = nan;
    end
end

if contains(lower(algorithm), 'etrk')
    [~,ek_ind] = min(abs(par - ek));
    [~,emax_ind] = min(abs(par - 3*ek));
    tauQa = mean(tau(ek_ind));
    fqfm_emax = mean(fqfm(emax_ind));
    emax = par(emax_ind);
    etrk = (par .* fqfm) ./ (emax .* fqfm_emax) .* 1/tauQa;
    
    [l, ps, ps_err, pmax, pmax_err, ek, ek_err, alpha, alpha_err, beta, beta_err, R2, mused, modelfit] = PvI_ys4(par(keep), etrk(keep), 1,mused);
    
end

if exist('savedir','var')
    saveas(gcf, savedir)
end


end
