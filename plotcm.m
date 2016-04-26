function plotcm(varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], ''; ...
    });

groups = 0:length(param.groupnames)-1;
groups = groups(groups < 3);
grouppairs = nchoosek(groups,2);

fontname = 'Helvetica';
fontsize = 20;

load(sprintf('combclsyfyr_%s.mat',param.group));
for g = 1:size(clsyfyr,2)
    
    fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
        param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
        clsyfyr(g).auc,clsyfyr(g).pval,clsyfyr(g).chi2,clsyfyr(g).chi2pval,clsyfyr(g).accu);
    
    plotconfusion(clsyfyr(g).confmat,{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
    set(gca,'FontName',fontname,'FontSize',fontsize);
    if ~isempty(param.xlabel)
        xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
    else
        xlabel('EEG diagnosis','FontName',fontname,'FontSize',fontsize);
    end
    if ~isempty(param.ylabel)
        ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
    else
        ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
    end
    
    export_fig(gcf,sprintf('figures/clsyfyr_%s_vs_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}));
    close(gcf);
end