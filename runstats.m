function runstats(listname,varargin)


param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'xlabel', 'string', [], 'EEG diagnosis'; ...
    'ylabel', 'string', [], 'CRS-R diagnosis'; ...
    'alpha', 'real', [], 0.05; ...
    });

loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    };

featlist = {
    'ftdwpli','power',1
    'ftdwpli','power',2
    'ftdwpli','power',3
    'ftdwpli','median',1
    'ftdwpli','median',2
    'ftdwpli','median',3
    'ftdwpli','clustering',1
    'ftdwpli','clustering',2
    'ftdwpli','clustering',3
    'ftdwpli','characteristic path length',1
    'ftdwpli','characteristic path length',2
    'ftdwpli','characteristic path length',3
    'ftdwpli','modularity',1
    'ftdwpli','modularity',2
    'ftdwpli','modularity',3
    'ftdwpli','participation coefficient',1
    'ftdwpli','participation coefficient',2
    'ftdwpli','participation coefficient',3
    'ftdwpli','centrality',1
    'ftdwpli','centrality',2
    'ftdwpli','centrality',3
    'ftdwpli','modular span',1
    'ftdwpli','modular span',2
    'ftdwpli','modular span',3
    };

features = [];
allpvec = [];
featnames = cell(1,size(featlist,1));
for f = 1:size(featlist,1)
    [allfeat{f},groupvar,allauc{f},~,allpval{f}] = plotmeasure(listname,featlist{f,:},'noplot','on',varargin{:});
    p_thresh = fdr(allpval{f}(:),param.alpha);
    allpval{f}(allpval{f}>p_thresh) = 1;
end

groups = unique(groupvar(~isnan(groupvar)));
grouppairs = nchoosek(groups,2);

fprintf('\n');

for f = 1:size(featlist,1)
    for g = 1:size(grouppairs,1)
        [~,maxaucidx] = max(allauc{f}(g,:));
        if allpval{f}(g,maxaucidx) < param.alpha
            fprintf('%s band %s: %s vs %s AUC = %.2f, p = %.4f.\n', featlist{f,2},bands{featlist{f,3}},...
                param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
                allauc{f}(g,maxaucidx),allpval{f}(g,maxaucidx));
        end
    end
end

% corr_pvals = bonf_holm(pvals);
% [~,pval_mask] = fdr(pvals,0.05);
% corr_pvals = pvals;
% corr_pvals(~pval_mask) = 1;

% for bandidx = 1:length(bands)
%     fprintf('%s band: t(%.1f) = %5.2f, p = %.4f.\n',bands{bandidx},stats(bandidx).df,stats(bandidx).tstat,corr_pvals(bandidx));
%     fprintf('%s band: AUC = %.2f, U = %d, p = %.4f.\n',bands{bandidx},stats(bandidx).auc,stats(bandidx).U,corr_pvals(bandidx));
% end

% nonnanidx = ~isnan(grpout);
% grouplist = cell(size(grpout));
% grouplist(grpout == 0) = {'Group 0'};
% grouplist(grpout == 1) = {'Group 1'};
% 
% datatable = table(grouplist(nonnanidx),dataout(nonnanidx,1),dataout(nonnanidx,2),dataout(nonnanidx,3),'VariableNames',{'group',bands{1},bands{2},bands{3}});
% design = table(bands,'VariableNames',{'bands'});
% rmmodel = fitrm(datatable,'delta-alpha~group','WithinDesign',design);
% multcomptbl = multcompare(rmmodel,'group','By','bands');

% fprintf('\n');
% for r = 1:size(multcomptbl,1)
%     fprintf('%s - %s vs. %s: Diff = %.2f, ',multcomptbl.bands{r},multcomptbl.group_1{r},multcomptbl.group_2{r},multcomptbl.Difference(r));
%     if multcomptbl.pValue(r) >= 1e-4
%         fprintf('p = %.4f\n',multcomptbl.pValue(r));
%     else
%         fprintf('p = %.0e\n',multcomptbl.pValue(r));
%     end
% end
% fprintf('\n');
