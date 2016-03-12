function calcwsmi(basename)

loadpaths

%%% The output variables are structured in cells corresponding 
%%% to each tau.
%%%
%%% Variables:
%%%
%%% sym: the symbolic transformation of the time series (carefull is zero based, symbols form 0 to 5). 
%%% Structure: channel x symbols x trials
%%%
%%% count: the probability (ocurrence rate) of each symbol.
%%% Structure: channel x symbols x trials
%%%
%%% smi: the symbolic mutual information connectivity 
%%% Structure:
%%% channels x channels x trials, with the connectivity between channels
%%%
%%% wsmi: idem to smi but weighted

EEG = pop_loadset('filepath',filepath,'filename',[basename '_csd.set']);
chanlocs = EEG.chanlocs;

EEG.data = reshape(reshape(EEG.data,EEG.nbchan,EEG.pnts*EEG.trials),EEG.nbchan,EEG.pnts/5,EEG.trials*5);

cfg.chan_sel = 1:size(EEG.data,1);  % compute for all pairs of channels
cfg.data_sel = 1:size(EEG.data,2); % compute using all samples
cfg.taus     = [32 16 8 4 2]; % compute for taus
cfg.kernel   = 3; % kernel = 3 (3 samples per symbol)
cfg.sf       = EEG.srate;  % sampling frequency
cfg.over_trials = 0;  % sampling frequency

[~, ~, ~, wsmi] = smi_and_wsmi(EEG.data, cfg);

matrix = zeros(length(wsmi),size(wsmi{1},1),size(wsmi{1},2));
for t = 1:length(wsmi)
    meanwsmi = mean(wsmi{t},3);
    meanwsmi(meanwsmi < 0) = 0;
    matrix(t,:,:) = triu(meanwsmi,1)+triu(meanwsmi,1)';
end

save([filepath 'wsmi/' basename 'wsmi.mat'],'wsmi','matrix','chanlocs','cfg');

