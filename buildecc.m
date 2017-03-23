function clsyfyr = buildecc(listname,varargin)

param = finputcheck(varargin, {
    'mode', 'string', {'eval','test'}, 'eval'; ...
    'groups', 'real', [], [0 1 2]; ...
    });

loadsubj
group = 'crsdiag';

subjlist = eval(listname);
refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

groupvar = eval(group);
if strcmp(param.mode,'eval')
    groups = param.groups;
elseif strcmp(param.mode,'test')
    groups = unique(groupvar(~isnan(groupvar)));
end

selgroupidx = ismember(groupvar,groups);
groupvar = groupvar(selgroupidx);

clsyfyrlist = {
    'UWS_MCS-'  [1 -1  0]
    'MCS-_MCS+' [0  1 -1]
%     'UWS_MCS+'  [1  0 -1]
    };

predlabels = NaN(size(groupvar,1),size(clsyfyrlist,1));

ecccode = NaN(length(param.groups),size(clsyfyrlist,1));
for c = 1:size(clsyfyrlist,1)
    bincls = load(sprintf('clsyfyr_%s_%s.mat',group,clsyfyrlist{c,1}));
    if strcmp(param.mode,'eval')
        predlabels(groupvar == bincls.groups(1) | groupvar == bincls.groups(2),c) = bincls.clsyfyr.predlabels;
    elseif strcmp(param.mode,'test')
        disp(bincls.featlist(1,:));
        features = getfeatures(listname,bincls.featlist{1:3});
        rng('default');
        [~,postProb] = predict(fitSVMPosterior(bincls.clsyfyr.model),squeeze(features(:,bincls.clsyfyr.D,:)));
        predlabels(:,c) = double(postProb(:,2) >= bincls.clsyfyr.bestthresh);
    end
    ecccode(:,c) = clsyfyrlist{c,2};
end

predlabels(predlabels == 0) = -1;
predlabels(isnan(predlabels)) = 0;
ecclabels = NaN(size(groupvar));

for g = 1:size(groupvar,1)
    for k = 1:size(ecccode,1)
        dist(k) = 0;
        for j = 1:size(ecccode,2)
            if ecccode(k,j) ~= 0
                dist(k) = dist(k) + lossfunc(ecccode(k,j),predlabels(g,j));
            end
        end
    end
    [~,ecclabels(g)] = min(dist/sum(ecccode(k,:)));
end

ecclabels = ecclabels - 1;

if strcmp(param.mode,'eval')
    clear clsyfyr
    clsyfyr.trainlabels = groupvar;
    clsyfyr.predlabels = ecclabels;
    [clsyfyr.confmat,clsyfyr.chi2,clsyfyr.chi2pval] = crosstab(groupvar,ecclabels);
    save('clsyfyr_ecc.mat','clsyfyr','groups');
elseif strcmp(param.mode,'test')
    disp(ecclabels);
    fprintf('Accuracy = %.1f%%.\n', sum(ecclabels == (groupvar > 0)) * 100/length(ecclabels));
end

function loss = lossfunc(y,s)
% loss = (1 - sign(y*s))/2;
loss = exp(-y*s)/2;
