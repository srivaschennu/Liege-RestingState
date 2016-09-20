function bestcls = buildknn(features,groupvar,varargin)

rng('default');

param = finputcheck(varargin, {
    'runpca', 'string', {'true','false'}, 'false'; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

if ndims(features) == 3
    features = permute(features,[1 3 2]);
end

clsyfyrparams = {'Standardize',true};
if strcmp(param.train,'true')
    cvoption = {};
else
    cvoption = {'Leaveout','on'};
end

% PCA - Keep enough components to explain the desired amount of variance.
explainedVarianceToKeepAsFraction = 95/100;

Nvals = 1:10;

%% put test data in a 'locked cupboard'
cvp = cvpartition(groupvar,'KFold',3);
trainfeatures = features(cvp.training(1),:,:);
trainlabels = groupvar(cvp.training(1),1);
testfeatures = features(cvp.test(1),:,:);
testlabels = groupvar(cvp.test(1),1);

%% start parallel pool
curpool = gcp('nocreate');
if isempty(curpool)
    parpool(parallel.defaultClusterProfile,size(features,3));
elseif curpool.NumWorkers ~= size(features,3)
    delete(curpool);
    parpool(parallel.defaultClusterProfile,size(features,3));
end

%% search through parameters for best cross-validated classifier
parfor d = 1:size(features,3)
    rng('default');
    thisfeat = trainfeatures(:,:,d);
    
    if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
        [~, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
        numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
        thisfeat = pcaScores(:,1:numPCAComponentsToKeep);
    end
    
    for n = 1:length(Nvals)
        model = fitcknn(thisfeat,trainlabels,clsyfyrparams{:},cvoption{:},'NumNeighbors',Nvals(n));
        auc{d}(n) = (1 - kfoldLoss(model)) * 100;
    end
end
auc = cat(1,auc{:});

[~,maxidx] = max(abs(auc(:)));
[bestD,bestN] = ind2sub(size(auc),maxidx);

bestcls.D = bestD;
bestcls.N = Nvals(bestN);

%% build best cross-validated classifier
thisfeat = trainfeatures(:,:,bestD);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    [bestcls.pcaCoeff, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
    bestcls.numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
end

model = fitcknn(thisfeat,trainlabels,clsyfyrparams{:},cvoption{:},'NumNeighbors',bestcls.N);
bestcls.accu = (1 - kfoldLoss(model)) * 100;

%% test best classifier on test data in locked cupboard
bestcls.model = fitcknn(thisfeat,trainlabels,clsyfyrparams{:},'NumNeighbors',bestcls.N);

thisfeat = testfeatures(:,:,bestD);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    pcaScores = thisfeat * bestcls.pcaCoeff;
    thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
end

predlabels = NaN(size(groupvar));
predlabels(cvp.test(1)) = predict(bestcls.model,thisfeat);

[~,bestcls.chi2,bestcls.chi2pval] = crosstab(testlabels,predlabels(~isnan(predlabels)));
bestcls.testaccu = round(sum(testlabels==predlabels(~isnan(predlabels)))*100/length(testlabels));

bestcls.confmat = confusionmat(testlabels,predlabels(~isnan(predlabels)));
bestcls.confmat = confusionmat(testlabels,predlabels(~isnan(predlabels)));
bestcls.J = bestcls.confmat(1,1)/(bestcls.confmat(1,1)+bestcls.confmat(1,2)) + ...
    bestcls.confmat(2,2)/(bestcls.confmat(2,1)+bestcls.confmat(2,2)) - 1;
bestcls.predlabels = predlabels;

end