function dataimport(basename)

loadpaths

% chanlocmat = 'GSN-HydroCel-128.mat';
chanlocfile = 'GSN-HydroCel-257.sfp';

EEG = pop_readegi([rawpath basename '.raw'], [],[],'auto');
EEG = fixegilocs(EEG,[chanlocpath chanlocfile]);

EEG = eeg_checkset(EEG);

%%%% PREPROCESSING

%REMOVE PERIPHERAL CHANNELS
chanexcl = {'E31', 'E67', 'E73', 'E82', 'E91', 'E92', 'E93', 'E94', 'E102', 'E103', 'E104', 'E105', 'E111', 'E112', 'E113', 'E114', 'E120', 'E121', 'E122', 'E123', 'E133', 'E134', 'E135', 'E136', 'E145', 'E146', 'E147', 'E148', 'E156', 'E157', 'E158', 'E165', 'E166', 'E167', 'E168', 'E174', 'E175', 'E176', 'E177', 'E187', 'E188', 'E189', 'E190', 'E199', 'E200', 'E201', 'E208', 'E209', 'E216', 'E217', 'E218', 'E219', 'E225', 'E226', 'E227', 'E228', 'E229', 'E230', 'E231', 'E232', 'E233', 'E234', 'E235', 'E236', 'E237', 'E238', 'E239', 'E240', 'E241', 'E242', 'E243', 'E244', 'E245', 'E246', 'E247', 'E248', 'E249', 'E250', 'E251', 'E252', 'E253', 'E254', 'E255', 'E256'};
EEG = pop_select(EEG,'nochannel',chanexcl);

%REDUCE SAMPLING RATE TO 250HZ
if EEG.srate > 250
    fprintf('Downsampling to 250Hz.\n');
    EEG = pop_resample(EEG,250);
elseif EEG.srate < 250
    error('Sampling rate too low!');
end

%Filter
hpfreq = 0.5;
lpfreq = 45;
fprintf('Low-pass filtering below %.1fHz...\n',lpfreq);
EEG = pop_eegfiltnew(EEG, 0, lpfreq);
fprintf('High-pass filtering above %.1fHz...\n',hpfreq);
EEG = pop_eegfiltnew(EEG, hpfreq, 0);

%Remove line noise
fprintf('Removing line noise at 50Hz.\n');
EEG = rmlinenoisemt(EEG);

EEG.setname = sprintf('%s_orig',basename);
EEG.filename = sprintf('%s_orig.set',basename);
EEG.filepath = filepath;

EEG = eeg_checkset(EEG);

fprintf('Saving %s%s.\n', EEG.filepath, EEG.filename);
pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);
