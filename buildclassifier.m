function bestcls = buildclassifier(features,groupvar,varargin)

param = finputcheck(varargin, {
    'C', 'real', [], []; ...
    'K', 'real', [], []; ...
    'runpca', 'string', {'true','false'}, 'false'; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

if strcmp(param.train,'true')
    clsyfyrparams = {'Standardize',true,'KernelFunction','RBF'};
else
    clsyfyrparams = {'KFold',4,'Standardize',true,'KernelFunction','RBF'};
end

if size(features,2) > 1 && strcmp(param.runpca,'true')
    [bestcls.pcaCoeff, pcaScores, ~, ~, explained] = pca(...
        features, ...
        'Centered', true);
    % Keep enough components to explain the desired amount of variance.
    explainedVarianceToKeepAsFraction = 95/100;
    bestcls.numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    features = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
end

lastwarn('');
if isempty(param.C) || isempty(param.K)
    Cvals = unique(sort(cat(2, 10.^(-5:5), 5.^(-5:5), 2.^(-5:5))));
    Kvals = unique(sort(cat(2, 10.^(-5:5), 5.^(-5:5), 2.^(-5:5))));
    
    for c = 1:length(Cvals)
        for k = 1:length(Kvals)
            
            rng('default');
            svmmodel = fitcsvm(features,groupvar,clsyfyrparams{:},'BoxConstraint',Cvals(c),'KernelScale',Kvals(k));
            if strcmp(param.train,'true')
                [~,postProb] = predict(fitSVMPosterior(svmmodel),features);
            else
                [~,postProb] = kfoldPredict(fitSVMPosterior(svmmodel));
            end
            if ~strcmp(lastwarn,'')
                lastwarn('');
                auc(c,k) = 0.5;
            else
                [x,y,t,auc(c,k)] = perfcurve(groupvar,postProb(:,2),1);
                [~,bestthresh] = max(y + (1-x) - 1);
                predLabels = double(postProb(:,2) > t(bestthresh));
            end
        end
    end
    
    [~,maxidx] = max(abs(auc(:)));
    [bestC,bestK] = ind2sub(size(auc),maxidx);
    
    bestcls.C = Cvals(bestC);
    bestcls.K = Kvals(bestK);
else
    bestcls.C = param.C;
    bestcls.K = param.K;
end

rng('default');
bestcls.svmmodel = fitcsvm(features,groupvar,clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K);

if ~strcmp(param.train,'true')
    [~,postProb] = kfoldPredict(fitSVMPosterior(bestcls.svmmodel));
else
    [~,postProb] = predict(fitSVMPosterior(bestcls.svmmodel),features);
end
[x,y,t,bestcls.auc] = perfcurve(groupvar,postProb(:,2),1);

bestcls.pval = ranksum(postProb(groupvar == 0,2),postProb(groupvar == 1,2));

% [~,bestthresh] = min(sqrt((0-x).^2 + (1-y).^2));
[~,bestthresh] = max(abs(y + (1-x) - 1));
predLabels = double(postProb(:,2) > t(bestthresh));
bestcls.bestthresh = t(bestthresh);

[~,bestcls.chi2,bestcls.chi2pval] = crosstab(groupvar,predLabels);
bestcls.accu = round(sum(groupvar==predLabels)*100/length(groupvar));

bestcls.confmat = confusionmat(groupvar,predLabels);
bestcls.confmat = bestcls.confmat*100 ./ repmat(sum(bestcls.confmat,2),1,2);
bestcls.predlabels = predLabels;
end