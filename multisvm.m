function bestcls = multisvm(features,groupvar,varargin)

rng('default');

param = finputcheck(varargin, {
    'runpca', 'string', {'true','false'}, 'false'; ...
    });

features = permute(features,[1 3 2]);

clsyfyrparams = {'Standardize',true,'KernelFunction','RBF'};
cvoption = {'KFold',4};

% PCA - Keep enough components to explain the desired amount of variance.
explainedVarianceToKeepAsFraction = 95/100;

Cvals = unique(sort(cat(2, 10.^(-3:3), 5.^(-3:3), 2.^(-5:5))));
Kvals = unique(sort(cat(2, 10.^(-3:3), 5.^(-3:3), 2.^(-5:5))));

trainfeatures = features;
trainlabels = groupvar;

%% search through parameters for best cross-validated classifier
rng('default');
warning('off','stats:glmfit:IterationLimit');
thisfeat = trainfeatures;

if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    [~, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
    numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    thisfeat = pcaScores(:,1:numPCAComponentsToKeep);
end

perf = zeros(length(Cvals),length(Kvals));
for c = 1:length(Cvals)
    for k = 1:length(Kvals)
        model = fitcecoc(thisfeat,trainlabels,cvoption{:},...
            'Learners',templateSVM(clsyfyrparams{:},'BoxConstraint',Cvals(c),'KernelScale',Kvals(k)));
        perf(c,k) = (1-kfoldLoss(model))*100;
    end
end
warning('on','stats:glmfit:IterationLimit');

[bestcls.perf,maxidx] = max(abs(perf(:)));
[bestC,bestK] = ind2sub(size(perf),maxidx);
bestcls.C = Cvals(bestC);
bestcls.K = Kvals(bestK);

model = fitcecoc(thisfeat,trainlabels,cvoption{:},...
    'Learners',templateSVM(clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K));
bestcls.predlabels = kfoldPredict(model);

%% build best cross-validated classifier
thisfeat = trainfeatures(:,:,bestcls.D);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    [bestcls.pcaCoeff, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
    bestcls.numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
end

model = fitcecoc(thisfeat,trainlabels,cvoption{:},...
    'Learners',templateSVM(clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K));
predlabels = kfoldPredict(model);
[bestcls.confmat,bestcls.chi2,bestcls.chi2pval] = crosstab(trainlabels,predlabels);
bestcls.accu = (1 - kfoldLoss(model)) * 100;
bestcls.predlabels = predlabels;

bestcls.model = fitcecoc(thisfeat,trainlabels,...
    'Learners',templateSVM(clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K));

bestcls.clsyfyrparams = clsyfyrparams;
bestcls.cvoption = cvoption;
end