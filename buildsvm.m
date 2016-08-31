function bestcls = buildsvm(features,groupvar,varargin)

param = finputcheck(varargin, {
    'runpca', 'string', {'true','false'}, 'false'; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

if ndims(features) == 3
    features = permute(features,[1 3 2]);
end

if strcmp(param.train,'true')
    clsyfyrparams = {'Standardize',true,'KernelFunction','RBF'};
else
    clsyfyrparams = {'KFold',4,'Standardize',true,'KernelFunction','RBF'};
end

% PCA - Keep enough components to explain the desired amount of variance.
explainedVarianceToKeepAsFraction = 95/100;

lastwarn('');
Cvals = unique(sort(cat(2, 10.^(-5:5), 5.^(-5:5), 2.^(-5:5))));
Kvals = unique(sort(cat(2, 10.^(-5:5), 5.^(-5:5), 2.^(-5:5))));

for d = 1:size(features,3)
    fprintf('Density %d\n',d);
    thisfeat = features(:,:,d);
    
    if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')  
        [~, pcaScores, ~, ~, explained] = pca(...
            thisfeat, ...
            'Centered', true);
        numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
        thisfeat = pcaScores(:,1:numPCAComponentsToKeep);
    end
    
    for c = 1:length(Cvals)
        for k = 1:length(Kvals)
            
            rng('default');
            model = fitcsvm(thisfeat,groupvar,clsyfyrparams{:},'BoxConstraint',Cvals(c),'KernelScale',Kvals(k));
            if strcmp(param.train,'true')
                [~,postProb] = predict(fitSVMPosterior(model),thisfeat);
            else
                [~,postProb] = kfoldPredict(fitSVMPosterior(model));
            end
            if ~strcmp(lastwarn,'')
                lastwarn('');
                auc{d}(c,k) = 0.5;
            else
                [~,~,~,auc{d}(c,k)] = perfcurve(groupvar,postProb(:,2),1);
            end
        end
    end
end
auc = permute(cat(3,auc{:}),[3 1 2]);

[~,maxidx] = max(abs(auc(:)));
[bestD,bestC,bestK] = ind2sub(size(auc),maxidx);

bestcls.D = bestD;
bestcls.C = Cvals(bestC);
bestcls.K = Kvals(bestK);

rng('default');
thisfeat = features(:,:,bestD);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    [bestcls.pcaCoeff, pcaScores, ~, ~, explained] = pca(...
        thisfeat, ...
        'Centered', true);
    bestcls.numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
end

bestcls.model = fitcsvm(thisfeat,groupvar,clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K);

if ~strcmp(param.train,'true')
    [~,postProb] = kfoldPredict(fitSVMPosterior(bestcls.model));
else
    [~,postProb] = predict(fitSVMPosterior(bestcls.model),thisfeat);
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