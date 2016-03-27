function testclassifier(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS'}; ...
    'keepfeat', 'real', [], 3; ...
    });

loadsubj
changroups

subjlist = eval(listname);

bands = {
    'delta'
    'theta'
    'alpha'
    };

fontname = 'Helvetica';
fontsize = 22;

load sortedlocs_91.mat
load(sprintf('combclsyfyr_%s_train.mat',param.group));

clsyfyr = clsyfyr(1);
selfeat = selfeat{1};
groupvar = cell2mat(subjlist(:,2));

features = [];
for f = 1:size(selfeat,1)
    thisfeat = getmeasure(listname,selfeat{f,1:3},sortedlocs,struct('changroup','all_91','changroup2','all_91'));
    features = cat(2,features,thisfeat);
end
fprintf('Testing with the following features...\n');
selfeat

features = features(groupvar == 0 | groupvar == 1,:);
groupvar = groupvar(groupvar == 0 | groupvar == 1);

[~,scores] = predict(fitSVMPosterior(clsyfyr.svmmodel),features);
scores = scores(:,2);
predlabels = double(scores >= clsyfyr.bestthresh);
accu = round(sum(logical(groupvar) == predlabels)*100/length(groupvar));

[~,chi2,chi2pval] = crosstab(groupvar,predlabels);
confmat = confusionmat(groupvar,predlabels);
confmat = confmat*100 ./ repmat(sum(confmat,2),1,2);
plotconfusion(confmat,param.groupnames);
set(gca,'FontName',fontname,'FontSize',fontsize);
xlabel('Predicted diagnosis','FontName',fontname,'FontSize',fontsize);
ylabel('True diagnosis','Fontname',fontname,'FontSize',fontsize);

fprintf('Test Chi2 = %.2f, p = %.4f, accu = %d%%.\n',chi2,chi2pval,accu);
end
