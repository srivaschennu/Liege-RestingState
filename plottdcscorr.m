figure; hold all;

scores = [];
for g = 0:1
    scatter(nanmean(testdata(groupvar == g,stats.maxaucidx),2),tdcsimp(groupvar == g),100,'filled',...
        'MarkerFaceColor',facecolorlist(g+1,:),'MarkerEdgeColor',colorlist(g+1,:));
    scores = cat(1,scores,nanmean(testdata(groupvar == g,:),2));
end

set(gca,'FontSize',16,'FontName','Helvetica');
xlabel('\sigma(\theta centrality) at baseline','FontSize',16,'FontName','Helvetica');
ylabel('CRS-R improvement');
legend('non-resp','resp','Location','best');
% [rho,pval] = corr(nanmean(testdata(~isnan(groupvar),stats.maxaucidx),2),tdcsimp(~isnan(groupvar)),'type','spearman')
[brob,rstat] = robustfit(nanmean(testdata(~isnan(groupvar),stats.maxaucidx),2),tdcsimp(~isnan(groupvar)));
plot(xlim,brob(1)+brob(2)*xlim,'black','LineWidth',2,'LineStyle','--','DisplayName',sprintf('Robust t = %.2f,p = %.3f',rstat.t(2),rstat.p(2)));

export_fig(gcf,'figures/tdcscorr.tiff','-r300','-p0.01');
close(gcf);
