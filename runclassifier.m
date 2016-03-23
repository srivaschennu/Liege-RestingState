function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'xlabel', 'string', [], 'EEG diagnosis'; ...
    'ylabel', 'string', [], 'CRS-R diagnosis'; ...
    'clsyfyr', 'struct', [], []; ...
    'alpha', 'real', [], 0.05; ...
    });
loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    };

fontname = 'Helvetica';
fontsize = 24;

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
    'ftdwpli','modular span',1
    'ftdwpli','modular span',2
    'ftdwpli','modular span',3
    };

if ~isempty(param.clsyfyr)
    keepprop = 0.25;
    varargin = varargin(setdiff(1:length(varargin),[find(strcmp('clsyfyr',varargin)) find(strcmp('clsyfyr',varargin))+1]));
    selfeat = cell(1,size(param.clsyfyr,2));

    for g = 1:size(param.clsyfyr,2)
        [sortedauc,sortidx] = sort(cell2mat({param.clsyfyr(:,g).auc}),'descend');
        selfeatidx = sortidx(1:round(keepprop*length(sortedauc)));

        features = [];
        for f = selfeatidx
                [thisfeat,groupvar] = plotmeasure(listname,featlist{f,:},'noplot','on',varargin{:});
                features = cat(2,features,thisfeat);
                selfeat{g} = cat(1,selfeat{g},featlist(f,:));
        end
        selfeat{g}
        
        groups = unique(groupvar(~isnan(groupvar)));
        grouppairs = nchoosek(groups,2);
        
        features = features(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:);
        groupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
        [~,~,groupvar] = unique(groupvar);
        groupvar = groupvar-1;
        
        clsyfyr(g) = buildclassifier(features,groupvar);
        
        fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
            param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            clsyfyr(g).auc,clsyfyr(g).pval,clsyfyr(g).chi2,clsyfyr(g).chi2pval,clsyfyr(g).accu);
        
        %% plot confusion matrix
        confmat = confusionmat(groupvar,clsyfyr(g).predLabels);
        confmat = confmat*100 ./ repmat(sum(confmat,2),1,2);
        
        plotconfusion(confmat,{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
        set(gca,'FontName',fontname,'FontSize',fontsize);
        xlabel('EEG diagnosis','FontName',fontname,'FontSize',fontsize);
        ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
        
        export_fig(gcf,sprintf('figures/clsyfyr_%s_vs_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}));
        close(gcf);
    end

    save(sprintf('combclsyfyr_%s.mat',param.group),'selfeat','clsyfyr');
    
else
    for f = 1:size(featlist,1)
        [features,groupvar] = plotmeasure(listname,featlist{f,:},'noplot','on',varargin{:});
        
        groups = unique(groupvar(~isnan(groupvar)));
        grouppairs = nchoosek(groups,2);
        
        for g = 1:size(grouppairs,1)
            thisfeat = features(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:);
            thisgroupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
            [~,~,thisgroupvar] = unique(thisgroupvar);
            thisgroupvar = thisgroupvar-1;
            
            clsyfyr(f,g) = buildclassifier(thisfeat,thisgroupvar);
            
            fprintf('%s %s - %s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
                featlist{f,2},bands{featlist{f,3}},param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
                clsyfyr(f,g).auc,clsyfyr(f,g).pval,clsyfyr(f,g).chi2,clsyfyr(f,g).chi2pval,clsyfyr(f,g).accu);
            
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
    end
    save(sprintf('clsyfyr_%s.mat',param.group),'featlist','clsyfyr');
end

end

function bestcls = buildclassifier(features,groupvar)

clsyfyrparams = {'KFold',4,'Standardize',true,'KernelFunction','RBF'};
Cvals = unique(sort(cat(2, 10.^(-5:5), 5.^(-5:5), 2.^(-5:5))));
Kvals = unique(sort(cat(2, 10.^(-5:5), 5.^(-5:5), 2.^(-5:5))));

for c = 1:length(Cvals)
    for k = 1:length(Kvals)
        
        rng('default');
        svmmodel = fitcsvm(features,groupvar,clsyfyrparams{:},'BoxConstraint',Cvals(c),'KernelScale',Kvals(k));
        
        orig_state = warning('off','all');
        [~,postProb] = kfoldPredict(fitSVMPosterior(svmmodel));
        warning(orig_state);
        
        [x,y,t,auc(c,k)] = perfcurve(groupvar,postProb(:,2),1);
        [~,bestthresh] = max(y + (1-x) - 1);
        predLabels = double(postProb(:,2) > t(bestthresh));
        [~,~] = crosstab(groupvar,predLabels);
    end
end

[~,maxidx] = max(auc(:));
[bestC,bestK] = ind2sub(size(auc),maxidx);

bestcls.C = Cvals(bestC);
bestcls.K = Kvals(bestK);

rng('default');
svmmodel = fitcsvm(features,groupvar,clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K);

[~,postProb] = kfoldPredict(fitSVMPosterior(svmmodel));
[x,y,t,bestcls.auc] = perfcurve(groupvar,postProb(:,2),1);

bestcls.pval = ranksum(postProb(groupvar == 0,2),postProb(groupvar == 1,2));

[~,bestthresh] = min(sqrt((0-x).^2 + (1-y).^2));
bestcls.predLabels = double(postProb(:,2) > t(bestthresh));

[~,bestcls.chi2,bestcls.chi2pval] = crosstab(groupvar,bestcls.predLabels);
bestcls.accu = round(sum(groupvar==bestcls.predLabels)*100/length(groupvar));

end