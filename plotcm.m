function plotcm(varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS'}; ...
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], ''; ...
    'clim', 'real', [], [0 100]; ...
    });

fontname = 'Helvetica';
fontsize = 32;

load(sprintf('clsyfyr_%s.mat',param.group));
for g = 1:size(clsyfyr,2)
    
%     fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.1e, accu = %d%%.\n',...
%         param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
%         clsyfyr(g).auc,clsyfyr(g).pval,clsyfyr(g).chi2,clsyfyr(g).chi2pval,clsyfyr(g).accu);
    
    plotconfusionmat(clsyfyr(g).confmat,param.groupnames(1:length(groups)),'clim',param.clim);
    set(gca,'FontName',fontname,'FontSize',fontsize);
    if ~isempty(param.xlabel)
        xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
    else
        xlabel('EEG prediction','FontName',fontname,'FontSize',fontsize);
    end
    if ~isempty(param.ylabel)
        ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
    else
        ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
    end
    
    export_fig(gcf,sprintf('figures/clsyfyr_%s_cm.tiff',param.group),'-r300','-p0.01');
    close(gcf);
end