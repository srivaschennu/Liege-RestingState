function calcftspec(basename)

loadpaths

load freqlist.mat

EEG = pop_loadset([filepath basename '.set']);
chanlocs = EEG.chanlocs;

mintrials = 50;
if EEG.trials < mintrials
    error('Need at least %d trials for analysis, only found %d.',mintrials,EEG.trials);
end

EEG = convertoft(EEG);

cfg = [];
cfg.output     = 'pow';
cfg.method     = 'mtmfft';
cfg.foilim        = [0.01 40];
% cfg.taper = 'rectwin';
cfg.taper = 'dpss';
cfg.tapsmofrq = 0.3;

EEG = ft_freqanalysis(cfg,EEG);
spectra = EEG.powspctrm;
freqs = EEG.freq;

save([filepath basename 'spectra.mat'], 'chanlocs', 'freqs', 'spectra', 'freqlist');
