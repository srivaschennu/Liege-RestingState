function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'xlabel', 'string', [], 'EEG diagnosis'; ...
    'ylabel', 'string', [], 'CRS-R diagnosis'; ...
    });
loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    };

featlist = {
    %     'ftdwpli','power',1
    %     'ftdwpli','power',2
    %     'ftdwpli','power',3
    %     'ftdwpli','median',1
    %     'ftdwpli','median',2
%     'ftdwpli','median',3
    %     'ftdwpli','clustering',1
    %     'ftdwpli','clustering',2
    %     'ftdwpli','clustering',3
    %     'ftdwpli','characteristic path length',1
    %     'ftdwpli','characteristic path length',2
    %     'ftdwpli','characteristic path length',3
%         'ftdwpli','modularity',1
    %     'ftdwpli','modularity',2
    %     'ftdwpli','modularity',3
    %     'ftdwpli','participation coefficient',1
    %     'ftdwpli','participation coefficient',2
    'ftdwpli','participation coefficient',3
    %     'ftdwpli','centrality',1
    %     'ftdwpli','centrality',2
    %     'ftdwpli','centrality',3
    %     'ftdwpli','modular span',1
    %     'ftdwpli','modular span',2
%         'ftdwpli','modular span',3
    };

features = [];
for f = 1:size(featlist,1)
    [thisfeat,groupvar] = plotmeasure(listname,featlist{f,:},'noplot','on',varargin{:});
    features = cat(2,features,thisfeat);
end

groups = unique(groupvar(~isnan(groupvar)));
grouppairs = nchoosek(groups,2);

fontname = 'Helvetica';
fontsize = 24;

clsyfyrparams = {'KFold',4,'Standardize',true,'KernelFunction','RBF','KernelScale','auto'};
Cvals = 10.^(-5:5);

for g = 1:size(grouppairs,1)
    thisfeat = features(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:);
    thisgroupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
    [~,~,thisgroupvar] = unique(thisgroupvar);
    thisgroupvar = thisgroupvar-1;
    
    for c = 1:length(Cvals)
        rng('default');
        svmmodel = fitcsvm(thisfeat,thisgroupvar,clsyfyrparams{:},'BoxConstraint',Cvals(c));
        
        [~,postProb] = kfoldPredict(fitSVMPosterior(svmmodel));
        [x,y,t,~] = perfcurve(thisgroupvar,postProb(:,2),1);
        [~,bestthresh] = max(y + (1-x) - 1);
        predLabels = double(postProb(:,2) > t(bestthresh));
        [~,chi2(c)] = crosstab(thisgroupvar,predLabels);
    end
    
    [~,maxidx] = max(chi2(:));
    rng('default');
    svmmodel = fitcsvm(thisfeat,thisgroupvar,clsyfyrparams{:},'BoxConstraint',Cvals(maxidx));
    [~,postProb] = kfoldPredict(fitSVMPosterior(svmmodel));
    [x,y,t,~] = perfcurve(thisgroupvar,postProb(:,2),1);
    [~,bestthresh] = min(sqrt((0-x).^2 + (1-y).^2));
    predLabels = double(postProb(:,2) > t(bestthresh));
    [~,chi2,chi2_p] = crosstab(thisgroupvar,predLabels);
    
    fprintf('%s vs %s: Chi2 = %.2f, p = %.5f, accu = %d%%.\n',...
        param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
        chi2,chi2_p,round(sum(thisgroupvar==predLabels)*100/length(thisgroupvar)));
    
    %     %% plot confusion matrix
    %     confmat = confusionmat(thisgroupvar,predLabels);
    %     confmat = confmat*100 ./ repmat(sum(confmat,2),1,2);
    %
    %     plotconfusion(confmat,{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
    %     set(gca,'FontName',fontname,'FontSize',fontsize);
    %     xlabel('EEG diagnosis','FontName',fontname,'FontSize',fontsize);
    %     ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
    %
    %     export_fig(gcf,sprintf('figures/clsyfyr_%s_vs_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}));
    %     close(gcf);
end

