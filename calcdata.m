function calcdata(listname,conntype)

loadpaths
loadsubj

subjlist = eval(listname);

load sortedlocs.mat
% load([chanlocpath '173to91.mat']);

for s = 1:size(subjlist,1)
    basename = subjlist{s,1};
    fprintf('Processing %s.\n',basename);
    
    specinfo = load([filepath basename 'spectra.mat']);
    [sortedchan,sortidx] = sort({specinfo.chanlocs.labels});
    if ~strcmp(chanlist,cell2mat(sortedchan))
        error('Channel names do not match!');
    end
    specinfo.spectra = specinfo.spectra(sortidx,:);
    specinfo.chanlocs = specinfo.chanlocs(sortidx);
    
%     specinfo.spectra = specinfo.spectra(keepidx,:);
%     specinfo.chanlocs = specinfo.chanlocs(keepidx);
    
    load([filepath conntype filesep basename conntype '.mat']);
    [sortedchan,sortidx] = sort({chanlocs.labels});
    if ~strcmp(chanlist,cell2mat(sortedchan))
        error('Channel names do not match!');
    end
    matrix = matrix(:,sortidx,sortidx);
    chanlocs = chanlocs(sortidx);
    bootmat = bootmat(:,sortidx,sortidx,:);

%     matrix = matrix(:,keepidx,keepidx);
%     bootmat = bootmat(:,keepidx,keepidx,:);
%     chanlocs = chanlocs(keepidx);
    
    if s == 1
        freqbins = specinfo.freqs;
        spectra = zeros(size(subjlist,1),length(chanlocs),length(specinfo.freqs));
        bandpower = zeros(size(subjlist,1),size(matrix,1),length(chanlocs));
        specent = zeros(size(subjlist,1),length(chanlocs));
        bandpeak = zeros(size(subjlist,1),size(matrix,1));
        allcoh = zeros(size(subjlist,1),size(matrix,1),length(chanlocs),length(chanlocs));
%         allbootcoh = zeros(length(subjlist),size(matrix,1),length(chanlocs),length(chanlocs));
    end
    
    matrix(isnan(matrix)) = 0;
    matrix = abs(matrix);
    allcoh(s,:,:,:) = matrix;
    
%     bootmat(isnan(bootmat)) = 0;
%     bootmat = abs(bootmat);
%     allbootcoh(s,:,:,:) = mean(bootmat,4);
    
    spectra(s,:,:) = specinfo.spectra;
    for f = 1:size(specinfo.freqlist,1)
        %collate spectral info
        [~, bstart] = min(abs(specinfo.freqs-specinfo.freqlist(f,1)));
        [~, bstop] = min(abs(specinfo.freqs-specinfo.freqlist(f,2)));
%         bandpower(s,f,:) = mean(specinfo.spectra(:,bstart:bstop),2);
        [~,peakindex] = max(mean(specinfo.spectra(:,bstart:bstop),1),[],2);
        bandpower(s,f,:) = specinfo.spectra(:,bstart+peakindex-1);
        
        maxpeakheight = 0;
        for c = 1:size(specinfo.spectra,1)
            [peakheight, peakfreq] = findpeaks(specinfo.spectra(c,bstart:bstop),'npeaks',1);
            if ~isempty(peakheight) && peakheight > maxpeakheight
                bandpeak(s,f) = specinfo.freqs(bstart-1+peakfreq);
                maxpeakheight = peakheight;
            end
        end
    end
    
    for c = 1:size(bandpower,3)
        bandpower(s,:,c) = bandpower(s,:,c)./sum(bandpower(s,:,c));
        specent(s,c) = -sum(bandpower(s,:,c) .* log(bandpower(s,:,c)));
    end
    grp(s,1) = subjlist{s,3};
end
save(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype), 'grp', 'spectra', 'freqbins', 'bandpower', 'specent', 'bandpeak', 'allcoh', 'subjlist'); %'allbootcoh',