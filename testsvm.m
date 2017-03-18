function results = testsvm(clsyfyr,testfeatures,testlabels,varargin)

param = finputcheck(varargin, {
    'runpca', 'string', {'true','false'}, 'false'; ...
    });

testfeatures = permute(testfeatures,[1 3 2]);

%% test best classifier on test data in locked cupboard

thisfeat = testfeatures(:,:,clsyfyr.D);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    pcaScores = thisfeat * clsyfyr.pcaCoeff;
    thisfeat = pcaScores(:,1:clsyfyr.numPCAComponentsToKeep);
end

[~,postProb] = predict(fitSVMPosterior(clsyfyr.model),thisfeat);
results.predlabels = (postProb(testlabels == 3,2) >= clsyfyr.bestthresh);
results.accu = mean(postProb(testlabels == 3,2) >= clsyfyr.bestthresh) * 100;

testlabels = double(testlabels > 0);
predlabels = double(results.predlabels > 0);
[~,results.chi2,results.chi2pval] = crosstab(testlabels,predlabels);
results.accu = round(sum(testlabels==predlabels)*100/length(testlabels));


end