function bestcls = buildnn(features,groupvar,varargin)

param = finputcheck(varargin, {
    'N', 'real', [], []; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

if strcmp(param.train,'true')
    clsyfyrparams = {'Standardize',true,'KernelFunction','RBF'};
else
    clsyfyrparams = {'KFold',4,'Standardize',true,'KernelFunction','RBF'};
end
Nvals = 10:10:200;

nsamp = size(features,1);
cvpart = cvpartition(nsamp,'KFold',4);
groupvar = [groupvar ~groupvar];
for n = 1:length(Nvals)
    outputs = zeros(nsamp,2);
    for f = 1:cvpart.NumTestSets
        rng('default');
        nnet = patternnet(Nvals(n));
        
        trainidx = find(training(cvpart,f));
        testidx = find(test(cvpart,f));
        validx = trainidx(length(trainidx)-length(testidx)+1:end);
        trainidx = trainidx(1:length(trainidx)-length(testidx));
        nnet.divideFcn = 'divideind';
        nnet.divideParam.trainInd = trainidx;
        nnet.divideParam.valInd = validx;
        nnet.divideParam.testInd = testidx;
        
        nnet = train(nnet,features',groupvar');
        outputs(testidx,:) = nnet(features(testidx,:)')';
    end
    [~,~,~,auc(n)] = perfcurve(groupvar(:,1),outputs(:,1),1);
end
auc(auc < 0.5) = 1-auc(auc < 0.5);
[~,maxidx] = max(auc);
bestN = Nvals(maxidx);

for f = 1:cvpart.NumTestSets
    rng('default');
    nnet = patternnet(bestN);
    trainidx = training(cvpart,f);
    testidx = test(cvpart,f);
    validx = trainidx(length(trainidx)-length(testidx)+1:end);
    trainidx = trainidx(1:length(trainidx)-length(testidx));
    nnet.divideFcn = divideind(nsamp,trainidx,validx,testidx);
    
    bestcls.nnet = train(nnet,features,groupvar);
    outputs = nnet(features);
end


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