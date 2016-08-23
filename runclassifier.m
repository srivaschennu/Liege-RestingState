function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS'}; ...
    'keepfeat', 'real', [], 3; ...
    'runpca', 'string', {'true','false'}, 'false'; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    };

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

% if param.keepfeat > 1
varargin = varargin(setdiff(1:length(varargin),[find(strcmp('keepfeat',varargin)) find(strcmp('keepfeat',varargin))+1]));
varargin = varargin(setdiff(1:length(varargin),[find(strcmp('train',varargin)) find(strcmp('train',varargin))+1]));

load(sprintf('stats_%s.mat',param.group));

selfeat = cell(1,size(clsyfyrs,2));

grouppairs = [
    0 1
    1 2
    2 3
    3 5
    ];

for g = 1:size(clsyfyrs,2)
    [~,sortidx] = sort(cell2mat({clsyfyrs(:,g).auc}),'descend');
%     selfeatidx = sortidx(1:param.keepfeat);
    selfeatidx = sortidx(1);%1:size(featlist,1);
    
    features = [];
    for f = selfeatidx
        [thisfeat,groupvar] = plotmeasure(listname,featlist{f,1:3},'noplot','on',varargin{:});
        features = cat(2,features,thisfeat);
        selfeat{g} = cat(1,selfeat{g},featlist(f,1:3));
    end
    fprintf('Combining the following features...\n');
    selfeat{g}
    
%     groups = unique(groupvar(~isnan(groupvar)));
%     grouppairs = nchoosek(groups,2);
    
    features = features(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:,:);
    groupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
    [~,~,groupvar] = unique(groupvar);
    groupvar = groupvar-1;
    
    if strcmp(param.train,'true')
        clsyfyr(g) = buildclassifier(features,groupvar,'train','true');
    else
        clsyfyr(g) = buildclassifier(squeeze(features(:,4,:)),groupvar);
        
        fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
            param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            clsyfyr(g).auc,clsyfyr(g).pval,clsyfyr(g).chi2,clsyfyr(g).chi2pval,clsyfyr(g).accu);
    end
end

groupnames = param.groupnames;
if strcmp(param.train,'true')
    save(sprintf('combclsyfyr_%s_train.mat',param.group),'selfeat','clsyfyr','grouppairs','groupnames');
else
    save(sprintf('combclsyfyr_%s.mat',param.group),'selfeat','clsyfyr','grouppairs','groupnames');
end

% else
%     for f = 1:size(featlist,1)
%         [features,groupvar] = plotmeasure(listname,featlist{f,:},'noplot','on',varargin{:});
%
%         groups = unique(groupvar(~isnan(groupvar)));
%         groups = groups(groups < 3);
%         grouppairs = nchoosek(groups,2);
%
%         for g = 1:size(grouppairs,1)
%             thisfeat = features(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:);
%             thisgroupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
%             [~,~,thisgroupvar] = unique(thisgroupvar);
%             thisgroupvar = thisgroupvar-1;
%
%             clsyfyr(g) = buildclassifier(thisfeat,thisgroupvar,'runpca','false');
%
%             fprintf('%s %s - %s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
%                 featlist{f,2},bands{featlist{f,3}},param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
%                 clsyfyr(g).auc,clsyfyr(g).pval,clsyfyr(g).chi2,clsyfyr(g).chi2pval,clsyfyr(g).accu);
%         end
%         featspec = featlist(f,:);
%         save(sprintf('clsyfyrs/clsyfyr_%s_%s_%s_%s.mat',featspec{1},featspec{2},bands{featspec{3}},param.group),...
%             'clsyfyr','featspec');
%         clear clsyfyr
%     end
% end

end

function bestcls = buildnnclassifier(features,groupvar,varargin)

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