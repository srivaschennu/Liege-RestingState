function bestcls = buildknn(features,groupvar,varargin)

param = finputcheck(varargin, {
    'runpca', 'string', {'true','false'}, 'false'; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

if ndims(features) == 3
    features = permute(features,[1 3 2]);
end

if strcmp(param.train,'true')
    clsyfyrparams = {'Standardize',true};
else
    clsyfyrparams = {'KFold',4,'Standardize',true};
end

lastwarn('');
Nvals = 1:10;

for d = 1:size(features,3)
    fprintf('Density %d\n',d);
    thisfeat = features(:,:,d);
    
    if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
        [bestcls.pcaCoeff, pcaScores, ~, ~, explained] = pca(...
            thisfeat, ...
            'Centered', true);
        % Keep enough components to explain the desired amount of variance.
        explainedVarianceToKeepAsFraction = 95/100;
        bestcls.numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
        thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
    end
    
    for n = 1:length(Nvals)
        
        rng('default');
        model = fitcknn(thisfeat,groupvar,clsyfyrparams{:},'NumNeighbors',n);
        if strcmp(param.train,'true')
            [~,postProb] = predict(model,thisfeat);
        else
            [~,postProb] = predict(model,thisfeat);
        end
        if ~strcmp(lastwarn,'')
            lastwarn('');
            auc(d,n) = 0.5;
        else
            [x,y,t,auc(d,n)] = perfcurve(groupvar,postProb(:,2),1);
        end
    end
end

[~,maxidx] = max(abs(auc(:)));
[bestD,bestN] = ind2sub(size(auc),maxidx);

bestcls.D = bestD;
bestcls.N = Nvals(bestN);

rng('default');
thisfeat = features(:,:,bestD);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    [bestcls.pcaCoeff, pcaScores, ~, ~, explained] = pca(...
        thisfeat, ...
        'Centered', true);
    % Keep enough components to explain the desired amount of variance.
    explainedVarianceToKeepAsFraction = 95/100;
    bestcls.numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
end

bestcls.model = fitcknn(thisfeat,groupvar,clsyfyrparams{:},'NumNeighbors',bestcls.N);

if ~strcmp(param.train,'true')
    [~,postProb] = kfoldPredict(bestcls.model);
else
    [~,postProb] = predict(bestcls.model,thisfeat);
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