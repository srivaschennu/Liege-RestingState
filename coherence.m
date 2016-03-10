function coherence(basename)

loadpaths

alpha = 0.05;
nboot = 50;

EEG = pop_loadset('filename',[basename '.set'],'filepath',filepath);
chanlocs = EEG.chanlocs;
times = EEG.times;

load freqlist
EEG.freqlist = freqlist;

matrix=zeros(size(EEG.freqlist,1),EEG.nbchan,EEG.nbchan,EEG.pnts);
% pval=zeros(size(EEG.freqlist,1),EEG.nbchan,EEG.nbchan,EEG.pnts);
% bootmat=zeros(size(EEG.freqlist,1),EEG.nbchan,EEG.nbchan,nboot,EEG.pnts);

freqbin = 0:0.5:45;

hilbdata = runhilbert(EEG,freqbin);

% calculate coherence between each pair of electrodes
for chann1=1:EEG.nbchan
    fprintf('%d',chann1);
    for chann2=1:EEG.nbchan
        fprintf(' %d',chann2);
        if chann1 < chann2
            [cohall, cohbootall] = calcwpli(hilbdata,chann1,chann2);
            
            for fidx = 1:size(EEG.freqlist,1)
%                 [matrix(fidx,chann1,chann2), pval(fidx,chann1,chann2), bootmat(fidx,chann1,chann2,:)] = ...
                    matrix(fidx,chann1,chann2,:) = ...
                    bandcoh(EEG.freqlist(fidx,1),EEG.freqlist(fidx,2),cohall,cohbootall,freqbin);
            end
        elseif chann1 > chann2
            matrix(:,chann1,chann2,:) = matrix(:,chann2,chann1,:);
%             pval(:,chann1,chann2) = pval(:,chann2,chann1);
%             bootmat(:,chann1,chann2,:) = bootmat(:,chann2,chann1,:);
        end
    end
    fprintf('\n');
end
fprintf('\n');

%%%% FDR correction
% for f = 1:size(EEG.freqlist,1)
%     coh = squeeze(matrix(f,:,:));
%     pvals = squeeze(pval(f,:,:));
%
%     tmp_pvals = pvals(logical(triu(ones(size(pvals)),1)));
%     tmp_coh = coh(logical(triu(ones(size(coh)),1)));
%
%     [~, p_masked]= fdr(tmp_pvals,alpha);
%     tmp_pvals(~p_masked) = 1;
%     tmp_coh(tmp_pvals >= alpha) = 0;
%
%     coh = zeros(size(coh));
%     coh(logical(triu(ones(size(coh)),1))) = tmp_coh;
%     coh = triu(coh,1)+triu(coh,1)';
%
%     pvals = zeros(size(pvals));
%     pvals(logical(triu(ones(size(pvals)),1))) = tmp_pvals;
%     pvals = triu(pvals,1)+triu(pvals,1)';
%
%     matrix(f,:,:) = coh;
%     pval(f,:,:) = pvals;
% end

fprintf('Saving %s.\n',[filepath 'wpli/' basename 'wplifdr.mat']);
save([filepath 'wpli/' basename 'wplifdr.mat'],'matrix','chanlocs','times','freqlist');%,'pval','bootmat',
end

function hilbdata = runhilbert(EEG,freqbin)
nbin = length(freqbin)-1;

hilbdata = zeros(nbin,EEG.nbchan,EEG.pnts,EEG.trials);

for f = 1:nbin
    filtEEG = pop_eegfiltnew(EEG,freqbin(f),freqbin(f+1));
    hilbdata(f,:,:,:) = filtEEG.data;
    for t = 1:EEG.trials
        hilbdata(f,:,:,t) = hilbert(squeeze(hilbdata(f,:,:,t))')';
    end
end
end