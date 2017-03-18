function bestcls = buildsvm(features,groupvar,varargin)

param = finputcheck(varargin, {
    'runpca', 'string', {'true','false'}, 'false'; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

features = permute(features,[1 3 2]);

clsyfyrparams = {'Standardize',true,'KernelFunction','RBF'};
cvoption = {'KFold',4};
% cvoption = {'Leaveout','on'};

% PCA - Keep enough components to explain the desired amount of variance.
explainedVarianceToKeepAsFraction = 95/100;

Cvals = unique(sort(cat(2, 10.^(-3:3), 5.^(-3:3), 2.^(-5:5))));
Kvals = unique(sort(cat(2, 10.^(-3:3), 5.^(-3:3), 2.^(-5:5))));

trainfeatures = features;
trainlabels = groupvar;
% %% put test data in a 'locked cupboard'
% cvp = cvpartition(groupvar,'KFold',4);
% trainfeatures = features(cvp.training(1),:,:);
% trainlabels = groupvar(cvp.training(1),1);
% testfeatures = features(cvp.test(1),:,:);
% testlabels = groupvar(cvp.test(1),1);

%% start parallel pool
curpool = gcp('nocreate');
if isempty(curpool)
%     parpool(parallel.defaultClusterProfile,size(features,3));
    parpool(parallel.defaultClusterProfile,3);
elseif curpool.NumWorkers ~= size(features,3)
    delete(curpool);
%     parpool(parallel.defaultClusterProfile,size(features,3));
    parpool(parallel.defaultClusterProfile,3);
end

%% search through parameters for best cross-validated classifier
parfor d = 1:size(features,3)
    rng('default');
    warning('off','stats:glmfit:IterationLimit');
    thisfeat = trainfeatures(:,:,d);
    
    if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
        [~, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
        numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
        thisfeat = pcaScores(:,1:numPCAComponentsToKeep);
    end
    
    for c = 1:length(Cvals)
        for k = 1:length(Kvals)
            rng('default');
            model = fitcsvm(thisfeat,trainlabels,clsyfyrparams{:},cvoption{:},'BoxConstraint',Cvals(c),'KernelScale',Kvals(k));
            [~,postProb] = kfoldPredict(fitSVMPosterior(model));
            [~,msgid] = lastwarn;
            if strcmp(msgid,'stats:glmfit:IllConditioned')
                auc{d}(c,k) = 0.5;
            else
                [~,~,~,auc{d}(c,k)] = perfcurve(trainlabels,postProb(:,2),1);
            end
        end
    end
    warning('on','stats:glmfit:IterationLimit');
end
auc = permute(cat(3,auc{:}),[3 1 2]);

[~,maxidx] = max(abs(auc(:)));
[bestD,bestC,bestK] = ind2sub(size(auc),maxidx);

bestcls.D = bestD;
bestcls.C = Cvals(bestC);
bestcls.K = Kvals(bestK);

%% build best cross-validated classifier
thisfeat = trainfeatures(:,:,bestcls.D);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    [bestcls.pcaCoeff, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
    bestcls.numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
end

rng('default');
model = fitcsvm(thisfeat,trainlabels,clsyfyrparams{:},cvoption{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K);

[~,postProb] = kfoldPredict(fitSVMPosterior(model));
[x,y,t,bestcls.auc] = perfcurve(trainlabels,postProb(:,2),1);
bestcls.pval = ranksum(postProb(trainlabels == 0,2),postProb(trainlabels == 1,2));
% [~,bestthresh] = min(sqrt((0-x).^2 + (1-y).^2));
[bestcls.J,bestthresh] = max(abs(y + (1-x) - 1));
bestcls.bestthresh = t(bestthresh);
predlabels = double(postProb(:,2) > bestcls.bestthresh);
bestcls.confmat = confusionmat(trainlabels,predlabels);
[~,bestcls.chi2,bestcls.chi2pval] = crosstab(trainlabels,predlabels);
bestcls.accu = round(sum(trainlabels==predlabels)*100/length(trainlabels));
bestcls.predlabels = predlabels;

bestcls.model = fitcsvm(thisfeat,trainlabels,clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K);

% %% test best classifier on test data in locked cupboard
% bestcls.model = fitcsvm(thisfeat,trainlabels,clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K);
% 
% thisfeat = testfeatures(:,:,bestD);
% if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
%     pcaScores = thisfeat * bestcls.pcaCoeff;
%     thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
% end
% 
% [~,postProb] = predict(fitSVMPosterior(bestcls.model),thisfeat);
% predlabels = NaN(size(groupvar));
% predlabels(cvp.test(1)) = double(postProb(:,2) > bestcls.bestthresh);
% 
% [~,bestcls.testchi2,bestcls.testchi2pval] = crosstab(testlabels,predlabels(~isnan(predlabels)));
% bestcls.testaccu = round(sum(testlabels==predlabels(~isnan(predlabels)))*100/length(testlabels));
% bestcls.predlabels = predlabels;

bestcls.clsyfyrparams = clsyfyrparams;
bestcls.cvoption = cvoption;
end