function runstats(listname,conntype,measure,varargin)

loadsubj
subjlist = eval(listname);

bands = {
    'delta'
    'theta'
    'alpha'
%     'beta'
%     'gamma'
    };

for bandidx = 1:length(bands)
    [dataout(:,bandidx),grpout] = plotmeasure(listname,conntype,measure,bandidx,varargin{:});

%     [pvals(bandidx),~,stat] = ranksum(dataout(grpout == 0,bandidx),dataout(grpout == 1,bandidx));
%     n0 = sum(grpout == 0); n1 = sum(grpout == 1);
%     stat.U = (n0*n1)+(n0*(n0+1))/2-stat.ranksum;
%     stat.U = min(stat.U,(n0*n1) - stat.U);
%     stat.auc = stat.U/(n0*n1);
%     if stat.auc < 0.5
%         stat.auc = 1-stat.auc;
%     end
%     stats(bandidx) = stat;
    
%     [~,pvals(bandidx),~,stats(bandidx)] = ttest2(dataout(grpout == 0,bandidx),dataout(grpout == 1,bandidx),[],[],'unequal');
end
fprintf('\n');

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
